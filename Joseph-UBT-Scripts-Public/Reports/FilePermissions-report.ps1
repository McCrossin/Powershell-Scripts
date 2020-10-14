#Set your CSV Paths
$csvImportPath = Get-CSV
$csvExportPath = Save-CSVFile

$csv = import-csv $csvImportPath
$counter = 0

$CSV | ForEach-Object {
    $Path = $_.Path

    $Permissions = (Get-Acl -Path $Path).Access | ForEach-Object { $_ | Add-Member -MemberType NoteProperty -Name Path -Value $Path -PassThru }

    if ($counter -eq 0){
        $Permissions | Export-Csv -Path $csvExportPath
        $counter += 1
    }else{
        $Permissions | Export-Csv -Path $csvExportPath -Append
    }
}