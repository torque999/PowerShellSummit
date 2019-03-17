Function Get-DiskInfo {
    [cmdletbinding()]
    Param(
        [Parameter(Position = 0, Mandatory, ValueFromPipeline, ValueFromPipelinebyPropertyName)]
        [ValidateNotNullorEmpty()]
        [string[]]$Computername,
        [ValidatePattern("[C-Gc-g]")]
        [string]$Drive = "C",
        [ValidateScript({Test-Path $path})]
        [string]$LogPath = $env:temp
    )
    Begin {
        Write-Verbose "Starting $($myinvocation.mycommand)"
        $filename = "{0}_DiskInfo_Errors.txt" -f (Get-Date -format "yyyyMMddhhmm")
        $errorLog = Join-Path -path $LogPath -ChildPath $filename
    }
    Process {
        foreach ($computer in $computername) {
            Write-Verbose "Getting disk information from $computer for drive $($drive.toUpper())"
            try {
                $data = Get-Volume -DriveLetter $drive -CimSession $computer -ErrorAction Stop
                $data | Select-Object -property DriveLetter,
                @{Name = "SizeGB"; Expression = {$_.size / 1gb -as [int]}},
                @{Name = "FreeGB"; Expression = {$_.SizeRemaining / 1GB}},
                @{Name = "PctFree"; Expression = {($_.SizeRemaining / $_.size) * 100 -as [int]}},
                HealthStatus,
                @{Name = "Computername"; Expression = {$_.PSComputername.toUpper()}}
            }
            catch {
                Add-Content -path $errorlog -Value "[$(Get-Date)] Failed to get disk data for drive $drive from $computer"
                Add-Content -path $errorlog -Value "[$(Get-Date)] $($_.exception.message)"
                $newErrors = $True
            }
        }
    }
    End {
        If ((Test-Path -path $errorLog) -AND $newErrors) {
            Write-Warning "Errors have been logged to $errorlog"
        }

        Write-Verbose "Ending $($myinvocation.MyCommand)"
    }
}