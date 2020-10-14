#This is the search variable, include * for any before or after
$ADGroupSearch = ""

    $GroupName = $_.GroupName

    $ADGroupList = Get-ADGroup -Filter * | Where-Object{$_.Name -like "#Edit Here"} | Select Name -ExpandProperty Name | Sort 
    $filename = "Groups.csv"
    ForEach($Group in $ADGroupList) 
    {
        $a = "Group: $Group"
        $exportobject = New-Object psobject -Property @{Name = $a}
        Export-Csv -InputObject $exportobject -Path C:\Git\Joseph-UBT-Scripts-Company-Details\AD-Scripts\$filename -NoTypeInformation -Append
        $Group | Export-Csv -Path C:\Git\Joseph-UBT-Scripts-Company-Details\AD-Scripts\$filename -Append
        Get-ADGroupMember -Identity $Group | Select Name -ExpandProperty Name | Sort  | Export-Csv -Path C:\Git\Joseph-UBT-Scripts-Company-Details\AD-Scripts\$filename -Append
    
        Write-Host "Writing to CSV..." 

        if ((Get-ADGroupMember -Identity $Group) -eq $null){
            write-host "null"
            Get-ADGroup -Identity $Group | Select Name | export-csv -Path C:\Git\Joseph-UBT-Scripts-Company-Details\AD-Scripts\$filename -Append
        }
    }
    Write-Host "Complete"