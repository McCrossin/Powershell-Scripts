<#!!!!!!!!!!!!!!!!!!!
THIS WILL ONLY WORK FOR ONE TENNANT AT A TIME
!!!!!!!!!!!!!!!!!!!#>

[CmdletBinding()]
param (
    [Parameter(
        Mandatory = $true,
        Position = 0)
    ]
    [PSCredential]
    # Put in AD credentials
    $Office365Creds = (Get-Credential -Message "Please input Office365 Admin Credentials"),
    [Parameter(
        Position = 1)
    ]
    [String]
    $CSVPath = (get-CSV)
)


$CSV = import-csv -Path $CSVPath


Connect-MsolService -Credential $Office365Creds
Connect-ExchangeOnline -Credential $Office365Creds


#This will read each email in the email column and perform actions for each
$CSV | ForEach-Object {
    
    $Email = $_.Email

    $Box = Get-Mailbox $Email -ErrorAction silentlycontinue

    if ($Box.IsValid -eq $true){
        #configure autoreply
        


        #Set mailbox to shared
        if ($Box.IsShared -eq $false){
            Set-Mailbox $Email -Type Shared
            Write-Output ("Converted " + $Email + " To shared.")
        }else{
            Write-Output $Email + " is already shared."
        }

        

    }else{
        Write-Output ("The email address " + $Email + " is Invalid, please see if the data is correct")
    }


}

$CSV | ForEach-Object {

    $Email = $_.Email

    $Box = Get-Mailbox $Email -ErrorAction silentlycontinue

    if ($Box.IsValid -eq $true){

    #Check if Mailbox is actually shared, do not proceed until it is
        While ($Box.IsShared -eq $false){
            start-sleep -Seconds 5
            Write-Output "Waiting for Mailbox to convert to Shared"
            $Box = Get-Mailbox $Email
        }
    
        #Remove all licenses from the user
        (Get-MsolUser -UserPrincipalName $Email).licenses.AccountSKUID |
        foreach{
            Set-MsolUserLicense -UserPrincipalName $Email -RemoveLicenses $_
            Write-Output ("Removed License " + $_ + "From" + $Email)
        }

        $AutoReplyMessage = "Hello, `n 
        `n
        This email address is no longer monitored. `n
        To contact orbit please contact your respective regions mailbox, eg: `n
        au@orbitteam.com or euk@orbitteam.com `n
        `n
        Thank you very much."
        Set-MailboxAutoReplyConfiguration -Identity $Email -AutoReplyState enabled
        Set-MailboxAutoReplyConfiguration –identity $Email –InternalMessage $AutoReplyMessage –ExternalMessage $AutoReplyMessage
        #Block Sign in
        Set-MsolUser -UserPrincipalName $Email -BlockCredential $true

    }else{
        Write-Output ("The email address " + $Email + " is Invalid, please see if the data is correct")
    }

}