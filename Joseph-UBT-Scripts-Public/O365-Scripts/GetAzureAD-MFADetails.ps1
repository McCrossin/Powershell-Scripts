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

$mailboxes = get-mailbox -resultsize unlimited

foreach ($box in $mailboxes) 
{
    
    $box | Select PrimarySmtpAddress |
        ForEach-Object{
            $Email = $_.PrimarySmtpAddress
        }
    
	$box |
        ForEach-Object{
            $Name = $_.DisplayName
            $IsValid = $_.IsValid
            $IsShared = $_.IsShared
            $IsLicensed = $_.IsLicensed
        }

    if ($isValid -and ($IsShared -eq $false) -and $IsLicensed){

        Get-MailboxLocation $Email | Select DataBaseLocation |
        ForEach-Object{
            $DataBaseLocation = $_.DatabaseLocation
        }

        $object = New-Object psobject
        $object | Add-Member -MemberType NoteProperty -name Name -Value $Name
        $object | Add-Member -MemberType NoteProperty -name Email -Value $Email
        $object | Add-Member -MemberType NoteProperty -name DataBase-Location -Value $DataBaseLocation

        $object | export-csv -Path C:\temp\UBTAReport.csv -Append

        Write-Output ("Email: " + $Email + "Name: " + $Name + "DataBase Location: " + $DataBaseLocation)

    }else{
        Write-Output ($Email + " Is an SharedMailbox or an Offboarded user")
    }
}

Remove-PSSession $Session