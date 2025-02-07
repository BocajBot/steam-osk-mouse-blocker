# Steam OSK Mouse Blocker

## Overview

This PowerShell script monitors for the **"Steam Input On-screen Keyboard"** window. When detected, it disables mouse input by installing a low-level mouse hook via embedded C# code. When the keyboard is not running, mouse input is restored.

## Features

- **Automatic Detection:** Monitors for the target window.
- **Dynamic Blocking:** Uses a low-level mouse hook to block mouse events.
- **Real-Time Feedback:** Displays status messages in the console.

## Prerequisites

- **Operating System:** Windows
- **PowerShell:** Version 5.0 or later
- **.NET Framework:** Pre-installed on Windows
- **Permissions:** Run as Administrator (if required)

## Installation

1. Clone or download the `MouseBlocker.ps1` script.
2. Save it in a directory with proper access rights.

## Usage

1. **Run as Administrator:** Open PowerShell with administrative privileges.
2. **Navigate to the Script Directory:**

   ```powershell
   cd [Path to your directory]
   ```

### Execute the Script

```powershell
.\MouseBlocker.ps1
```

## Output

- **When the on-screen keyboard is active:**

  ```plaintext
  Steam Input On-screen Keyboard is running. Mouse input is disabled.
  ```

- **When the keyboard is not active:**

  ```plaintext
  Steam Input On-screen Keyboard is NOT running. Mouse input is enabled.
  ```

## How It Works

### Embedded C# Code

Compiled using `Add-Type`, it includes:

- **Win32Helper:** Declares necessary Windows API functions.
- **WindowSearcher:** Checks for the target window.
- **MouseBlocker:** Sets and removes the low-level mouse hook.

### Monitoring Loop

A continuous PowerShell loop checks every second to start or stop mouse blocking based on the target window's presence.

## Troubleshooting

- **Administrative Rights:** Run PowerShell as Administrator if the mouse hook fails.
- **PowerShell Version:** Ensure you are using version 5.0 or later.
- **Compatibility:** This script works only on Windows.

## Disclaimer

This script is provided "as is" without any warranty. Test it in a controlled environment before using it in production.

## License

MIT License  
© 2025 BocajGnuoy
