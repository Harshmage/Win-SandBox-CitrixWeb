# REPLACE contoso.com
# REPLACE citrix.contoso.com

Start-Transcript "C:\users\WDAGUtilityAccount\Desktop\CitrixWorkspaceInstall.log"
$uri = "https://downloadplugins.citrix.com/Windows/CitrixWorkspaceApp.exe"
$dlPath = "C:\users\WDAGUtilityAccount\Downloads\sandbox\CitrixWorkspaceApp.exe"

# Wait for the services to start
Start-Sleep -Seconds 10

# Test if we can get to the Citrix website
if ((Test-NetConnection -ComputerName citrix.com -Port 443).TcpTestSucceeded -eq $false) {
    Write-Host "No internet connection, using existing local file."
} else {
    # Download Citrix Workspace
    #cmd /c curl -s -L $uri -o $dlPath
    $ProgressPreference = 'SilentlyContinue' # Suppress the progress bar, this will make the download faster
    Invoke-WebRequest -URI $uri -OutFile $dlPath
}

# Install and run Citrix Workspace
Start-Process -FilePath $dlPath -ArgumentList "/silent noreboot startAppProtection"

While (Get-Process -Name CitrixWorkspaceApp -ErrorAction SilentlyContinue) {
    Start-Sleep -Seconds 5
}

# Add Citrix Workspace to the URLAllowList and AutoLaunchProtocolsFromOrigins
New-Item -Path HKCU:\SOFTWARE\Citrix\DesktopViewer -Name "Ignore.NET" -Force
New-Item -Path HKLM:\SOFTWARE\Policies\Microsoft\Edge -Name "URLAllowList" -Force
New-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Edge\URLAllowList -Name "1" -Value "*.contoso.com" -PropertyType String
New-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Edge\URLAllowList -Name "2" -Value "workspace://*" -PropertyType String
New-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Edge\URLAllowList -Name "3" -Value "receiver://*" -PropertyType String
New-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Edge -Name "AutoLaunchProtocolsFromOrigins" -PropertyType String -Value '[{"allowed_origins": ["citrix.contoso.com"], "protocol": "receiver"}]'
New-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Edge -Name "PasswordManagerEnabled" -Value "0" -PropertyType DWord

# Wait for the services to start
Start-Sleep -Seconds 10

# Open the Citrix page
& "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" --start-maximized https://citrix.contoso.com/
Stop-Transcript
