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
#     Remove classic Teams            #
#######################################

# Remove Teams Machine-Wide Installer
Write-Host "Removing Teams Machine-wide Installer" -ForegroundColor Yellow
$MachineWide = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "Teams Machine-Wide Installer"}
$MachineWide.Uninstall()

#######################################
#     Install New Teams               #
#######################################


$teamstemppath = "c:\temp\teams"
if((Test-Path $teamstemppath) -eq $false) {
    Write-Host "AVD AIB Customization - Install Teams: Creating temp directory"
    New-Item -Path C:\temp -Name teams -ItemType Directory -ErrorAction SilentlyContinue}



Set-Location -path $teamstemppath

New-Item -Path HKLM:\SOFTWARE\Microsoft -Name "Teams" 
                $registryPath = "HKLM:\SOFTWARE\Microsoft\Teams"
                $registryKey = "IsWVDEnvironment"
                $registryValue = "1"
                Set-RegKey -registryPath $registryPath -registryKey $registryKey -registryValue $registryValue 


#install Edge WebView2
Invoke-WebRequest -Uri https://go.microsoft.com/fwlink/p/?LinkId=2124703 -OutFile $teamstemppath\webview2.exe


$webview_deploy_status = Start-Process `
    -FilePath "$teamstemppath\webview2.exe" `
    -ArgumentList "/silent /install" `
    -Wait `
    -Passthru

#install Teams
Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/?linkid=2243204&clcid=0x409" -OutFile $teamstemppath\teamsbootstrapper.exe

$NewTeams_deploy_status = Start-Process `
    -FilePath "$teamstemppathteamsbootstrapper.exe" `
    -ArgumentList "-p" `
    -Wait `
    -Passthru

#cleanup
  if ((Test-Path -Path $teamstemppath -ErrorAction SilentlyContinue)) {
                Remove-Item -Path $teamstemppath -Force -Recurse -ErrorAction Continue}
