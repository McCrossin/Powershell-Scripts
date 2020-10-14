function Invite-AzureADUsers{
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
            [string]$CSVPath = (Get-CSV)
    )

    $CSV = import-csv -Path $CSVPath

    $CSV | ForEach-Object {

        New-AzureADMSInvitation -InvitedUserEmailAddress $email -InviteRedirectURL https://myapps.microsoft.com -SendInvitationMessage $true
        $user = Get-AzureADUser -Filter "Mail eq '$email'"
        $user | Set-AzureADUser -Department "[Redacted]" -JobTitle "[Redacted]"

    }
}

function Connect-AzureAD{
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true,
            Position = 0)
        ]
        [PSCredential]
        # Put in AD credentials
        $Office365Creds
    )

    #This connects to office365's live powershell which enables you to modify many asspects of O365 accounts
    Connect-AzureAD -Credential $Office365Creds
}