#Set variables
$rg = 'WebServerDemos'

#Enable PS Remoting on VM

$winParams = @{
  Name = 'web3'
  ResourceGroup = $rg
  Protocol = 'https'
  OsType = 'windows'
}

Enable-AzVMPSRemoting @winParams

#Build a credential object

$u = 'sysadmin'
$p = ConvertTo-SecureString 'P@ssw0rd2020' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($u, $p)

#Define a script block for the remote VM

$invokeParams = @{
  Name = 'web3'
  ResourceGroupName = $rg
  ScriptBlock = {
    get-service win*
  }
  Credential = $cred
}


Invoke-AzVMCommand @invokeParams
