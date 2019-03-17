#BitsAdministration.psrc

@{

    # ID used to uniquely identify this document
    GUID                    = '2765e350-2627-46cc-8bf5-81493f357cef'

    # Author of this document
    Author                  = 'Art Deco'

    # Description of the functionality provided by these settings
    Description             = 'A sample JEA capability file for BITS administration'

    # Company associated with this document
    CompanyName             = 'Company'

    # Copyright statement for this document
    Copyright               = '2019'

    # Modules to import when applied to a session
    # ModulesToImport = 'MyCustomModule', @{ ModuleName = 'MyCustomModule'; ModuleVersion = '1.0.0.0'; GUID = '4d30d5f0-cb16-4898-812d-f20a6c596bdf' }
    ModulestoImport         = "BitsTransfer"

    # Aliases to make visible when applied to a session
    #VisibleAliases = 'Item1', 'Item2'
    VisibleAliases          = "gsv", "gcim", "dir", "h", "r"

    # Cmdlets to make visible when applied to a session
    # VisibleCmdlets = 'Invoke-Cmdlet1', @{ Name = 'Invoke-Cmdlet2'; Parameters = @{ Name = 'Parameter1'; ValidateSet = 'Item1', 'Item2' }, @{ Name = 'Parameter2'; ValidatePattern = 'L*' } }
    VisibleCmdlets          = "Get-Date",
    "Get-History",
    "Invoke-History",
    @{ Name = 'Start-Service'; Parameters = @{ Name = 'Name'; ValidateSet = 'BITS' }, @{Name = "Passthru"}},
    @{ Name = 'Stop-Service'; Parameters = @{ Name = 'Name'; ValidateSet = 'BITS' }, @{Name = "Passthru"}},
    @{ Name = 'Restart-Service'; Parameters = @{ Name = 'Name'; ValidateSet = 'BITS' }, @{Name = "Passthru"}},
    @{ Name = 'Set-Service'; Parameters = @{ Name = 'Name'; ValidateSet = 'BITS' }, @{Name = 'StartupType'}, @{Name = "Passthru"}},
    "bitstransfer\*"

    # Functions to make visible when applied to a session
    # VisibleFunctions = 'Invoke-Function1',
    # @{ Name = 'Invoke-Function2'; Parameters = @{ Name = 'Parameter1'; ValidateSet = 'Item1', 'Item2' }, @{ Name = 'Parameter2'; ValidatePattern = 'L*' } }
    VisibleFunctions        = "help", "Get-PSSender", "Get-Service", "Get-ChildItem", "Get-CimInstance"

    # External commands (scripts and applications) to make visible when applied to a session
    # VisibleExternalCommands = 'Item1', 'Item2'
    VisibleExternalCommands = "c:\windows\system32\netstat.exe", "c:\windows\system32\bitsadmin.exe"

    # Providers to make visible when applied to a session
    VisibleProviders        = 'FileSystem'

    # Scripts to run when applied to a session
    # ScriptsToProcess = 'C:\ConfigData\InitScript1.ps1', 'C:\ConfigData\InitScript2.ps1'

    # Aliases to be defined when applied to a session
    # AliasDefinitions = @{ Name = 'Alias1'; Value = 'Invoke-Alias1'}, @{ Name = 'Alias2'; Value = 'Invoke-Alias2'}

    # Functions to define when applied to a session
    # FunctionDefinitions = @{ Name = 'MyFunction'; ScriptBlock = { param($MyInput) $MyInput } }
    FunctionDefinitions     = @{ Name = 'Get-PSSender'; ScriptBlock = {
            param()
            [pscustomobject]@{
                ConnectionString = $PSSenderInfo.ConnectionString
                ConnectedUser    = $PSSenderInfo.ConnectedUser
                RunAsUser        = $PSSenderInfo.RunAsUser
                PSVersion        = $PSSenderInfo.ApplicationArguments.PSVersionTable.PSVersion
            }
        }
    },
    @{Name = 'Get-CimInstance'; ScriptBlock = {
            [cmdletbinding()]
            [alias("gcim")]
            Param(
                [ValidateSet("win32_Service")]
                [string]$Classname = "Win32_Service"
            )
            Begin {
                if (-Not $PSBoundParameters.ContainsKey("Classname")) {
                    $PSBoundParameters.Add("Classname", "Win32_Service")
                }
                $PSBoundParameters.add("Filter", "Name='bits'")
                Write-Verbose ($PSBoundParameters | Out-String)

                try {
                    $outBuffer = $null
                    if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer)) {
                        $PSBoundParameters['OutBuffer'] = 1
                    }
                    $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('CimCmdlets\Get-CimInstance', [System.Management.Automation.CommandTypes]::Cmdlet)
                    $scriptCmd = {& $wrappedCmd @PSBoundParameters }
                    $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
                    $steppablePipeline.Begin($PSCmdlet)
                }
                catch {
                    throw
                }

            } #begin

            Process {

                try {
                    $steppablePipeline.Process($_)
                }
                catch {
                    throw
                }

            } #process

            End {

                try {
                    $steppablePipeline.End()
                }
                catch {
                    throw
                }

            } #end
        }
    },
    @{Name = 'Get-Service'; ScriptBlock = {
            [CmdletBinding()]
            [alias("gsv")]
            Param()

            Begin {
                $PSBoundParameters.Add("Name", "Bits")
                Write-Verbose ($PSBoundParameters | Out-String)

                try {
                    $outBuffer = $null
                    if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer)) {
                        $PSBoundParameters['OutBuffer'] = 1
                    }
                    $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Management\Get-Service', [System.Management.Automation.CommandTypes]::Cmdlet)
                    $scriptCmd = {& $wrappedCmd @PSBoundParameters }
                    $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
                    $steppablePipeline.Begin($PSCmdlet)
                }
                catch {
                    throw
                }

            } #begin

            Process {

                try {
                    $steppablePipeline.Process($_)
                }
                catch {
                    throw
                }

            } #process

            End {

                try {
                    $steppablePipeline.End()
                }
                catch {
                    throw
                }
            } #end
        }
    },
    @{Name = "Get-ChildItem"; ScriptBlock = {
            [CmdletBinding()]
            [alias("dir")]
            Param(
                [Parameter(Position = 0)]
                [ValidateSet("C:\BitsDownloads")]
                [string]$Path = "C:\BitsDownloads",
                [Parameter(Position = 1)]
                [string]$Filter,
                [string[]]$Include,
                [string[]]$Exclude,
                [Alias('s')]
                [switch]$Recurse,
                [uint32]$Depth,
                [switch]$Force,
                [switch]$Name,
                [switch]$File
            )

            Begin {
                try {
                    $outBuffer = $null
                    if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer)) {
                        $PSBoundParameters['OutBuffer'] = 1
                    }
                    if (-not ($PSBoundParameters.ContainsKey("Path"))) {
                        $PSBoundParameters.Add("Name", "C:\BitsDownloads")
                    }
                    $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Management\Get-ChildItem', [System.Management.Automation.CommandTypes]::Cmdlet)
                    $scriptCmd = {& $wrappedCmd @PSBoundParameters }
                    $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
                    $steppablePipeline.Begin($PSCmdlet)
                }
                catch {
                    throw
                }
            } #begin

            Process {
                try {
                    $steppablePipeline.Process($_)
                }
                catch {
                    throw
                }
            } #process

            End {
                try {
                    $steppablePipeline.End()
                }
                catch {
                    throw
                }
            } #end
        }
    }

    # Variables to define when applied to a session
    # VariableDefinitions = @{ Name = 'Variable1'; Value = { 'Dynamic' + 'InitialValue' } }, @{ Name = 'Variable2'; Value = 'StaticInitialValue' }

    # Environment variables to define when applied to a session
    # EnvironmentVariables = @{ Variable1 = 'Value1'; Variable2 = 'Value2' }

    # Type files (.ps1xml) to load when applied to a session
    # TypesToProcess = 'C:\ConfigData\MyTypes.ps1xml', 'C:\ConfigData\OtherTypes.ps1xml'

    # Format files (.ps1xml) to load when applied to a session
    # FormatsToProcess = 'C:\ConfigData\MyFormats.ps1xml', 'C:\ConfigData\OtherFormats.ps1xml'

    # Assemblies to load when applied to a session
    # AssembliesToLoad = 'System.Web', 'System.OtherAssembly, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a'

}