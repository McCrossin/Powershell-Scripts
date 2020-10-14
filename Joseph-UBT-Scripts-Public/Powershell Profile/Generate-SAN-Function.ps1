function Generate-SAN {
    <#
    .SYNOPSIS
    Generate a SAM Account Name from "Firstname Lastname" CSV
    .DESCRIPTION
    This script will take a CSV of Full Names and generate a SAM account name varient.

    .PARAMETER CSVPath
    This is the location of the CSV to be used, Please make sure that this CSV has the header of Name
    .PARAMETER Output
    This will be the CSV with the SAM Account Names
    .EXAMPLE
    New-PassPhrase -CSVPath "C:\temp\Names.csv" -output "C:\temp\SANames.csv"
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 1)]
        [string]$CSVPath = (Get-CSV),

        [Parameter(Position = 2)]
        [string]$Output = (Save-CSVFile)
    )
    "Name" | Out-File -FilePath $Output -Append
    try {
        $CSV = Import-Csv -Path $CSVPath
        $CSV | ForEach-Object{
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

            $SAMAccountName | Out-File -FilePath $Output -Append
        }
    }catch{
        "An Error occured during script execution"
    }
}