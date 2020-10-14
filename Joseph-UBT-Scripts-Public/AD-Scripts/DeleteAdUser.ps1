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


$CSV | ForEach-Object {
    $Name = $_.Name

    $SplitName = $Name.Split(" ")
    $Namelen = $SplitName.Count

    if ($Namelen -eq 2){
        $Firstname = $SplitName[0]
        $Surname = $SplitName[1]
    }else{
        $Firstname = $SplitName[0]
        for ($i=1; $i -ilt ($Namelen); $i++){
            $Surname = $Surname + $SplitName[$i]
        }
    }
    $SAMAccountName = "$Firstname" + ".$Surname"

    Remove-ADUser -Identity $SAMAccountName
}

Remove-PSSession $DC