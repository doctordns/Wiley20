#requires -version 5.1

#this function is only as good as far as you trust what you find in the registy.

Function Get-PSInstalled {

    <#
    .Synopsis
    Get installed PowerShell versions
    .Description
    This command will query the registry for installed versions of PowerShell. It requires PowerShell remoting.
    .Parameter Computername
    Enter the name of a computer to query.
    .Parameter Credential
    Enter a credential object or username.
    .Parameter UseSSL
    Indicates that this cmdlet uses the Secure Sockets Layer (SSL) protocol to establish a connection to the remote computer. By default, SSL is not used.
    
    WS-Management encrypts all Windows PowerShell content transmitted over the network. The UseSSL parameter is an additional protection that sends the data across an HTTPS, instead of HTTP.
    
    If you use this parameter, but SSL is not available on the port that is used for the command, the command fails.
    .Parameter Session
    Specify an existing PSSession.
    .parameter ThrottleLimit
    Specifies the maximum number of concurrent connections that can be established to run this command. If you omit this parameter or enter a value of 0, the default value, 32, is used.
    .Example
    PS C:\> Get-PSInstalled -computername "dom1","srv1","win10" -Credential $artd
    
    Computername PSVersions                Date
    ------------ ----------                ----
    DOM1         {2.0, 5.1.14393.0, 7.0.0} 5/6/2020 5:00:18 PM
    SRV1         {5.1.14393.0}             5/6/2020 5:00:18 PM
    WIN10        {2.0, 5.1.18362.1, 7.0.0} 5/6/2020 5:00:18 PM
    
    Query computers using an alternate credential.
    
    .Example
    PS C:\> Get-PSSession | Get-PSInstalled
    
    Computername PSVersions                       Date
    ------------ ----------                       ----
    WIN10        {2.0, 5.1.18362.1, 7.0.0}        5/6/2020 9:01:07 PM
    SRV1         {5.1.14393.0}                    5/6/2020 9:01:07 PM
    DOM1         {2.0, 5.1.14393.0, 7.0.0}        5/6/2020 9:01:07 PM
    THINKP1      {5.1.18362.1, 7.0.0, 7.0.0-rc.1} 5/6/2020 9:01:07 PM
    SRV2         {2.0, 5.1.14393.0}               5/6/2020 9:01:07 PM
    SRV3         {2.0, 5.1.17763.1}               5/6/2020 9:01:07 PM
    
    Query for installed versions of PowerShell using existing PSSessions
    
    .Example
    PS C:\> Get-PSSession | Get-PSInstalled | Where-Object {$_.PSVersions -contains "2.0"}
    
    Computername PSVersions                Date
    ------------ ----------                ----
    WIN10        {2.0, 5.1.18362.1, 7.0.0} 5/6/2020 9:17:00 PM
    DOM1         {2.0, 5.1.14393.0, 7.0.0} 5/6/2020 9:17:00 PM
    SRV3         {2.0, 5.1.17763.1}        5/6/2020 9:17:00 PM
    SRV2         {2.0, 5.1.14393.0}        5/6/2020 9:17:00 PM
    
    Query remote computers and filter to only show those with PowerShell 2.0 installed.
    
    .Notes
    Learn more about PowerShell: http://jdhitsolutions.com/blog/essential-powershell-resources/
    #>
        [cmdletbinding(DefaultParameterSetName = "computer")]
        Param(
            [Parameter(ParameterSetName = "computer", Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = "Enter the name of a computer to query.")]
            [ValidateNotNullOrEmpty()]
            [string[]]$Computername = $env:COMPUTERNAME,
            [Parameter(ParameterSetName = "computer", ValueFromPipelineByPropertyName, HelpMessage = "Enter a credential object or username.")]
            [PSCredential]$Credential,
            [Parameter(ParameterSetName = "computer")]
            [switch]$UseSSL,
            [Parameter(ParameterSetName = "session", ValueFromPipeline)]
            [ValidateNotNullOrEmpty()]
            [System.Management.Automation.Runspaces.PSSession[]]$Session,
            [ValidateScript( {$_ -ge 0})]
            [int32]$ThrottleLimit = 32
        )
    
        Begin {
            #capture the start time. The Verbose messages can display a timespan.
            #this value can also be used as the audit date value
            $start = Get-Date
            #the first verbose message uses a pseudo timespan to reflect the idea we're just starting
            Write-Verbose "[00:00:00.0000000 BEGIN  ] Starting $($myinvocation.mycommand)"
    
            #a script block to be run remotely
            Write-Verbose "[$(New-TimeSpan -start $start) BEGIN  ] Defining scriptblock"
            $sb = {
                param([string]$VerbPref = "SilentlyContinue")
    
                $VerbosePreference = $VerbPref
                $regbase = "HKLM:\SOFTWARE\Microsoft"
                $versions = @()
    
                #windows powershell settings
                $pskey = Join-Path -Path $regbase -ChildPath PowerShell
                Write-Verbose "[$(New-TimeSpan -start $using:start) REMOTE ] Querying \\$($env:computername)\$pskey"
                Get-ChildItem $PSKey -Recurse -Include PowerShellEngine | ForEach-Object {
                    $leaf = Convert-Path $_.pspath # | Split-path -leaf
                    Write-Verbose "[$(New-TimeSpan -start $using:start) REMOTE ] ..$leaf"
                    $versions += $_.pspath | Get-ItemPropertyValue -name PowerShellVersion
                }
    
                #check for PS Core and later
                $pskey = Join-Path -Path $regbase -ChildPath PowerShellCore\InstalledVersions
    
                if (Test-Path -path $Pskey) {
                    Write-Verbose "[$(New-TimeSpan -start $using:start) REMOTE ] Querying \\$($env:computername)\$pskey"
                    Get-ChildItem $PSKey -Recurse | ForEach-Object {
                        $leaf = Convert-Path $_.pspath | Split-path -leaf
                        Write-Verbose "[$(New-TimeSpan -start $using:start) REMOTE ] ..$leaf"
                        $versions += $_.pspath | Get-ItemPropertyValue -name SemanticVersion
                    }
                }
                #send the result
                @{
                    Computername = $env:COMPUTERNAME
                    Versions     = $versions
                }
    
            } #scriptblock
    
            #parameters to splat to Invoke-Command
            Write-Verbose "[$(New-TimeSpan -start $start) BEGIN  ] Defining parameters for Invoke-Command"
            $icmParams = @{
                Scriptblock      = $sb
                Argumentlist     = $VerbosePreference
                HideComputerName = $True
                ThrottleLimit    = $ThrottleLimit
                ErrorAction      = "Stop"
                Session          = $null
            }
    
            #initialize an array to hold session objects
            [System.Management.Automation.Runspaces.PSSession[]]$All = @()
        } #begin
    
        Process {
            if ($PSCmdlet.ParameterSetName -eq 'computer') {
                foreach ($computer in $Computername ) {
                    $PSBoundParameters["Computername"] = $Computer
                    #create a session
                    Write-Verbose "[$(New-TimeSpan -start $start) PROCESS] Creating a temporary PSSession to $($computer.toUpper())"
                    If ($Credential.username) {
                        Write-Verbose "[$(New-TimeSpan -start $start) PROCESS] Using credential for $($credential.username)"
                    }
                    Try {
                        #save each created session to $tmp so it can be removed at the end
                        $all += New-PSSession @PSBoundParameters -ErrorAction Stop -OutVariable +tmp
                    }
                    Catch {
                        Write-Error $_
                    }
                } #foreach computer
            } #if computer parameterset
            Else {
                #only add open sessions
                foreach ($sess in $session) {
                    if ($sess.state -eq 'opened') {
                        Write-Verbose "[$(New-TimeSpan -start $start) PROCESS] Using session for $($sess.computername.toUpper())"
                        $all +=$sess
                    }
                }
            }
    
        } #process
    
        End {
    
            $icmParams["session"] = $all
    
            Try {
                Write-Verbose "[$(New-TimeSpan -start $start) END    ] Querying $($all.count) computers"
    
                Invoke-Command @icmParams | Foreach-Object {
                    Write-Verbose "[$(New-TimeSpan -start $start) END    ] Creating result for $($_.ComputerName)"
                    [pscustomobject]@{
                    Computername = $_.Computername
                    PSVersions   = $_.versions
                    Date         = $Start
                }
              } #foreach result
            } #try
            Catch {
                Write-Error $_
            } #catch
    
            if ($tmp) {
                Write-Verbose "[$(New-TimeSpan -start $start) END    ] Removing temporary PSSessions"
                $tmp | Remove-PSSession
            }
            Write-Verbose "[$(New-TimeSpan -start $start) END    ] Ending $($myinvocation.mycommand)"
        } #end
    }