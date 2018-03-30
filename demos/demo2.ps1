
#region CSV

Import-Csv .\data.csv | tee -Variable in
$in | get-member

#some functions that consume a CSV file
Function Get-Tickle {
    [cmdletbinding(DefaultParameterSetName = "days")]
    Param(
        [string]$Path = "data.csv",
        [Parameter(ParameterSetName = "days")]
        [int32]$Days = 7,
        [Parameter(ParameterSetName = "all")]
        [switch]$All
    )

    $in = Import-Csv -Path $path | 
        Select-object @{Name = "ID"; Expression = {$_.id -as [int32]}}, Event, Comment,
    @{Name = "Date"; Expression = {$_.date -as [datetime]}}
    if ($All) {
        $in
    }
    else {
        $in | where-object {$_.date -gt (Get-Date) -AND $_.date -le (Get-Date).AddDays($Days)
        } | Sort-object -property Date
    }    
}

Function New-Tickle {
    [cmdletbinding()]
    Param(
        [Parameter(mandatory)]
        [string]$Event,
        [string]$Comment,
        [Parameter(mandatory)]
        [datetime]$Date,
        [string]$Path = "data.csv"
    )

    #import CSV to get last ID
    [int32]$last = (Import-Csv -path $Path | Select-Object -last 1).ID
    $last++
    $e = [pscustomobject]@{
        ID      = $last
        Event   = $Event
        Comment = $Comment
        Date    = $Date
    }

    $e | Export-csv -Path $path -Append
}

#Add an event
get-tickle
get-tickle | Get-Member
get-tickle -all
new-tickle -Event "Something soon" -Date 4:00PM
Get-Tickle
Get-Content data.csv -tail 4

#modify an event
Function Set-Tickle {
    [cmdletbinding(DefaultParameterSetName = "days")]
    Param(
        [string]$Path = "data.csv",
        [Parameter(mandatory)]
        [int32]$ID,
        [string]$Event,
        [string]$Comment,
        [datetime]$Date
    )

    #should only be one
    $in = Import-CSV -path $path
    $entry = $in | Where-object ID -eq $ID
    if ($event) {
        $entry.event = $event
    }
    If ($comment) {
        $entry.comment = $comment
    }
    if ($Date) {
        $entry.date = $date
    }
    #update the csv file
    $in | Export-Csv -Path $path -NoTypeInformation
    Get-Tickle -all | where-object id -eq $entry.ID
}

Set-Tickle -id 120 -Comment "foo" -Date (get-date).adddays(1)

#you could use CSV as a database

#removing an entry would also mean saving and re-writing the entire file

#on the plus side, easier to keep in synch between laptops.
#endregion

#region XML
<#
$f = Join-Path (convert-path .) data.xml
[xml]$doc = import-csv .\data.csv | 
Select @{Name="ID";Expression={$_.id as [int32]}},
Event,Comment,@{Name="Date";Expression={$_.date -as [datetime]}} |
Convertto-xml
$doc.save($f)
#>
#I'd create a function to wrap all of this up
#get objects
[xml]$In = Get-Content -Path .\data.xml -Encoding UTF8

$in.Objects.object[1].property

Function Get-TickleXML {
    [cmdletbinding(DefaultParameterSetName = "days")]
    Param(
        [string]$Path = "data.xml",
        [Parameter(ParameterSetName = "days")]
        [int32]$Days = 7,
        [Parameter(ParameterSetName = "all")]
        [switch]$All
    )

    [xml]$In = Get-Content -Path $path -Encoding UTF8

    $events = foreach ($obj in $in.Objects.object) {
        $obj.Property | ForEach-Object -begin {$hash = [ordered]@{}} -process {
            #look at value and compare to a regex pattern to figure type
            
            #add the property to the hashtable
            $propType = $_.type -as [type]
            $hash.Add($_.Name, ($_.'#text' -as $propType))
        } -end {
            #turn into an object
            New-Object -TypeName PSObject -Property $Hash
        } 
    }   
    if ($all) {
        $events | Sort-Object Date
    }
    else {
        $events | Where-Object {$_.date -gt (Get-Date) -And $_.date -le (Get-Date).AddDays($days)} |
            Sort-Object Date
    }
}

Get-TickleXML
Get-TickleXML -all

#new item
$fullpath = Convert-Path .\data.xml
[xml]$In = Get-Content -Path $fullpath -Encoding UTF8
#create an object
$e = [pscustomobject]@{
    ID      = 120
    Event   = "XML event"
    Comment = "practice makes perfect"
    Date    = (Get-Date).AddDays(1)
}

#create the entry
[xml]$newxml = $e | ConvertTo-Xml
  
   #Import the node
    $imp = $in.ImportNode($newXML.objects.object,$true)
    #append node
    $in.Objects.AppendChild($imp) | Out-Null
    #save the file
    $in.save($fullpath)

    Get-TickleXML

#searching is easier
$id = 120
$r = $in | Select-XML -XPath "//Object/Property[text()='$id']"
$r
$r.Node

#get the parent node
$obj = $r.node.ParentNode
$obj
#process as an object
$obj.Property | foreach-object -begin {$hash = [ordered]@{}} -process {
    #look at value and compare to a regex pattern to figure type
    #add the property to the hashtable
    $propType = $_.type -as [type]
    $hash.Add($_.Name, ($_.'#text' -as $propType))
} -end {
    #turn into an object
    New-Object -TypeName PSObject -Property $Hash
} 

#modify
$obj.property
$obj.SelectSingleNode("Property[@Name='Comment']")
$obj.SelectSingleNode("Property[@Name='Comment']").'#text' = "updated"
#save the file
$in.save($fullpath)

($in | Select-XML -XPath "//Object/Property[text()='$id']").node.parentnode.property

#remove
[xml]$In = Get-Content -Path $fullpath -Encoding UTF8

$node = ($in | Select-Xml -XPath "//Object/Property[text()='$id']").node.ParentNode
$node.Property
$node.parentNode.RemoveChild($node)
$in.save($fullpath)

cat $fullpath -tail 7

#endregion

#region My database option

#still under development
#https://github.com/jdhitsolutions/myTickle
Import-Module s:\mytickle -force
Get-Command -Module mytickle
# psedit S:\mytickle\myTickleFunctions.ps1

Get-TickleEvent -days 10

#endregion