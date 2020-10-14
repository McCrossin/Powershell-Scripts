[CmdletBinding()]
param (
    [Parameter()]
    [string] 
    $ExcelLocation = (Read-Host -Prompt 'Excel File Location I.E- C:\temp\my_test.xlsx')
)
Connect-MsolService

#Variables for MFA
$st = New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationRequirement
$st.RelyingParty = "*"
$st.State = "Enabled"
$sta = @($st)


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

   Set-MsolUser -UserPrincipalName $Email -StrongAuthenticationRequirements $sta
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