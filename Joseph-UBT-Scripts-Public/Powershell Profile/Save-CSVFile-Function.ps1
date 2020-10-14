Function Save-CSVFile ([string]$initialDirectory) {

	$SaveInitialPath = "C:\"
	$SaveFileName = "NewCSV.csv"

    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    
    $OpenFileDialog = New-Object System.Windows.Forms.SaveFileDialog
    $OpenFileDialog.initialDirectory = $SaveInitialPath
    $OpenFileDialog.filter = "CSV (*.csv)| *.csv"
	$OpenFileDialog.FileName = $SaveFileName
    $OpenFileDialog.ShowDialog() | Out-Null

    return $OpenFileDialog.filename

}