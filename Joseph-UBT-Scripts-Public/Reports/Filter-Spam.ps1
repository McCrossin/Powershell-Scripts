$CSVPath = Get-CSV
$CSV = Import-Csv -Path $CSVPath

$CSV |
    ForEach-Object{
        
        $Reason = $_.Reason

        if(($Reason -notcontains "Subject Content") -and ($Reason -notcontains "Body Content") -and ($Reason -notcontains "Barracuda Reputation")){
            $_ | Export-Csv -Path (Save-CSVFile) -Append
        }
    }