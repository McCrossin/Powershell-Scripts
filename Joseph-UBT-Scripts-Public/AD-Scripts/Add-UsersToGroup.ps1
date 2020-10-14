[CmdletBinding()]
param (
    [Parameter(
        Position = 0)
    ]
    [PSCredential]
    # Put in AD credentials
    $0AccountCreds = (Get-Credential -Message "Please input Domain Admin Credentials") ,
    [Parameter(
        Position = 1)
    ]
    [String]
    $DCName = (read-host -prompt "Please input Domain Controller Hostname"),
    [Parameter(
        Position = 2)
    ]
    [String]
    $Group = (read-host -prompt "Please input exact Group Name")
)

  
#Connect to DC
$DC = New-PSSession -ComputerName $DCName -Credential $0AccountCreds
Import-Module -PSSession $DC -Name ActiveDirectory

$ADUsers = Get-ADUser -SearchBase 'OU=Users,OU=UBT,OU=APAC,OU=0GLOBAL,DC=corp,DC=ubtglobal,DC=com' -Filter *

$ADUsers | ForEach-Object{
    
    Write-Output ("Adding " + $_.SamAccountName + " To Password-Reset-Enabled Group")
    Add-ADGroupMember -Identity "Password-Reset-Enabled" -Members $_.SamAccountName
    Write-Output ("-------------------------------------------------------")

}

Remove-PSSession $DC