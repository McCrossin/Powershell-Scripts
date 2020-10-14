function Connect-DC{
    <#
    .SYNOPSIS
    Connect to a DC
    .DESCRIPTION
    This sript will take credentials and connect to a DC

    .PARAMETER PSCredential
    This will be credentials to connect to DC
    .PARAMETER DCName
    This will be the desired DC to connect to
    .EXAMPLE
    New-PassPhrase -CSVPath "C:\temp\Names.csv" -output "C:\temp\SANames.csv"
    #>
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true,
            Position = 0)
        ]
        [PSCredential]
        # Put in AD credentials
        $0AccountCreds,
    
        [Parameter(
            Mandatory = $false,
            Position = 1)
        ]
        [string]$DCName = (Read-Host -Prompt "Please input DC Hostname")
    )

    try{
        #Connect to DC
        $DC = New-PSSession -ComputerName $DCName -Credential $0AccountCreds
        Import-Module -PSSession $DC -Name ActiveDirectory
    }catch{
        "There was an error in execution"
    }
}