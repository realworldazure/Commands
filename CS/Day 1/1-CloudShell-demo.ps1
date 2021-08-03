<#
  Session Title: Up and Running with Azure Cloud Shell 
  Presenter: Mike Pfeiffer
#>

<#
Quickstart for PowerShell in Azure Cloud Shell
https://docs.microsoft.com/en-us/azure/cloud-shell/quickstart-powershell

 - Cloud Shell runs on a temporary host provided on a per-session, per-user basis
 - Cloud Shell times out after 20 minutes without interactive activity
 - Cloud Shell requires an Azure file share to be mounted
 - Cloud Shell uses the same Azure file share for both Bash and PowerShell
 - Cloud Shell persists $HOME using a 5-GB image held in your file share
#>

<#
PowerShell in Azure Cloud Shell for Windows users
https://docs.microsoft.com/en-us/azure/cloud-shell/cloud-shell-windows-users

 - File system case sensitivity
 - Windows PowerShell aliases vs Linux utilities
#>

<#
Features & tools for Azure Cloud Shell
https://docs.microsoft.com/en-us/azure/cloud-shell/features#tools
 
 - Secure automatic authentication
 - Azure drive (Azure:)
 - Deep integration with open-source tooling
#>

<#
Persist files in Azure Cloud Shell
https://docs.microsoft.com/en-us/azure/cloud-shell/persisting-shell-storage

 - Uses Azure Storage File Shares
 - $HOME persistence across sessions
#>

<#
Azure Account and Sign-In
https://marketplace.visualstudio.com/items?itemName=ms-vscode.azure-account
#>

<#
PowerShell Remoting in Cloud Shell
#>

#Enable ps remoting on a Windows VM (method #1)
Enable-AzVMPSRemoting -Name web1 -ResourceGroupName WebServers -Protocol https -OsType Windows

#Setup credentials for the remote machine (we'll fix this later)
$u = 'sysadmin'
$p = ConvertTo-SecureString 'P@ssw0rd2020' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($u, $p)

#Invoke commands remotely
Invoke-AzVMCommand -Name web1 -ResourceGroupName WebServers -ScriptBlock {get-service win*} -Credential $cred

Enter-AzVM -Name web1 -ResourceGroupName WebServers -Credential $cred

<#
Setting up your profile
#>

New-Item -ItemType file -Path $profile.CurrentUserAllHosts -Force
Write-Host "Hello, Mike! You have $((Get-AzVM).Count) VM(s) in this subscription!" -ForegroundColor green

<#
Using the Azure Cloud Shell editor
https://docs.microsoft.com/en-us/azure/cloud-shell/using-cloud-shell-editor
#>