[CmdletBinding()]
param (
    [Parameter(
        Mandatory = $false,
        Position = 0)
    ]
    [PSCredential]
    # Put in O365 credentials
    $Office365Creds
)

$Logfile = "C:\temp\MassCheckMFA.log"
Function LogWrite {
    Param ([string]$logstring)

    Add-content $Logfile -value $logstring
}


Connect-MsolService -Credential $Office365Creds

$mailboxes = Get-MsolUser -All

foreach ($box in $mailboxes) {
    #Sends stuff to a temp file is this just a log of who has been processed?
    $box | Select DisplayName, UsageLocation, UserPrincipalName | 
    Export-CSV -Path "C:\temp\AllEmailsDetails.csv" -Append


    # no Need to process Msoluser again
    $license = ($Box).licenses.AccountSKUID
    
    if ($license -notlike $null) {
        $IsLicensed = $true
    }
    else {
        $IsLicensed = $false
    }

    #Write-Output ("Checking MFA for: " + $email)

    if (($IsMailboxDisabled -eq $false) -and $IsLicensed) {
        
        $Box | select DisplayName, UserPrincipalName, UsageLocation,

        @{N   = "MFA Status"; 
            E = { 
                if ( $_.StrongAuthenticationRequirements.State -ne $null) { 
                    $_.StrongAuthenticationRequirements.State
                }
                else { 
                    "Disabled"
                }
            } 
        }

        #Write-Output ($Email + " MFA details added to MFACheck.csv")

    }
    else {
        #Write-Output ($Email + " is not Valid or Licensed or is shared")
        #LogWrite ($Email + " is not Valid or Licensed or is shared")
    }
    
    #Write-Output ("-----------------------------------------")
}
