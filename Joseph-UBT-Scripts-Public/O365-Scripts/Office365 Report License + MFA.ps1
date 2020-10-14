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
    $Office365Creds
)


#This connects to office365's live powershell which enables you to modify many asspects of O365 accounts
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $Office365Creds -Authentication Basic -AllowRedirection
Import-PSSession $Session -DisableNameChecking
Connect-MsolService -Credential $Office365Creds

$mailboxes = Get-MsolUser -All
$report = @()

foreach ($box in $mailboxes) 
{
    
    $box | Select UserPrincipalName, Licenses, DisplayName, UsageLocation |
        ForEach-Object{
            $email = $_.UserPrincipalName
            $Licenses = $_.Licenses
            $DisplayName = $_.DisplayName
            $UsageLocation = $_.UsageLocation
        }
     
     Write-Output ("Adding user: " + $email + " to sheet.")

    $licenses = $licenses | Select AccountSkuID
    for($i=0; $i -lt $licenses.Length; $i++){

        $license = $licenses[$i]
        
        $PSObject = New-Object PsObject -Property @{
            'Name' = $DisplayName
            'Email' = $email
            'Location' = $UsageLocation
            'License' = $license.AccountSkuId
        }
        $PSObject | Export-Csv -Path "C:\Users\joseph.mccrossin\OneDrive - Universal Business Team\Reports\GAPReports\CampusandcoReport.csv" -Append
    }
}

Remove-PSSession $Session