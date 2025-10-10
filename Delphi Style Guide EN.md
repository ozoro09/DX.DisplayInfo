# Delphi Style Guide (EN)

> Version: 2.1
> Author: Olaf Monien
> Updated: 2025-10-08

> Note: This style guide is maintained in both German and English. Keep both documents in sync when making changes.

This guide defines formatting and naming conventions for modern Delphi projects. It aims to improve readability, maintainability, and team consistency.

---

## Quick Start - Essential Rules at a Glance

New to the project? Here are the essential rules:

### **Naming**
```pascal
// Variables
var
  LCustomer: TCustomer;        // Local: L prefix

type
  TMyClass = class
  private
    FName: string;             // Field: F prefix
  end;

// Parameters
procedure DoSomething(const AValue: string);  // Parameter: A prefix

// Loop counters - Exception!
for var i := 0 to 10 do       // Lowercase, no prefix

// Constants
const
  cMaxRetries = 3;             // Technical: c prefix
  scErrorMessage = 'Error';    // String: sc prefix
```

### **Types**
```pascal
type
  TCustomer = class end;           // Class: T prefix
  ILogger = interface end;         // Interface: I prefix
  TPoint = record end;             // Record: T prefix, NO F prefix for fields!
  TFileUtils = class sealed end;   // Utility class: sealed
  TStringHelper = record helper for string end;  // Helper: only for real helpers!
```

### **Error Handling**
```pascal
// Free resources
LObject := TObject.Create;
try
  // Use object
finally
  FreeAndNil(LObject);  // Always FreeAndNil instead of .Free
end;

// Multiple objects
LQuery := nil;
LList := nil;
try
  LQuery := TFDQuery.Create(nil);
  LList := TList<string>.Create;
finally
  FreeAndNil(LQuery);
  FreeAndNil(LList);
end;
```

### **Formatting**
- **2 spaces** indentation
- **120 characters** max line length
- `begin..end` always on separate lines
- Prefer inline variables (from Delphi 10.3+)

### **Collections**
```pascal
// Fixed size → TArray<T>
function GetNames: TArray<string>;

// Dynamic list → TList<T>
var LNumbers: TList<Integer>;

// Objects with ownership → TObjectList<T>
var LCustomers: TObjectList<TCustomer>;
```

### **Unit Names (Namespace Hierarchy)**
```pascal
// Forms end with .Form.pas
unit Main.Form;                    // TFormMain / FormMain
unit Customer.Details.Form;        // TFormCustomerDetails / FormCustomerDetails

// Data modules end with .DM.pas
unit Main.DM;                      // TDMMain / DMMain
unit Customer.Details.DM;          // TDMCustomerDetails / DMCustomerDetails
```

### **Documentation**
```pascal
/// <summary>
/// Calculates the sum of two numbers
/// </summary>
function Add(const AValue1, AValue2: Integer): Integer;
```

**→ See full documentation in the complete style guide.**

---

## License

MIT License
https://opensource.org/licenses/MIT

