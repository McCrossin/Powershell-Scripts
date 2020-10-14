function Create-CORPADUser {

    $CSVCheck = (Read-Host -Prompt "Do you have the needed CSV File? yes/no")

    if (($CSVCheck -ne "yes") -and ($CSVCheck -ne "y")){

        Write-Host "Generating template for you"
        $objTemplate = New-Object PSObject
        $objTemplate | Add-Member -MemberType NoteProperty -Name Name -Value "John Smith"
        $objTemplate | Add-Member -MemberType NoteProperty -Name Entity -Value "UBT"
        $objTemplate | Add-Member -MemberType NoteProperty -Name Department -Value "IT"
        $objTemplate | Add-Member -MemberType NoteProperty -Name Manager -Value "John Smith"
        $objTemplate | Add-Member -MemberType NoteProperty -Name Position -Value "Clerk"
        $objTemplate | Add-Member -MemberType NoteProperty -Name TemplateAccount -Value "TemplateUserSamAccountName"
        $objTemplate | Add-Member -MemberType NoteProperty -Name Location -Value "The Precinct"
        $objTemplate | Add-Member -MemberType NoteProperty -Name HideInHive -Value "True"
        $objTemplate | Add-Member -MemberType NoteProperty -Name Country -Value "Australia"

        $objTemplate | export-csv -Path (Save-CSVFile)
        
        return

    }

    Write-Host ("Please input your CSV containing users to add & information needed.")
    $CSVPath = (Get-CSV)
    $CSV = Import-Csv -Path $CSVPath

    $CSVSave = (Read-Host -Prompt "Do you want to export your results to a CSV?")
    $SaveToCSV = $false

    if (($CSVSave -eq "yes") -or ($CSVSave -eq "y")){
        Write-Output ("Please Specify Locaiton to save CSV")
        $CSVSavePath = Save-CSVFile
        $SaveToCSV = $true
    }

    $DCName = (read-host -prompt "Please input Domain Controller Hostname")
    $0AccountCreds = (Get-Credential -Message "Please input Domain Admin Credentials")

    try {
        $DC = New-PSSession -ComputerName $DCName -Credential $0AccountCreds
        Import-Module -PSSession $DC -Name ActiveDirectory
    }catch{
        write-host ("Ran into Error when connecting with following details: `nDC Hostname: " + $DCName + "`nUsing account: " + $0AccountCreds.UserName) 
        return
    }

    $CSV | ForEach-Object {
        
        $Name = $_.Name
        $Entity = $_.Entity
        $Department = $_.Department
        $Manager = $_.Manager
        $Position = $_.Position
        $TemplateAccount = $_.TemplateAccount
        $Location = $_.Location
        $HideInHive = $_.HideInHive
        $Country = $_.Country

        if ($Entity -eq "UBTA"){
        $Domain = "@ubtaccountants.com"
        }elseif ($Entity -eq "RRT"){
            $Domain = "@rrtglobal.org"
        }elseif ($Entity -eq "Co Shield"){
            $Domain = "@coshield.com"
        }elseif ($Entity -eq "CoShield"){
            $Domain = "@coshield.com"
        }elseif ($Entity -eq "UBT"){
            $Domain = "@ubteam.com"
        }else{
            $Domain = (read-host -Prompt "Please input domain, e.g. @ubteam.com: ")
        }
         
        try {
           $CopyUser = Get-ADUser $TemplateAccount -Properties *
        }
        catch {
            Write-Output ("Template User is invalid")
            return
        }


        $TargetGroups = $CopyUser.MemberOf
        $TargetOU = $CopyUser.DistinguishedName -replace "CN=$($CopyUser.Name)," , ""

        if($Location -eq "Sydney Precinct"){
            $City = "Sydney"
            $State = "NSW"
            $Street = "10 Herb Elliott Ave, Sydney Olympic Park"
            $Postal = "2127"
        }else{
            $Street = $Location
        }

        #This will make SAMAccountName
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

        $Count = ""
        $loop = 0
        $SAMAccountName = "$Firstname" + ".$Surname"

        try {
            while ($true){
             Write-Output ("Checking: " + $SAMAccountName)
             $test = Get-ADUser $SamAccountName -ErrorAction Stop
             Write-Output ($SAMAccountName + " already exists.")
             $loop += 1
             $Count = $loop
             $SAMAccountName = "$Firstname" + ".$Surname" + $Count
            }
        }
        catch {
            $SAMAccountName = "$Firstname" + ".$Surname" + $Count
            Write-Output ("SAMAccountName is: " + $SAMAccountName)
        }

        $UBTProxy = "SMTP:" + $EmailAddress
        $MicrosoftProxy = "smtp:" + $SAMAccountName + "@UBT365.onmicrosoft.com"

        $password = New-PassPhrase

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
            Country = $Country
            Company = $Entity
            StreetAddress = $Street
            PostalCode = $Postal
            City = $City
            State = $State
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
        
        try {
           $test = Get-ADUser $Manager
           Set-ADUser -Manager $Manager
        }
        catch {
            Write-Output ("Manager is invalid")
        }

        write-host "Made Account with the following details:"
        write-host @ADDetails
        write-host "Password: " $Password
        write-host "Proxy Addressess:" $UBTProxy $MicrosoftProxy
        write-host "OU location: " $TargetOU

        if ($SaveToCSV){
            $objUser = New-Object PSObject
            $objUser | Add-Member -MemberType NoteProperty -Name Name -Value $Name
            $objUser | Add-Member -MemberType NoteProperty -Name SAMAccountName -Value $SAMAccountName
            $objUser | Add-Member -MemberType NoteProperty -Name Password -Value $Password
            $objUser | Add-Member -MemberType NoteProperty -Name OU -Value $TargetOU
        }

    }

}