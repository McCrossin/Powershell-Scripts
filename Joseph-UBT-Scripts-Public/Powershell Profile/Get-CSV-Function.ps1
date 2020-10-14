function Get-CSV {

    Add-Type -AssemblyName System.Windows.Forms

    
    $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ 
        InitialDirectory = [Environment]::GetFolderPath('Desktop') 
        Filter = 'Text Files (*.csv)|*.csv'
    }

    $null = $FileBrowser.ShowDialog()

    return ($FileBrowser.FileName)
}