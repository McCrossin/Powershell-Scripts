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
    $CSVPath = (get-CSV),
    [Parameter(
        Position = 3)
    ]
    [String]
    $Password = (read-host -prompt "Please input Password")
)

$CSV = Import-Csv -Path $CSVPath
  
#Connect to DC
$DC = New-PSSession -ComputerName $DCName -Credential $0AccountCreds
Import-Module -PSSession $DC -Name ActiveDirectory


$CSV | ForEach-Object {

    $Name = $_.Name
    $Entity = $_.Entity
    $Department = $_.Department
    $Manager = $_.Manager
    $Position = $_.Position
    $TargetUser = $_.CopyUser
    $Location = $_.Location
    $HideInHive = $_.HideInHive
    $Country = $_.Country


    if ($TargetUser -eq "standard"){
        $CopyUser = Get-ADUser -Filter {SamAccountName -eq "SOPstandard"} -Properties *
    }elseif ($TargetUser -eq "standard.ubta"){
        $CopyUser = Get-ADUser -Filter {SamAccountName -eq "SOPUBTAStandardUser"} -Properties *
    }else{
        $CopyUser = Get-ADUser $TargetUser -Properties *
    }

    if ($Entity -eq "UBTA"){
        $Domain = "@ubtaccountants.com"
    }elseif ($Entity -eq "RRT"){
        $Domain = "@au-rapidreliefteam.org"
    }elseif ($Entity -eq "Co Shield"){
        $Domain = "@coshield.com"
    }elseif ($Entity -eq "CoShield"){
        $Domain = "@coshield.com"
    }else{
        $Domain = "@ubteam.com"
    }

    $TargetGroups = $CopyUser.MemberOf
    $TargetOU = $CopyUser.DistinguishedName -replace "CN=$($CopyUser.Name)," , ""


    if($Location -eq "Sydney Precinct"){
        $City = $CopyUser.City
        $State = $CopyUser.State
        $Street = $CopyUser.StreetAddress
        $Postal = $CopyUser.PostalCode
    }else{
        $Street = $Location
    }

    #Get more variables for account
    $SplitName = $name.Split(" ")
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

    if ($Manager -notmatch '\.'){
        if ($Manager -ne ""){
            $ManagerSplit = $Manager.Split(" ")
            $ManagerFirst = $ManagerSplit[0]
            $ManagerSurname = $ManagerSplit[1]

            $Manager = ($ManagerFirst + "." + $ManagerSurname)
        }
    }


    $EmailAddress = "$Firstname" + ".$Surname" + $Domain
    
    if ($Entity -eq "Co Shield"){
        $SAMAccountName = "$Firstname" + ".$Surname" + "1"
    }elseif ($Entity -eq "CoShield"){
        $SAMAccountName = "$Firstname" + ".$Surname" + "1"
        $HideInHive = $true
    }else{
        $SAMAccountName = "$Firstname" + ".$Surname"
    }

    #Proxy Details
    $UBTProxy = "SMTP:" + $EmailAddress
    $MicrosoftProxy = "smtp:" + $SAMAccountName + "@UBT365.onmicrosoft.com"

    if ($Manager -eq ""){
      $ADDetails = @{
            Name = $Name
            DisplayName = $Name
            GivenName = $Firstname
            Surname = $Surname
            SamAccountName = $SAMAccountName
            EmailAddress = $EmailAddress
            UserPrincipalName = $EmailAddress
            Path = $targetOU
            Title = $Position
            Department = $Department
            Company = $Entity
            POBOX = $Country
            StreetAddress = $Street
            PostalCode = $Postal
            City = $City
            State = $State
        }
    }else{
        $ADDetails = @{
            Name = $Name
            DisplayName = $Name
            GivenName = $Firstname
            Surname = $Surname
            SamAccountName = $SAMAccountName
            EmailAddress = $EmailAddress
            UserPrincipalName = $EmailAddress
            Path = $targetOU
            Title = $Position
            Manager = $Manager
            Department = $Department
            Company = $Entity
            POBOX = $Country
            StreetAddress = $Street
            PostalCode = $Postal
            City = $City
            State = $State
        }
    }
    

    #!!!!!!!!!!!!!!!!Everything here will interact with AD!!!!!!!!!!!!!!!!
    New-ADUser @ADDetails
    $TargetGroups | Add-ADGroupMember -Members $SAMAccountName
    Set-ADAccountPassword -Identity $SAMAccountName -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "$Password" -force)
    Set-ADUser -Identity $SAMAccountName -Enabled $true
    Set-ADUser $SamAccountName -Add @{'proxyAddresses'=$UBTProxy}
    Set-ADUser $SamAccountName -Add @{'proxyAddresses'=$MicrosoftProxy}
    Set-ADUser $SamAccountName -Add @{'HideInDirectory'=$HideInHive}
    #!!!!!!!!!!!!!!!!Everything Here will interact with AD!!!!!!!!!!!!!!!!

    #Move-ADObject -Identity $SAMAccountName -TargetPath $TargetOU --testing this functionality

    write-host "Made Account with the following details:"
    write-host @ADDetails
    write-host "Password: " $Password
    write-host "Proxy Addressess:" $UBTProxy $MicrosoftProxy
    write-host "OU location: " $TargetOU

}

#Get details from the AD user we need to copy



Remove-PSSession $DC