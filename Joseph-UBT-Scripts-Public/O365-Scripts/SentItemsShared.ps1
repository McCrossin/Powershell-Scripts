[CmdletBinding()]
param (
    [Parameter(
        Position = 0)
    ]
    [PSCredential]
    # Put in AD credentials
    $0365Creds = (Get-Credential -Message "Please input 0365 Admin Credentials") ,
    [Parameter(
        Position = 1)
    ]
    [String]
    $Email = (read-host -prompt "Please input Shared Mailbox Email: ")
)

Connect-ExchangeOnline -Credential $0365Creds -ShowProgress $true

set-mailbox $Email -MessageCopyForSentAsEnabled $True
set-mailbox $Email -MessageCopyForSendOnBehalfEnabled $True
