#code to generate some sample data

"Jeff","Don","Jason","Richard","Bruce" | foreach {

[PSCustomObject]@{
Name = $_
Size = Get-Random -min 100kb -max 10mb
Date = (Get-Date).AddHours((Get-Random -min 30 -max 300))
Value = (Get-Random -min 1 -max 10)/3.2
TS = New-TimeSpan -Hours (Get-Random -min 1 -max 23) -Minutes (Get-Random -min 1 -max 59)
}

}

