<#
  Session Title: Mastering the Azure PowerShell Az module
  Presenter: Mike Pfeiffer
#>


<#
Intro to the Az Module
https://docs.microsoft.com/en-us/powershell/azure/new-azureps-module-az?view=azps-1.8.0
#>

#Sign in interactively
Connect-AzAccount

#Create a service principal
$cred= New-Object Microsoft.Azure.Commands.ActiveDirectory.PSADPasswordCredential `
-Property @{ StartDate=Get-Date; EndDate=Get-Date -Year 2030; Password='P@ssw0rd2020'}

$sp = New-AzAdServicePrincipal -DisplayName PSDeepDive -PasswordCredential $cred
Write-Output $sp

#Sign in with service principal

$u = 'bd6107f4-34c2-4a01-aab7-d4861981eaa0'
$p = ConvertTo-SecureString 'P@ssw0rd2020' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($u, $p)

Connect-AzAccount -ServicePrincipal -Credential $cred `
-Tenant '82c52ca8-e5e7-4d47-89a4-6697627717cf'

<#

Azure PowerShell offers a feature called Azure Context Autosave, which gives the following features:

 - Retention of sign-in information for reuse in new PowerShell sessions.
 - Easier use of background tasks for executing long-running cmdlets.
 - Switch between accounts, subscriptions, and environments without a separate sign-in.
 - Execution of tasks using different credentials and subscriptions, simultaneously, from the 
  same PowerShell session.

 To set PowerShell to forget your context and credentials, use Disable-AzContextAutoSave.
 With context saving disabled, you'll need to sign in to Azure 
 every time you open a PowerShell session.

 To allow Azure PowerShell to remember your context after the PowerShell session is closed, 
 use Enable-AzContextAutosave

 Context and credential information are automatically saved in a special hidden folder 
 in your user directory ($env:USERPROFILE\.Azure on Windows, and $HOME/.Azure on other platforms). 

#>

#Viewing your subscriptions

Get-AzSubscription

<#
Use multiple Azure subscriptions
https://docs.microsoft.com/en-us/powershell/azure/manage-subscriptions-azureps?view=azps-1.8.0
#>

Select-AzSubscription -SubscriptionId 123456

<#
Query output of Azure PowerShell:
https://docs.microsoft.com/en-us/powershell/azure/queries-azureps?view=azps-1.8.0
#>

#Selecting properties
Get-AzVM -Name web1 | Select-Object Name,VmId,ProvisioningState

#Selecting custom properties
Get-AzVM | 
  Select-Object Name,
                @{Name="DataDiskCount"; Expression={$_.StorageProfile.DataDisks.count}}

#Filtering results
Get-AzVM | 
  Where-Object {$_.StorageProfile.OsDisk.OsType -eq 'Linux'} | 
    Select-Object Name,VmID,ProvisioningState

#Filtering based on Status
Get-AzVM -Status
Get-AzVM -Status | Where-Object powerstate -eq deallocated

<#
Use tags to organize your Azure resources
https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-using-tags
#>

Get-AzResource -Name web1 | 
  Set-AzResource -Tag @{Updated=(Get-Date).ToLongDateString()} -Force

Get-AzResource -TagName Updated -TagValue ((Get-Date).ToLongDateString())

<#
Lock resources to prevent unexpected changes
https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-lock-resources
#>

Get-AzVM -Name web1 | New-AzResourceLock -LockLevel CanNotDelete -LockName Lock-Web1
Get-AzResourceLock

Get-AzResourceLock | Remove-AzResourceLock