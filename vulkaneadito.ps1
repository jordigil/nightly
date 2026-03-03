$ErrorActionPreference = "Stop"

try {
    net session 1>$null 2>$null
} catch {
    Write-Host "This script must be run with administrator privileges!"
    Exit 1
}

$VulkanSDKVer = "1.4.341.1"
$VulkanSDKArch = "X64"
$VulkanSDKOs = "windows"
$VULKAN_SDK = "C:/VulkanSDK/$VulkanSDKVer"
$ExeFile = "vulkansdk-windows-$VulkanSDKArch-$VulkanSDKVer.exe"
$Uri = "https://sdk.lunarg.com/sdk/download/$VulkanSDKVer/$VulkanSDKOs/$ExeFile"
$Destination = "./$ExeFile"

echo "Downloading Vulkanitto SDK $VulkanSDKVer from $Uri"
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile($Uri, $Destination)
echo "Finished downloading $ExeFile"

$Arguments = "--root `"$VULKAN_SDK`" --accept-licenses --default-answer --confirm-command install"

echo "Installing Vulkanitto SDK $VulkanSDKVer"
$InstallProcess = Start-Process -FilePath $Destination -NoNewWindow -PassThru -Wait -ArgumentList $Arguments
$ExitCode = $InstallProcess.ExitCode

if ($ExitCode -ne 0) {
    echo "Error installing Vulkanitto SDK $VulkanSDKVer (Error: $ExitCode)"
    Exit $ExitCode
}

echo "Finished installing Vulkanitto SDK $VulkanSDKVer"

if ("$env:GITHUB_ACTIONS" -eq "true") {
    echo "VULKAN_SDK=$VULKAN_SDK" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
    echo "$VULKAN_SDK/Bin" | Out-File -FilePath $env:GITHUB_PATH -Encoding utf8 -Append
}
