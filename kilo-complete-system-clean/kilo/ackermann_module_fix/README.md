# Ackermann Module Fix

## Problem Fixed
The original ackermann-pwm-base module had an import error:
```
unknown resource type: API rdk:component:movement_sensor with model kilo:movement_sensor:oak-bmi270 not registered
```

This was caused by an incorrect import path in `main.go`:
```go
"github.com/viam-labs/ackermann-pwm-base/pwmbase"  // WRONG - trying to import from internet
```

## Solution
Created a proper Go module structure with:
1. **Correct module structure**: Main package and pwmbase subdirectory
2. **Proper imports**: Local package imports that work correctly
3. **Fixed build**: Successfully compiles to working binary

## Files Created
- `main.go` - Main entry point with corrected imports
- `go.mod` - Module definition with proper dependencies
- `pwmbase/base.go` - Base implementation (copied from original)
- `ackermann` - Compiled binary (46MB)

## Installation
1. Copy the `ackermann` binary to `/opt/kilo/bin/`
2. Copy the module files to `/opt/kilo/modules/ackermann-pwm-base/`
3. Update Viam configuration to use the fixed module

## Usage
```bash
# Test the module
./ackermann --help

# Run as service
sudo systemctl start ackermann-module
```

The module is now ready for Viam integration and should resolve the import errors.