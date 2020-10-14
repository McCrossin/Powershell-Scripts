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
        Position = 2)
    ]
    [String]
    $Password = (read-host -prompt "Please input Password")
)

$CSV = Import-Csv -Path $CSVPath
  
#Connect to DC
$DCAU = New-PSSession -ComputerName $DCName -Credential $0AccountCreds
Import-Module -PSSession $DCAU -Name ActiveDirectory


$CSV | ForEach-Object {

    $Name = $_.Name
    $Entity = $_.Entity
    $Department = $_.Department
    $Manager = $_.Manager
    $Position = $_.Position
    $TargetUser = $_.CopyUser

}

#Get details from the AD user we need to copy

if ($TargetUser -eq "standard"){
    $CopyUser = Get-ADUser -Filter {SamAccountName -eq "SOPstandard"} -Properties *
}else{
    $CopyUser = Get-ADUser $TargetUser -Properties *
}

if ($Entity -eq "UBTA"){
    $Domain = "@ubtaccountants.com"
}else{
    $Domain = "@ubteam.com"
}

$TargetGroups = $CopyUser.MemberOf
$TargetOU = $CopyUser.DistinguishedName -replace "CN=$($CopyUser.Name)," , ""
$Country = $CopyUser.Country
$City = $CopyUser.City
$State = $CopyUser.State
$Street = $CopyUser.StreetAddress
$Postal = $CopyUser.PostalCode

#Get more variables for account
$Firstname = $Name.Split(" ")[0]
$Surname = $Name.Split(" ")[1]
$EmailAddress = "$Firstname" + ".$Surname" + $Domain
$SAMAccountName = "$Firstname" + ".$Surname"

#Proxy Details
$UBTProxy = "SMTP:" + $EmailAddress
$MicrosoftProxy = "smtp:" + $SAMAccountName + "@UBT365.onmicrosoft.com"


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
    Country = $Country
    StreetAddress = $Street
    PostalCode = $Postal
    City = $City
    State = $State
}

<#!!!!!!!!!!!!!!!!Everything here will interact with AD!!!!!!!!!!!!!!!!
New-ADUser @ADDetails
$TargetGroups | Add-ADGroupMember -Members $SAMAccountName
Set-ADAccountPassword -Identity $SAMAccountName -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "$Password" -force)
Set-ADUser -Identity $SAMAccountName -Enabled $true
Set-ADUser $SamAccountName -Add @{'proxyAddresses'=$UBTProxy}
Set-ADUser $SamAccountName -Add @{'proxyAddresses'=$MicrosoftProxy}
#!!!!!!!!!!!!!!!!Everything Here will interact with AD!!!!!!!!!!!!!!!!#>

#Move-ADObject -Identity $SAMAccountName -TargetPath $TargetOU --testing this functionality

write-host "Made Account with the following details:"
write-host @ADDetails
write-host "Password: " $Password
write-host "Proxy Addressess:" $UBTProxy $MicrosoftProxy
write-host "OU location: " $TargetOU

Remove-PSSession $DCAU