[CmdletBinding()]
param (
    [Parameter(
        Position = 0)
    ]
    [PSCredential]
    # Put in AD credentials
    $O365Creds = (Get-Credential -Message "Please input Office365 Admin Credentials") ,
    [Parameter(
        Position = 1)
    ]
    [String]
    $CSVPath = (get-CSV)
)

Connect-MsolService -Credential $O365Creds

#Excel Variables
$excel = New-Object -ComObject Excel.Application
$wb = $excel.Workbooks.Open($ExcelLocation)
$sheet = $wb.sheets.item("Sheet1")
$column = 1

for ($i = 1; $i -lt 9999; $i++)
{
   $Email = $sheet.Cells.Item($i, $column).Value2

   if( $Email -eq $null){
        Write-Output "Closing Script"
        $excel.Workbooks.Close()
        pause
        break
   }

   Get-msolUser -UserPrincipalName $Email | 
    select DisplayName,UserPrincipalName,@{N="MFA Status"; 
    E={ 
        if( $_.StrongAuthenticationRequirements.State -ne $null){ 
            $_.StrongAuthenticationRequirements.State
        }else { 
            "Disabled"
        }
      }
    }
}
$excel.Workbooks.Close()