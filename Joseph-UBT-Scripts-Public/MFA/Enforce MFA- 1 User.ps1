[CmdletBinding()]
param (
    [Parameter(
        Position = 0)
    ]
    [PSCredential]
    # Put in AD credentials
    $O365Creds = (Get-Credential -Message "Please input Office365 Admin Credentials") ,
    [Parameter(
        Position = 1)
    ]
    [String]
    $Email = (read-host -prompt "Please Input Email for MFA")
)

Connect-MsolService -Credential $O365Creds

$st = New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationRequirement
$st.RelyingParty = "*"
$st.State = "Enforced"
$sta = @($st)

Set-MsolUser -UserPrincipalName $Email -StrongAuthenticationRequirements $sta
   Get-msolUser -UserPrincipalName $Email | 
    select DisplayName,UserPrincipalName,@{N="MFA Status"; 
    E={ 
        if( $_.StrongAuthenticationRequirements.State -ne $null){ 
            $_.StrongAuthenticationRequirements.State
        }else { 
            "Disabled"
        }
      }
    }