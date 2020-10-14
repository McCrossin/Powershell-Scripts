[CmdletBinding()]
param (
    [Parameter(
        Position = 0)
    ]
    [PSCredential]
    $Office365Creds = (Get-Credential -Message "Please input 0365 Admin Credentials") ,
    [Parameter(
        Position = 1)
    ]
    [String]
    $CSVPath = (get-CSV)
)
$CSV = import-csv -Path $CSVPath


#This connects to office365's live powershell which enables you to modify many asspects of O365 accounts
<#$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $Office365Creds -Authentication Basic -AllowRedirection
Import-PSSession $Session -DisableNameChecking      !!!!No longer needed#>

Connect-MsolService -Credential $Office365Creds
Connect-ExchangeOnline -Credential $Office365Creds


#This will read each email in the email column and perform actions for each
$CSV | ForEach-Object {
    
    $Email = $_.Email

    #Check if Email is Valid before proceeding
    Get-Mailbox $Email | Select IsValid |
        ForEach-Object{
            $IsValid = $_.IsValid
        }

    $license = (Get-MsolUser -UserPrincipalName $Email).licenses.AccountSKUID
    $LicenseNotAssigned = $license -notcontains "reseller-account:ATP_ENTERPRISE"

    if (($IsValid -eq $true) -and $LicenseNotAssigned){

        #Add ATP 1 license to user
        Set-MsolUserLicense -UserPrincipalName $Email -AddLicenses "reseller-account:ATP_ENTERPRISE"
        Write-Output ("Added ATP1 License to: " + $Email)
        
    }elseif($LicenseNotAssigned = $false){

        Write-Output ("The email address: " + $Email + " Already has the requested License")

    }else{

        Write-Output ("The email address: " + $Email + " Is Invalid, please see if the data is correct")
        
    }
}