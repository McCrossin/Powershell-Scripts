[CmdletBinding()]
param (
    [Parameter(
        Position = 0)
    ]
    [PSCredential]
    # Put in AD credentials
    $0AccountCreds = (Get-Credential -Message "Please input Domain Admin Credentials") ,
    [Parameter(
        Position = 1)
    ]
    [String]
    $AzureConnector = (read-host -prompt "Please input Azure Connector Hostname")
)


$AZUREDC = New-PSSession -ComputerName $AzureConnector -Credential $0AccountCreds
Import-Module -PSSession $AZUREDC -Name ADSync

Start-ADSyncSyncCycle -PolicyType Delta

Remove-PSSession $AZUREDC