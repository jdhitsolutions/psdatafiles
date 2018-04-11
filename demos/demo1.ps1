#beware type

.\newdata.ps1 | tee -Variable a
$a | Get-Member

$a | Export-csv .\obj.csv
import-csv .\obj.csv | tee -Variable b
$b | Get-Member

#if you know in advance you can do this
import-csv .\obj.csv | foreach {
    [PSCustomObject]@{
        Name  = $_.Name
        Size  = $_.Size -as [int32]
        Date  = $_.Date -as [DateTime]
        Value = $_.Value -as [double]
        TS    = $_.TS -as [timespan]
    }
} | get-member

#alternative using a class
#might be useful if you need to use type or format extensions
Class myData {
    [string]$Name
    [int32]$Size  
    [datetime]$Date  
    [double]$Value  
    [timespan]$TS 

    myData ($Name,$Size,$Date,$Value,$TS) {
        $this.name = $Name
        $this.Size = $Size
        $this.date = $Date
        $this.value = $Value
        $this.TS = $TS
    }
}

import-csv .\obj.csv | foreach {[myData]::new($_.Name,$_.Size,$_.Date,$_.Value,$_.TS)} | get-member

#json types
$a | convertto-json -Depth 1
$a | convertto-json | set-content -path .\obj.json

$j = get-content .\obj.json | Convertfrom-json
$j
$j | Get-Member
#you might try limiting depth
$a | convertto-json -Depth 1
$a | convertto-json -Depth 1 | Set-Content -Path .\obj2.json 
$k = get-content .\obj2.json | convertfrom-json 
$k | get-member
$k | Select Name,Size,Date,Value, @{Name="TS";Expression={$_.ts -as [timespan]}} -ov s| get-member
$s | format-table

#caution with json cmdlets and the pipeline
#this will fail
get-content .\obj2.json | convertfrom-json | 
Select Name,Size,Date,Value, @{Name="TS";Expression={$_.ts -as [timespan]}} -ov s| get-member
$s
get-content .\obj2.json | convertfrom-json | get-member
#fix
get-content .\obj2.json | convertfrom-json | foreach {
$_ | Select Name,Size,Date,Value, @{Name="TS";Expression={$_.ts -as [timespan]}}  } -ov s | get-member
$s

