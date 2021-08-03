
Return "This is a walk-through demo file. Not a script."

#region hashtables

help about_Hash_Tables

#key/value pair
$hash = @{
    Name    = "Mike"
    State   = "AZ"
    MVP     = $True
    Created = (Get-Date).ToUniversalTime()
}

$hash
$hash | get-member

$hash.keys
$hash.values
$hash.Item("name")
#you might also see this syntax
$hash["name"]

$hash.Name

#update values
$hash.Name = "Michelle"
$hash.mvp = $false
$hash.state = "IN"

$hash

#you can make it ordered
$hash = [ordered]@{
    Name    = "Mike"
    State   = "AZ"
    MVP     = $True
    ID      = New-GUID
    Created = (Get-Date).ToUniversalTime()
}

$hash

$k = @{}
$k.Add("Date",(Get-Date))
$k.add("Name",$env:USERNAME)
$k.add("Computername",$env:COMPUTERNAME)
$k.add("OS",(Get-CimInstance win32_operatingsystem).caption)

$k
#create a custom object
$obj = New-Object -TypeName PSObject -Property $k
$obj

#or you can do this:
[pscustomobject]$k

$m = [pscustomobject]@{ 
    Date         = (Get-Date) 
    Name         = $env:USERNAME 
    Computername = $env:COMPUTERNAME 
    OS           = (Get-CimInstance win32_operatingsystem).caption
}

$m

#splatting
$p = @{name="bits";computername = $env:computername;RequiredServices = $True}
Get-Service @p

#remember objects in the pipeline?
$m | Get-Service bits,wuauserv,sql* | Select-Object Machinename,Displayname,Status

#here's another common use
$m | Get-Service bits,wuauserv,sql* | 
Select-Object @{Name="Computername";Expression = { $_.Machinename} },
Displayname,Status

Get-VM | Select-Object Name, State, Uptime,
@{Name = "MemAssignedMB"; Expression = {$_.MemoryAssigned / 1MB}},
@{Name = "MemDemandMB"; Expression = {$_.MemoryDemand / 1MB}}, 
@{Name = "IP" ; Expression = { $_.networkadapters.IpAddresses | Where-Object {$_ -match "^\d{1,3}\."}}},
@{Name = "VMSwitch"; Expression = {$_.networkadapters.switchname }},
Computername

#endregion

#region scriptblocks

help about_script_blocks

$sb = { Get-VM | Select-Object Name, State, Uptime,
@{Name = "MemAssignedMB"; Expression = {$_.MemoryAssigned / 1MB}},
@{Name = "MemDemandMB"; Expression = {$_.MemoryDemand / 1MB}}, 
@{Name = "IP" ; Expression = {$_.networkadapters.IpAddresses | Where-Object {$_ -match "^\d{1,3}\."}}},
@{Name = "VMSwitch"; Expression = {$_.networkadapters.switchname }},
Computername
}

Invoke-Command -ScriptBlock $sb
#or
&$sb

#can have parameters
$sb = { 
Param ([string[]]$Name) 
Get-Service -name $Name | 
Select-Object -Property Name,Status,StartType  
}

&$sb Bits,Winrm,sql*

Invoke-Command -ScriptBlock $sb -ComputerName srv1,srv2,dom1 -ArgumentList @(,("bits","winrm","wuauserv","w32time")) -Credential company\artd |
Format-Table -groupby PSComputername -Property Name,Status,StartType

#this is the beginning of writing functions
$sb = {
Param ([string[]]$Computername = $env:computername,[pscredential]$Credential)

$cs = New-Cimsession @PSBoundParameters

foreach ($session in $cs) {
Write-Host "Getting system data from $($session.computername.toUpper())" -ForegroundColor Cyan
    [pscustomobject]@{
        RunningSvc = Get-CimInstance win32_service -cimsession $session -filter "State = 'running'" | 
        Select-object Name,StartMode,StartName,Displayname
        Process = Get-Ciminstance win32_process -CimSession $session
        OS = (Get-Ciminstance win32_operatingsystem -CimSession $session).caption
        Uptime = (Get-Date) - (Get-Ciminstance win32_operatingsystem -CimSession $session).lastbootUptime
        ReportDate = Get-Date
        Computername = $session.ComputerName.toUpper()
     }
 }
$cs | Remove-CimSession
}


