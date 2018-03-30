#compare relative sizes

Get-CimInstance win32_process | Export-Clixml .\scratch.xml

[xml]$doc = Get-CimInstance win32_process | ConvertTo-Xml
$f = Join-Path -path (Convert-path .) -ChildPath scratch2.xml
$doc.Save($f)

Get-CimInstance win32_process | ConvertTo-Json | Set-Content -Path .\scratch.json
Get-CimInstance win32_process | Export-Csv -Path .\scratch.csv

Get-CimInstance win32_process | Out-File -FilePath .\scratch.txt

Dir scratch* | sort length -Descending

Import-Clixml .\scratch.xml | Select -first 5 -property Name 
import-csv .\scratch.csv | select -first 5 -property Name 
#converting from json is different
Get-Content .\scratch.json | ConvertFrom-Json | select -first 5 -property Name
Get-Content .\scratch.json | ConvertFrom-Json | Get-Member
$j = Get-Content .\scratch.json | ConvertFrom-Json 
$j | select -first 5 -Property Name

Get-Content .\scratch.txt
