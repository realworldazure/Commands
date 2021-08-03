
Return "This is a walk-through demo script file."

<#
I am using commands from a teaching module called PSTeachingTools
which you can install from the PowerShell Gallery

Import-Module PSTeachingtools

you may be prompted to update Nuget and trust Microsoft.
#>

#region basics

#check your version
$PSVersionTable

#use tab completion

#navigation

#endregion

#region using Help

help help

#need to update on new installs from an elevated session

Update-Help

help *service*
help get-service
help get-service -full
help get-service -Examples
help get-service -Parameter computername
help get-service -ShowWindow
help get-service -online

help about*

#endregion

#region core commands

help Get-Command
Get-Command *service
get-command -noun Azure*service
get-command -noun Azure*service -verb get

help Get-AzureRmContainerService

#endregion

#region aliases

dir
ls
gsv

help gsv
get-command gsv

get-command -commandtype alias
get-alias
get-alias np

get-command -noun alias

new-alias -Name vol -Value get-volume
vol

# be careful in PowerShell Core

#endregion

#region psdrives and providers

pushd
cd c:\work
dir
dir -directory
cd 'HKLM:\SOFTWARE\Microsoft\Windows NT'
dir
cd Cert:\CurrentUser\my
dir
dir -directory
dir -DocumentEncryptionCert

Get-PSProvider
Get-PSDrive

cd c:\
#help can be provider aware
help get-childitem
help get-childitem -Path Cert:
help get-childitem -Path Cert: -Examples
help get-childitem -Path HKLM: -Examples

#create your own psdrives
new-psdrive -PSProvider Registry -Name NT -Root 'HKLM:\SOFTWARE\Microsoft\Windows NT'
cd nt:
dir

popd

help registry 
#showWindow won't work

#endregion

#region the pipeline

Get-Vegetable
Get-Vegetable -Name corn
help Set-Vegetable
Get-Vegetable -Name corn | Set-Vegetable -CookingState Grilled -passthru

Get-Vegetable -Name corn

help Set-Vegetable -Parameter name
help Set-Vegetable -Parameter inputobject
help Get-Vegetable -Parameter name

"turnip","corn" | Get-Vegetable
#but...
Get-Vegetable -name "turnip","corn"

#check help
help Get-Vegetable -Parameter name

#passthru
Get-Vegetable -name carrot | Set-Vegetable -count 10 -CookingState Roasted -Passthru

#how did this work? This is advanced stuff
cls
Trace-command -PSHost ParameterBinding -Expression {Get-Vegetable corn | Set-Vegetable -count 5}

#objects can change
Get-Vegetable -RootOnly | Measure-Object -Property count -sum 
Get-Vegetable -RootOnly | Measure-Object -Property count -sum | Select-object -Property sum 
$s = Get-Vegetable -RootOnly | Measure-Object -Property count -sum
$s.sum

#expanding properties
Get-Vegetable -RootOnly | Measure-Object -Property count -sum | Select-object -ExpandProperty Sum
#or use nested expressions
$s = (Get-Vegetable -RootOnly | Measure-Object -Property count -sum).sum
$s

#not everything is as it appears
cls
Get-Vegetable | Select-Object -property Name,State,Count

#Get-Member rules!
Get-Vegetable | Get-Member
#this can help
Get-Vegetable -Name corn | Select-object -Property *

Get-Vegetable | Select-Object -property Name,CookedState,IsRoot,Count | gm

#endregion

#region working with objects
cls

# filtering
# filter early
Get-Vegetable -Name pepper
#not this
Get-Vegetable | Where-Object {$_.Name -eq 'pepper'}
#simple expressions can be written like this

Get-Vegetable | Where-Object Name -eq 'pepper'
#Use Where-Object when you need it
Get-Vegetable -Name pepper | Where-Object color -EQ 'green'
Get-Vegetable -Name pepper | Where-Object color -EQ 'green' | 
Select-object Name,CookedState,Count,UPC

cls
Get-process
Get-process | where-object WS -gt 150MB

# sorting

Get-Vegetable | sort-Object -property count
Get-process | where-object WS -gt 150MB | Sort-Object -Property WS -Descending

Get-ChildItem c:\scripts -include *.ps1,*.txt -Recurse | 
Sort-Object -Property length -Descending | 
Select-object -first 10 -Property Fullname,Length,LastWritetime,Name

# grouping
cls
Get-Vegetable | Group-Object -Property color
#this is a new object
Get-Vegetable | Group-Object -Property color | Get-Member

Get-Vegetable | Group-Object -Property color | Sort-Object count,name -Descending | Select-object Count,Name

#see if you can follow this mentally
Get-ChildItem -Path c:\scripts -file -Recurse |
Where-Object {$_.Extension} | Group-Object -Property Extension |
Sort-Object -Property Count -Descending |
Select-Object -first 10 -Property Count,Name,
@{Name="Size";Expression={($_.group | Measure-Object -Property length -sum).sum}}

# exporting/importing/converting
Get-Vegetable | export-csv .\veg.csv
Get-Content .\veg.csv
Get-Vegetable | Select-object -Property Name,count,upc,isroot,color | Export-csv .\veg.csv
Get-Content .\veg.csv

Import-Csv .\veg.csv
cls
Import-Csv .\svc.txt
Import-Csv .\svc.txt | Get-Service
Import-Csv .\svc.txt | Get-Service | 
Select-Object Machinename,Name,Status,@{Name="Checked";Expression = { Get-Date}}

#Why?
help Get-Service -parameter *name

Import-Csv .\svc.txt | Get-Service | 
Select-Object Machinename,Name,Status,@{Name="Checked";Expression = { Get-Date}} | 
ConvertTo-Json

Import-Csv .\svc.txt | Get-Service | 
Select-object Machinename,Name,Status,@{Name="Checked";Expression = { Get-Date}} | 
ConvertTo-Json | Out-File .\svc.json -Encoding ascii

Get-Content .\svc.json | ConvertFrom-Json

#some formats are better
Import-Csv .\svc.txt | Get-Service | 
Select-Object Machinename,Name,Status,@{Name="Checked";Expression = { Get-Date}} | 
Export-Clixml -Path .\svc.xml
    
Get-Content .\svc.xml
Import-Clixml .\svc.xml 

Get-Command -verb convert*
Get-Command -verb export
get-command -Verb import

# formatting
Get-Service
Get-Service | format-table
Get-Service | format-list

dir C:\windows\notepad.exe | ft
dir C:\windows\notepad.exe | fl *

#grouping
Get-Process | Format-Table -GroupBy Company
Get-Process | Sort-Object Company | Format-Table -GroupBy Company

#formatting is the last thing
Get-Process | Format-Table | Sort-Object WS -Descending | Select-Object -first 10
Get-Process | Format-Table | Get-Member

#views
Get-Process 
Get-Process | Format-Table
Get-Process | Format-List

Get-Process | Format-Table -View starttime
Get-Process | Format-Table -view foo

#some processes don't allow access to this property
Get-Process | where {$_.priorityclass -AND $_.WS -gt 25MB} | 
Sort-Object priorityclass,name | Format-Table -view priority

Get-Process | Format-List
Get-Process | Format-List -view foo

#endregion