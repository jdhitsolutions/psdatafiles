#not a demo file

[xml]$doc = import-csv .\data.csv | foreach {
    [PSCustomObject]@{
        ID =$_.ID -as [int32]
        Event = $_.Event
        Comment = $_.Comment
        Date = $_.Date -as [datetime]
    }
} | Convertto-xml

$doc.Save((Convert-path .\data.xml)) 