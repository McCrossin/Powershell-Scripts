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

$mailboxes = get-mailbox -resultsize unlimited | where-object {($_.primarysmtpaddress -like "*")}

foreach ($box in $mailboxes) 
{
    
    $box | Select PrimarySmtpAddress |
        ForEach-Object{
            $Email = $_.PrimarySmtpAddress
        }

    $MSOLUser = Get-MsolUser -UserPrincipalName $Email
    
	$box|
        ForEach-Object{
            $Name = $_.DisplayName
            $IsValid = $_.IsValid
            $IsShared = $_.IsShared
            $IsLicensed = $_.IsLicensed
        }

    if ($isValid -and $IsLicensed -and $IsShared){

        $license = $MSOLUser.licenses.AccountSKUID
        $HasE3 = $license -contains "reseller-account:ENTERPRISEPACK"

        if($HasE3){
            $object = New-Object psobject
            $object | Add-Member -MemberType NoteProperty -name Name -Value $Name
            $object | Add-Member -MemberType NoteProperty -name Email -Value $Email
            $object | Add-Member -MemberType NoteProperty -Name HasE3License -Value $HasE3

            $object | export-csv -Path C:\Git\Joseph-UBT-Scripts\O365-Scripts\E3LicenseReport.csv -Append
        }

    }elseif ($isValid -and $IsLicensed -and ($Email -notlike "ubtaccountants.com")){

        $license = $MSOLUser.licenses.AccountSKUID
        $HasE3 = $license -contains "reseller-account:ENTERPRISEPACK"

        if($HasE3){
            $object = New-Object psobject
            $object | Add-Member -MemberType NoteProperty -name Name -Value $Name
            $object | Add-Member -MemberType NoteProperty -name Email -Value $Email
            $object | Add-Member -MemberType NoteProperty -name Shared -Value $IsShared
            $object | Add-Member -MemberType NoteProperty -Name HasE3License -Value $HasE3

            $object | export-csv -Path C:\temp\E3LicenseReport.csv -Append

        }
    }
}

Remove-PSSession $Session