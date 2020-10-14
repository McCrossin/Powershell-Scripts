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
    $CSVPath = (get-CSV)
)


#Connect to DC
$DC = New-PSSession -ComputerName $DCName -Credential $0AccountCreds
Import-Module -PSSession $DC -Name ActiveDirectory

$CSV = import-csv -Path $CSVPath

$CSV | ForEach-Object {

    $UserName = $_.SamAccountName

    Remove-ADGroupMember -Identity "APP-Global-HCM" -Members $UserName -Confirm:$false
    Remove-ADGroupMember -Identity "APP-Global-Smartsheet" -Members $UserName -Confirm:$false
    Remove-ADGroupMember -Identity "APP-Global-UBTStars" -Members $UserName -Confirm:$false
    Remove-ADGroupMember -Identity "APP-Global-Zoom-BASIC" -Members $UserName -Confirm:$false
    Remove-ADGroupMember -Identity "ROLE - VPN User" -Members $UserName -Confirm:$false
    Remove-ADGroupMember -Identity "ROLE-THE HIVE-VISITORS" -Members $UserName -Confirm:$false
    Remove-ADGroupMember -Identity "ROLE-UBT-ONLINELEARNING-Global-Standard" -Members $UserName -Confirm:$false

}

