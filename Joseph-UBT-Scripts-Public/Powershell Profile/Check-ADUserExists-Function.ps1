function Check-ADUserExists{
    param (
        [Parameter(
            Position = 0)
        ]
        [string]$CSVPath = (Get-CSV)
    )
    try{
        $CSV = Import-Csv -Path $CSVPath
        $CSV | ForEach-Object {
            $Name = $_.Name
            $test = Get-ADUser $Name
            Write-Output ($Name + " exists in DC")
        }
    }catch{
        Write-Warning -Message ($Name + " Does not exist in DC")
    }
}