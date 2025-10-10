program DisplayInfo;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  Winapi.Windows,
  Winapi.MultiMon,
  System.SysUtils,
  System.Math;

const
  // Shcore.dll - optional DPI-APIs (Win 8.1+)
  PROCESS_DPI_UNAWARE = 0;
  PROCESS_SYSTEM_DPI_AWARE = 1;
  PROCESS_PER_MONITOR_DPI_AWARE = 2;

  MDT_EFFECTIVE_DPI = 0;
  MDT_ANGULAR_DPI = 1;
  MDT_RAW_DPI = 2;

type
  TProcessDpiAwareness = Integer;
  TMonitorDpiType = Integer;

var
  // Function pointers (dynamically resolved)
  GSetProcessDpiAwareness: function(AValue: TProcessDpiAwareness): HRESULT; stdcall = nil;
  GGetDpiForMonitor: function(AhMon: HMONITOR; AdpiType: TMonitorDpiType; out AdpiX, AdpiY: Cardinal): HRESULT; stdcall = nil;

/// <summary>
/// Attempts to load DPI-related APIs from Shcore.dll (Windows 8.1+)
/// </summary>
/// <returns>True if at least one API was successfully loaded</returns>
function TryLoadShcoreAPIs: Boolean;
var
  LHandle: HMODULE;
begin
  Result := False;
  LHandle := LoadLibrary('Shcore.dll');
  if LHandle <> 0 then
  begin
    @GSetProcessDpiAwareness := GetProcAddress(LHandle, PAnsiChar('SetProcessDpiAwareness'));
    @GGetDpiForMonitor := GetProcAddress(LHandle, PAnsiChar('GetDpiForMonitor'));
    // We don't necessarily need both - GetDpiForMonitor is sufficient
    Result := Assigned(GSetProcessDpiAwareness) or Assigned(GGetDpiForMonitor);
  end;
end;

/// <summary>
/// Converts DPI value to percentage (96 DPI = 100%)
/// </summary>
/// <param name="ADpi">DPI value to convert</param>
/// <returns>Scaling percentage</returns>
function PercentFromDpi(const ADpi: Integer): Integer;
begin
  if ADpi <= 0 then
    Exit(100); // Fallback
  Result := Round(ADpi / 96 * 100);
end;

/// <summary>
/// Prints information about a monitor (device name, resolution, DPI scaling)
/// </summary>
/// <param name="AhMon">Monitor handle</param>
/// <param name="AInfo">Monitor information structure</param>
procedure PrintMonitorInfo(AhMon: HMONITOR; const AInfo: TMonitorInfoEx);
var
  LDevMode: DEVMODEW;
  LHasMode: LongBool;
  LhDC: Winapi.Windows.HDC;
  LDpiX, LDpiY: Cardinal;
  LDpiUsed: Integer;
  LScalePercent: Integer;
  LResX, LResY: Integer;
  LDeviceName: string;
begin
  LDeviceName := string(AInfo.szDevice);

  // Current device resolution
  ZeroMemory(@LDevMode, SizeOf(LDevMode));
  LDevMode.dmSize := SizeOf(LDevMode);
  LHasMode := EnumDisplaySettingsW(PWideChar(LDeviceName), DWORD(-1), LDevMode);
  if LHasMode then
  begin
    LResX := LDevMode.dmPelsWidth;
    LResY := LDevMode.dmPelsHeight;
  end
  else
  begin
    // Fallback (less accurate with multi-monitor DPI)
    LhDC := CreateDC('DISPLAY', PChar(LDeviceName), nil, nil);
    if LhDC = 0 then
      LhDC := GetDC(0);
    try
      LResX := GetDeviceCaps(LhDC, HORZRES);
      LResY := GetDeviceCaps(LhDC, VERTRES);
    finally
      if LhDC <> 0 then
        DeleteDC(LhDC);
    end;
  end;

  // DPI / Scaling:
  if Assigned(GGetDpiForMonitor) and (GGetDpiForMonitor(AhMon, MDT_EFFECTIVE_DPI, LDpiX, LDpiY) = S_OK) then
  begin
    LDpiUsed := Integer(LDpiX); // X/Y are usually the same
  end
  else
  begin
    // Fallback via LOGPIXELSX
    LhDC := CreateDC('DISPLAY', PChar(LDeviceName), nil, nil);
    if LhDC = 0 then
      LhDC := GetDC(0);
    try
      LDpiUsed := GetDeviceCaps(LhDC, LOGPIXELSX);
      if LDpiUsed <= 0 then
        LDpiUsed := 96;
    finally
      if LhDC <> 0 then
        DeleteDC(LhDC);
    end;
  end;

  LScalePercent := PercentFromDpi(LDpiUsed);

  Writeln('---');
  Writeln('Device: ', LDeviceName);
  if (AInfo.dwFlags and MONITORINFOF_PRIMARY) <> 0 then
    Writeln('Primary Monitor: Yes')
  else
    Writeln('Primary Monitor: No');
  Writeln(Format('Resolution (current): %dx%d pixels', [LResX, LResY]));
  Writeln(Format('Scaling: ~%d%% (DPI ~%d)', [LScalePercent, LDpiUsed]));
end;

/// <summary>
/// Callback function for EnumDisplayMonitors
/// </summary>
/// <remarks>
/// Signature must match MONITORENUMPROC (PRect!)
/// </remarks>
function MonitorEnumProc(AhMon: HMONITOR; AhdcMon: HDC; AlprcMon: PRect; AdwData: LPARAM): BOOL; stdcall;
var
  LInfo: TMonitorInfoEx;
begin
  ZeroMemory(@LInfo, SizeOf(LInfo));
  LInfo.cbSize := SizeOf(LInfo);
  if GetMonitorInfo(AhMon, @LInfo) then
    PrintMonitorInfo(AhMon, LInfo);
  Result := True; // continue enumeration
end;

/// <summary>
/// Ensures the process is DPI-aware (modern or legacy method)
/// </summary>
procedure EnsureDpiAwareness;
type
  TSetProcessDPIAware = function: BOOL; stdcall;
var
  LUser32: HMODULE;
  LLegacy: TSetProcessDPIAware;
begin
  // Modern awareness (Win 8.1+)
  if Assigned(GSetProcessDpiAwareness) then
  begin
    GSetProcessDpiAwareness(PROCESS_PER_MONITOR_DPI_AWARE); // Ignore errors (e.g., already set)
    Exit;
  end;

  // Legacy (Vista+)
  LUser32 := GetModuleHandle('user32.dll');
  if LUser32 <> 0 then
  begin
    @LLegacy := GetProcAddress(LUser32, PAnsiChar('SetProcessDPIAware'));
    if Assigned(LLegacy) then
      LLegacy();
  end;
end;

begin
  try
    TryLoadShcoreAPIs;
    EnsureDpiAwareness;

    Writeln('Monitors, Resolution and Scaling:');
    EnumDisplayMonitors(0, nil, @MonitorEnumProc, 0);

    Writeln('---');
    Writeln('Note: 96 DPI = 100% scaling (effective DPI, if available).');
  except
    on E: Exception do
    begin
      Writeln('Error: ', E.ClassName, ' - ', E.Message);
    end;
  end;
end.

