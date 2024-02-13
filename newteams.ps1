function Set-RegKey($registryPath, $registryKey, $registryValue) {
    try {
         Write-Host "*** AVD AIB CUSTOMIZER PHASE ***  Teams Optimization  - Setting  $registryKey with value $registryValue ***"
         New-ItemProperty -Path $registryPath -Name $registryKey -Value $registryValue -PropertyType DWORD -Force -ErrorAction Stop
    }
    catch {
         Write-Host "*** AVD AIB CUSTOMIZER PHASE ***  Teams Optimization  - Cannot add the registry key  $registryKey *** : [$($_.Exception.Message)]"
    }
 }

#######################################
#     Install New Teams               #
#######################################


$teamstemppath = "c:\temp\teams"
if((Test-Path $teamstemppath) -eq $false) {
    Write-Host "AVD AIB Customization - Install Teams: Creating temp directory"
    New-Item -Path C:\temp -Name teams -ItemType Directory -ErrorAction SilentlyContinue}



#Set-Location -path $teamstemppath

Write-Host "AVD AIB Customization - Install Teams: Setting reg key"

if((Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Teams -Name "IsWVDEnvironment") -eq $false) 
    {
        New-Item -Path HKLM:\SOFTWARE\Microsoft -Name "Teams" 
        $registryPath = "HKLM:\SOFTWARE\Microsoft\Teams"
        $registryKey = "IsWVDEnvironment"
        $registryValue = "1"
        Set-RegKey -registryPath $registryPath -registryKey $registryKey -registryValue $registryValue
    }
else
    {
    Write-Host "AVD AIB Customization - Install Teams: Key already present"
    }

#install Edge WebView2
Write-Host "AVD AIB Customization - Install Teams: Downloading Edge WevView2"

Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/p/?LinkId=2124703" -OutFile $teamstemppath\webview2.exe -PassThru

Write-Host "AVD AIB Customization - Install Teams: Installing Edge WevView2"
$webview_deploy_status = Start-Process `
    -FilePath "$teamstemppath\webview2.exe" `
    -ArgumentList "/silent /install" `
    -Wait `
    -Passthru

#install Edge New Teams
Write-Host "AVD AIB Customization - Install Teams: Downloading New Teams Bootstrapper"

Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/?linkid=2243204&clcid=0x409" -OutFile $teamstemppath\teamsbootstrapper.exe -PassThru
Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/?linkid=2243204&clcid=0x409" -OutFile $teamstemppath\MSTeams-x64.msix -PassThru

# MSIX it https://go.microsoft.com/fwlink/?linkid=2196106&clcid=0x410&culture=it-it&country=it
#bootstrapper https://go.microsoft.com/fwlink/?linkid=2243204&clcid=0x409

Write-Host "AVD AIB Customization - Install Teams: Installing New Teams"

$NewTeams_deploy_status = Start-Process `
    -FilePath "$teamstemppath\teamsbootstrapper.exe" `
    -ArgumentList "-p -o $teamstemppath\MSTeams-x64.msix" `
    -Wait `
    -Passthru

#cleanup
Write-Host "AVD AIB Customization - Install Teams: Cleaning up"

Set-Location c:\
  if ((Test-Path -Path $teamstemppath -ErrorAction SilentlyContinue)) {
                Remove-Item -Path $teamstemppath -Force -Recurse -ErrorAction Continue}
