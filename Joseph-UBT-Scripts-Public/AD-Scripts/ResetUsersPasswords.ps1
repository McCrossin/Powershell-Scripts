[CmdletBinding()]
param (
    [Parameter(
        Position = 0)
    ]
    [String]
    $CSVPath = (get-CSV)
)

$CSV = Import-Csv -Path $CSVPath
  
$report = New-Object psobject

$csv | ForEach-Object {
    $Name = $_.Name
    $Password = New-PassPhrase
    $secure = ConvertTo-SecureString $Password -AsPlainText -Force


    
    $report | Add-Member -MemberType NoteProperty -Name Name -Value $Name -Force
    $report | Add-Member -MemberType NoteProperty -Name Password -Value $Password -Force

    $report | export-csv -path "C:\temp\passwords.csv" -NoTypeInformation -Append

}