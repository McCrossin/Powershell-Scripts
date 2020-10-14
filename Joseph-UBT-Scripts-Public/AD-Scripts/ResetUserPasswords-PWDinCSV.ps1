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

$CSV = Import-Csv -Path $CSVPath

#Connect to DC
$DC = New-PSSession -ComputerName $DCName -Credential $0AccountCreds
Import-Module -PSSession $DC -Name ActiveDirectory
 

$csv | ForEach-Object {
    $Name = $_.Name
    $Password = $_.Password
    $secure = ConvertTo-SecureString $Password -AsPlainText -Force


    Set-ADAccountPassword -Identity $Name -NewPassword $secure -Reset

    Write-Output ("Reset password for: " + $Name + " to " + $Password)

}