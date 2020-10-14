[CmdletBinding()]
param (
    [Parameter(
        Position = 0)
    ]
    [PSCredential]
    # Put in AD credentials
    $0365Creds = (Get-Credential -Message "Please input 0365 Admin Credentials") ,
    [Parameter(
        Position = 1)
    ]
    [String]
    $CSVPath = (get-CSV)
)

Connect-MsolService -Credential $0365Creds

import-csv -Path $CSVPath | forEach{
    
    $UPN = $_.Email

    $Users = Get-MsolUser -UserPrincipalName $UPN

    $Groupid = Get-MsolGroup -ObjectId "c353974a-b10c-49bb-9869-1d965e6727fc"

    Write-Output ("Adding " + $UPN + " to the group")

    $Users | ForEach {
        Add-MsolGroupMember -GroupObjectId $Groupid.ObjectId -GroupMemberType User -GroupMemberObjectId $Users.ObjectId
    }
}