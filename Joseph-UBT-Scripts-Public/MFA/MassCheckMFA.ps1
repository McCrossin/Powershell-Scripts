[CmdletBinding()]
param (
    [Parameter(
        Mandatory = $true,
        Position = 0)
    ]
    [PSCredential]
    # Put in O365 credentials
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

    $box |
        ForEach-Object{
            $Name = $_.DisplayName
            $IsValid = $_.IsValid
            $IsShared = $_.IsShared
            $IsMailboxEnabled = $_.IsMailboxEnabled
        }

    $license = $MSOLUser.licenses.AccountSKUID
    
    if ($license -notlike $null){
        $IsLicensed = $true
    }else{
        $IsLicensed = $false
    }

    Write-Output ("Checking MFA for: " + $email)

    if ($isValid -and $IsMailboxEnabled){
        
        
        $MSOLUser | 
        select DisplayName,UserPrincipalName,@{N="MFA Status"; 
        E={ 
            if( $_.StrongAuthenticationRequirements.State -ne $null){ 
                $_.StrongAuthenticationRequirements.State
            }else { 
                "Disabled"
            }
          } 
        } | Export-Csv -Path "C:\Git\Joseph-UBT-Scripts-Company-Details\MFA\MFACheck.csv" -Append

        Write-Output ($Email + " MFA details added to MFACheck.csv")

    }elseif ($isValid -and $IsMailboxEnabled -and ($IsShared -eq $false)){
        
        
        $MSOLUser | 
        select DisplayName,UserPrincipalName,@{N="MFA Status"; 
        E={ 
            if( $_.StrongAuthenticationRequirements.State -ne $null){ 
                $_.StrongAuthenticationRequirements.State
            }else { 
                "Disabled"
            }
          }
        } | Export-Csv -Path "C:\temp\MFACheck_NonLicensed.csv" -Append

        Write-Output ($Email + " MFA details added to MFACheck_NonLicensed.csv")

    }else{
        Write-Output ($Email + " is not Valid or Licensed or is shared")
    }
    
    Write-Output ("------------------------------------")
}

Remove-PSSession $Session