&$sb dom1 $cred

function Get-SysData {

Param ([string[]]$Computername = $env:computername,[pscredential]$Credential)

$cs = New-Cimsession @PSBoundParameters

foreach ($session in $cs) {
Write-Host "Getting system data from $($session.computername.toUpper())" -ForegroundColor Cyan
    [pscustomobject]@{
        RunningSvc = Get-CimInstance win32_service -cimsession $session -filter "State = 'running'" | 
        Select-object Name,StartMode,StartName,Displayname
        Process = Get-Ciminstance win32_process -CimSession $session
        OS = (Get-Ciminstance win32_operatingsystem -CimSession $session).caption
        Uptime = (Get-Date) - (Get-Ciminstance win32_operatingsystem -CimSession $session).lastbootUptime
        ReportDate = Get-Date
        Computername = $session.ComputerName.toUpper()
     }
 }
$cs | Remove-CimSession

}

$data = Get-SysData -computername srv1,srv2,dom1 -Credential $cred

$data

#endregion

#region arrays

help about_arrays
$arr = "apple","banana","cherry","durian"
$arr
$arr | get-member
$arr[0]
$arr[1]
$arr[-1]
$arr.count

#initialize an empty array
$arr=@()
$arr += "jeff"
$arr += "tim"
$arr += "mike"
$arr += "jason"
$arr

#can't easily remove
$arr = $arr | where {$_ -ne 'jason'}
$arr

#works with objects
$p = Get-process
$p.count
$p[0..5]
$p[10].Name

#this is handy
$p.name

$p[10].modules
$p[10].modules.count
$p[10].modules[0] | select *
$p[10].modules[0].Fileversion

Get-process | Select-object ID,Name,Path,@{Name="ModuleVersion";Expression = { $_.modules[0].Fileversion }} 

#endregion

#region scripting constructs

#read the corresponsing about help topics
#if
$x = 11
if ($x -gt 10) {
 "Good to go"
}

if ($x -gt 100) {
  "good to go"
}
else {
 "not big enough"
}

if ($x -gt 100) {
  "good to go"
}
elseif ($x -gt 40) {
   "almost"
}
else {
 "not big enough"
}

#test with different values of x

#switch

$value = 20
Switch ($value) {
    10 { "use this scriptblock for 10" }
    20 { "use this scriptblock for 20" }
    30 { "use this scriptblock for 30"}
    Default { "defaulting to something" }
}

#be careful

Switch ($value) {
    {$_ -ge 10} { "use this scriptblock for 10"  }
    {$_ -ge 20} { "use this scriptblock for 20"  }
    {$_ -ge 30} { "use this scriptblock for 30" }
}

#ForEach

1..5 | foreach-object {$_ * 4 }
#writes to the pipeline
1..5 | foreach-object {$_ * 4 } | Measure-object -sum -average | select-object sum,average

$numbers = 1..5
foreach ($n in $numbers) {
    $n * 4
}

#this won't work
foreach ($n in $numbers) {
    $n * 4
} |  Measure-object -sum -average | select-object sum,average

$d = foreach ($n in $numbers) {
write-Host "Processing $n" -ForegroundColor cyan
    $n * 4
} 
$d | Measure-object -sum -average | select-object sum,average

#For
$numbers = 1..10
$sum = 0
for ($i = 0;$i -lt $numbers.count;$i++) {
    Write-Host "Processing $($numbers[$i])" -ForegroundColor yellow
    $sum += $numbers[$i] * 4
}
$sum

#Do/While
$n = 1
$sum = 0
do {

    $sum+=$n
    $n++

} while ($sum -le 500)

$n

$n = 100
$sum = 0
do {
write-host $n
    $sum+=$n
    $n++

} until ($sum -ge 500)

$n = 100
$sum = 500
while ($sum -le 500) {
write-host $n
    $sum+=$n
    $n++

}

#endregion