[void](Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
using System.Text;
using System.Diagnostics;

public class Win32Helper {
    [DllImport("user32.dll")]
    public static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);

    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);

    [DllImport("user32.dll", SetLastError = true)]
    public static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);
    
    [DllImport("user32.dll", SetLastError = true)]
    public static extern int GetWindowTextLength(IntPtr hWnd);

    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool IsWindowVisible(IntPtr hWnd);
}

public class WindowSearcher {
    public static string TargetWindow = "Steam Input On-screen Keyboard";
    public static bool Found = false;

    public static bool EnumCallback(IntPtr hWnd, IntPtr lParam) {
        if (!Win32Helper.IsWindowVisible(hWnd))
            return true; // Skip invisible windows

        int length = Win32Helper.GetWindowTextLength(hWnd);
        if (length == 0)
            return true; // Skip windows with no title

        StringBuilder sb = new StringBuilder(length + 1);
        Win32Helper.GetWindowText(hWnd, sb, sb.Capacity);

        string title = sb.ToString();
        if (title.Contains(TargetWindow)) {
            Found = true;
            return false; // Stop enumeration once found
        }

        return true; // Continue searching
    }

    public static bool IsKeyboardRunning() {
        Found = false;
        Win32Helper.EnumWindows(new Win32Helper.EnumWindowsProc(EnumCallback), IntPtr.Zero);
        return Found;
    }
}

public class MouseBlocker {
    private const int WH_MOUSE_LL = 14;
    private static IntPtr _hookID = IntPtr.Zero;
    public delegate IntPtr LowLevelMouseProc(int nCode, IntPtr wParam, IntPtr lParam);
    private static LowLevelMouseProc _proc = HookCallback;

    [DllImport("user32.dll", SetLastError = true)]
    private static extern IntPtr SetWindowsHookEx(int idHook, LowLevelMouseProc lpfn, IntPtr hMod, uint dwThreadId);

    [DllImport("user32.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    private static extern bool UnhookWindowsHookEx(IntPtr hhk);

    [DllImport("user32.dll", SetLastError = true)]
    private static extern IntPtr CallNextHookEx(IntPtr hhk, int nCode, IntPtr wParam, IntPtr lParam);

    [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    private static extern IntPtr GetModuleHandle(string lpModuleName);

    public static void StartBlocking() {
        if (_hookID == IntPtr.Zero) {
            _hookID = SetHook(_proc);
        }
    }

    public static void StopBlocking() {
        if (_hookID != IntPtr.Zero) {
            UnhookWindowsHookEx(_hookID);
            _hookID = IntPtr.Zero;
        }
    }

    private static IntPtr SetHook(LowLevelMouseProc proc) {
        using (Process curProcess = Process.GetCurrentProcess())
        using (ProcessModule curModule = curProcess.MainModule) {
            return SetWindowsHookEx(WH_MOUSE_LL, proc, GetModuleHandle(curModule.ModuleName), 0);
        }
    }

    private static IntPtr HookCallback(int nCode, IntPtr wParam, IntPtr lParam) {
        if (nCode >= 0) {
            // Block the mouse event (clicks, moves, etc.)
            return new IntPtr(1);
        }
        return CallNextHookEx(_hookID, nCode, wParam, lParam);
    }
}
'@)

# Monitor the on-screen keyboard 
$mouseBlocked = $false
Write-Output "Looking for On-Screen Keyboard..."
while ($true) {
    if ([WindowSearcher]::IsKeyboardRunning()) {
        if (-not $mouseBlocked) {
            [MouseBlocker]::StartBlocking()
            Write-Output "Steam Input On-screen Keyboard is running. Mouse input is disabled."
            $mouseBlocked = $true
        }
    } else {
        if ($mouseBlocked) {
            [MouseBlocker]::StopBlocking()
            Write-Output "Steam Input On-screen Keyboard is NOT running. Mouse input is enabled."
            $mouseBlocked = $false
        }
    }
    Start-Sleep -Seconds 1
}
