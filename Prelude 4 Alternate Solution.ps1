# You might also use TestCases in your Pester test

$computername = "SRV3"

$admin = Get-Credential -Message "enter the admin credential for $computername" -UserName "$computernameadministrator"

#the session is using PowerShell Direct to connect to a Hyper-V virtual machine
$remote = New-PSSession -VMName $computername -Credential $admin

Describe "ServerConfiguration for $Computername" {
  It "Should have a System event log maximum size of 2GB" {
    $log = Invoke-Command { (get-eventlog -list).where({$_.log -eq 'system'})} -session $remote
    $log.MaximumKilobytes | Should be (2gb/1kb) 
  }

  $paths = @("C:Data") 
  $months = (Get-Culture).DateTimeFormat.AbbreviatedMonthNames | Where-object {$_}
  foreach ($month in $months) {
      #build a path and add it to the array
      $paths+=(Join-Path -Path "C:Data" -ChildPath $month)
  }
  foreach ($path in $paths) {
      It "$path Should exist" {
        Invoke-command { Test-Path $using:Path} -session $remote | Should BeTrue
      }
  }
  
  #get current feature state
  Invoke-Command { Get-WindowsFeature} -Session $remote |
  Foreach-Object -Begin { $feat = @{} } -process {
    $feat.add($_.name,$_.installed)
  }

  $add = @("windows-server-backup","telnet-client","web-ftp-server","enhancedstorage")
  foreach ($feature in $add) {
      It "Windows feature $feature should be installed" {
        $feat[$feature] | Should BeTrue
      }
  }
  $remove = @("powershell-v2","snmp-service")
  foreach ($feature in $remove) {
      It "Windows feature $feature should NOT be installed" {
        $feat[$feature] | Should BeFalse
      }
  }

  $Policy = "Remotesigned"
  It "Should have an execution policy of $policy" {
    (Invoke-Command { Get-ExecutionPolicy} -session $Remote).value | should be $policy
  }

  $Trusted = "172.16.100.*"
  It "Includes $trusted in Trustedhosts" {
   (Invoke-Command { Get-Item WSMan:localhostClientTrustedHosts} -session $remote).value | Should -Match $trusted
  }
  It "Should have a local administrator account for RoyGBiv" {
    $user = Invoke-command { Get-Localuser RoyGBiv} -session $remote
    $group = Invoke-command { Get-LocalGroupMember administrators } -session $remote
    
    $user.name | Should Be "RoyGBiv"
    $group.Name | Should Contain "$computernameRoyGbiv" 
  }
  It "Should have the PSScriptTools Module installed" {
     $m = Invoke-Command {Get-Module PSScriptTools -listavailable} -session $remote
     $m.name | Should be "PSScriptTools"
  } 
}

 Remove-PSSession $remote