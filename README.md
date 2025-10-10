# DX.DisplayInfo

A Windows console application that displays resolution and scaling information for all connected monitors.

## Features

- Lists all connected monitors
- Shows current resolution for each monitor
- Displays DPI scaling percentage
- Identifies the primary monitor
- Supports modern DPI awareness (Windows 8.1+) with fallback for older systems

## Requirements

- Windows Vista or later (Windows 8.1+ recommended for full DPI support)
- Delphi 10.3 or later (for compilation)

## Building

### Using Delphi IDE

1. Open `DisplayInfo.dproj` in Delphi
2. Select Build Configuration (Debug or Release)
3. Select Platform (Win32 or Win64)
4. Press F9 to compile and run, or Shift+F9 to compile only

### Using Command Line

```cmd
dcc32 DisplayInfo.dpr
```

Or for 64-bit:

```cmd
dcc64 DisplayInfo.dpr
```

## Output Structure

The project follows a clean output structure:

- **Executables**: `Win32\Debug\` or `Win32\Release\`
- **DCU files**: `Win32\Debug\dcu\` or `Win32\Release\dcu\`

## Usage

Simply run the executable:

```cmd
DisplayInfo.exe
```

### Example Output

```
Monitors, Resolution and Scaling:
---
Device: \\.\DISPLAY1
Primary Monitor: Yes
Resolution (current): 3840x2160 pixels
Scaling: ~150% (DPI ~144)
---
Device: \\.\DISPLAY2
Primary Monitor: No
Resolution (current): 1920x1080 pixels
Scaling: ~100% (DPI ~96)
---
Note: 96 DPI = 100% scaling (effective DPI, if available).
Press Enter to continue...
```

## Code Style

This project follows the [Delphi Style Guide](Delphi%20Style%20Guide%20EN.md) included in the repository.

Key conventions:
- 2 spaces indentation
- Local variables prefixed with `L`
- Parameters prefixed with `A`
- Global variables prefixed with `G`
- XML documentation comments for public APIs
- Proper error handling with `try..finally` blocks

## Technical Details

### DPI Awareness

The application uses two methods to ensure proper DPI awareness:

1. **Modern (Windows 8.1+)**: Uses `SetProcessDpiAwareness` from `Shcore.dll`
2. **Legacy (Windows Vista+)**: Falls back to `SetProcessDPIAware` from `user32.dll`

### Monitor Information

Monitor information is retrieved using:
- `EnumDisplayMonitors` - Enumerates all display monitors
- `GetMonitorInfo` - Gets monitor information including device name and primary status
- `EnumDisplaySettings` - Gets current display resolution
- `GetDpiForMonitor` - Gets effective DPI (Windows 8.1+)
- `GetDeviceCaps` with `LOGPIXELSX` - Fallback DPI detection

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

Copyright (c) 2025 Olaf Monien

