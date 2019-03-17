$params = @{
    Path                = ".\myBits.pssc"
    SessionType         = "RestrictedRemoteServer"
    TranscriptDirectory = "c:\JEA-Transcripts"
    RunAsVirtualAccount = $True
    Description         = "Company BITS Admin endpoint"
    RoleDefinitions     = @{'Company\BitsAdmins' = @{ RoleCapabilities = 'BITSAdministration' }}

}
New-PSSessionConfigurationFile @params