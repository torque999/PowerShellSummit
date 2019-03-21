function Start-NewVM
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]$Name
    )

    Begin
    {
        Start-VM -Name $Name
}
    Process
    {
        Invoke-Command -ComputerName $Name -ScriptBlock {
            Import-Module ServerManager
            New-Item -Path "c:\" -Name "Data" -ItemType "Directory"
            Install-WindowsFeature Windows-Server-Backup, Telnet-Client, Web-Ftp-Server, EnhancedStorage
        }
}
    End
    {

}


}

