Get-ChildItem ([Environment]::GetFolderPath("MyDocuments") + "\WindowsPowerShell\*Function.ps1") | %{. $_ }
