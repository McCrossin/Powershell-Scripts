#!!!!!!!!!!!!!!!!!!!!!CUSTOM FUNCTIONS START!!!!!!!!!!!!!!!!!!!!!

function Test-RegistryValue {

    param (

       [parameter(Mandatory=$true)]
       [ValidateNotNullOrEmpty()]$Path,

       [parameter(Mandatory=$true)]
       [ValidateNotNullOrEmpty()]$Value
    )

    try {

       Get-ItemProperty -Path $Path | Select-Object -ExpandProperty $Value -ErrorAction Stop | Out-Null
            return $true
        }

    catch {

       return $false

    }

}

#!!!!!!!!!!!!!!!!!!!!!CUSTOM FUNCTIONS END!!!!!!!!!!!!!!!!!!!!!

#!!!!!!!!!!!!!!!!!!!!!VARIABLES START!!!!!!!!!!!!!!!!!!!!!

#Booleans to check if the Folder and Registry Key Already exists.
$FolderExists = test-path -Path "C:\Windows\Lockscreen"
$RegPathExists = test-path -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\PersonalizationCSP"
$RegKeyExists = Test-RegistryValue -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\PersonalizationCSP" -Value "LockScreenImagePath"

#This is the URL to get the picture from, if the file type changes from ".jpg" You will need to change file type in LockscreenimageLocation
$url = "https://paueargworkloaddiag925.blob.core.windows.net/ubtosdintune/lockscreen.jpg?sp=rl&st=2020-01-31T02:28:22Z&se=2021-02-01T02:28:00Z&sv=2019-02-02&sr=b&sig=PL%2FSZHC95RZd8yx9YCrAggeb312pPjdCSDMFGaNOsU8%3D"
$LockScreenImageLocation = "C:\Windows\Lockscreen\Lockscreen.jpg"

#!!!!!!!!!!!!!!!!!!!!!VARIABLES END!!!!!!!!!!!!!!!!!!!!!

#!!!!!!!!!!!!!!!!!!!!!SCRIPT EXECUTION START!!!!!!!!!!!!!!!!!!!!!

#This will only create the folder if it does not already exist
if(!($FolderExists)){
    New-Item -ItemType "directory" -Name Lockscreen -Path "C:\Windows"
}

#This will download an image from a URL and put it in the C:\Windows\Lockscreen\ Folder
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($url, $LockScreenImageLocation)

#This is creating a Registry key to set the Lockscreen, This will only run if the Regsitry Key does not already exist.
if(!($RegPathExists)){
    New-Item –Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\" –Name PersonalizationCSP
}

#Create a new Registry Key if the key is not there, otherwise edit existing key
if($RegKeyExists){
    Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\PersonalizationCSP" -Name "LockScreenImagePath" -Value $LockScreenImageLocation
    Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\PersonalizationCSP" -Name "LockScreenImageUrl" -Value $LockScreenImageLocation
    Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\PersonalizationCSP" -Name "LockScreenImageStatus" -Value ”1”
}else{
    New-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\PersonalizationCSP" -Name "LockScreenImagePath" -Value $LockScreenImageLocation  -PropertyType "String"
    New-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\PersonalizationCSP" -Name "LockScreenImageUrl" -Value $LockScreenImageLocation  -PropertyType "String"
    New-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\PersonalizationCSP" -Name "LockScreenImageStatus" -Value ”1”  -PropertyType "Dword"
}

#!!!!!!!!!!!!!!!!!!!!!SCRIPT EXECUTION END!!!!!!!!!!!!!!!!!!!!!