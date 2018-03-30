#be careful with data files

Get-Content .\names.txt

Get-Content .\names.txt | Get-Service

#skip blank lines
Get-Content .\names.txt | where {$_ } | Get-Service

#still need to trim
(Get-Content .\names.txt | where {$_ }).foreach( {$_.trim()}) | Get-Service

#fine tune
(Get-Content .\names.txt | 
where {$_ -match '\w+' }).foreach( {$_.trim()}) | Get-Service

Function Optimize-Text {
    [cmdletbinding()]
    Param (
        [Parameter(Position = 0, ValueFromPipeline)]
        [string]$Text,
        [string]$CommentCharacter

    )
    Begin { 
        Write-Verbose "Start $($myinvocation.MyCommand)"
        $filterstring = '$_ -match "\S+"'
        If ($CommentCharacter) {
            $filterstring += " -AND `$_ -notmatch '$($commentcharacter)'"
        }
        Write-verbose "creating filter $filterstring"
        $filter = [scriptblock]::Create($filterstring)
    }
    Process {
        Write-Verbose "Optimizing: $text"
        $text | where-object $filter | foreach-object { $_.Trim() }  
    }
    End {
        Write-Verbose "End $($myinvocation.MyCommand)"
    }
}

Get-Content .\names.txt | Optimize-Text | Get-Service

Get-Content .\names2.txt | Optimize-Text -CommentCharacter "#" | Get-Service