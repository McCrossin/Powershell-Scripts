function New-PassPhrase {
    <#
    .SYNOPSIS
    Generate PassPhrase for account logins
    .DESCRIPTION
    Generate a PassPhrase from a pre-defined list of words instead of using random character passwords
    Inspiration https://millerb.co.uk/2018/08/18/Generating-Passphrases-Instead-Of-Passwords.html
    Inspiration https://github.com/RickFlist/PoSh/blob/master/Modules/MTL-PasswordGenerator/MTL-PasswordGenerator.psm1
    .PARAMETER MinLength
    Length of PassPhrase to be generated
    .PARAMETER Delimiter
    The Delimiter to be used when outputting the PassPhrase. If no delimiter is specified then a hyphen is used '-'
    .Parameter PhraseFile
    Path to a phrase file to use for the generation of passwords
    .EXAMPLE
    New-PassPhrase -MinLength 25
    .EXAMPLE
    New-PassPhrase -MinLength 25 -Delimiter ';'
    .NOTES
    NCSC UK Guidance on Secure Passwords
    https://www.ncsc.gov.uk/guidance/password-guidance-simplifying-your-approach
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 1)]
        [int] $MinLength=15,

        [Parameter(Position = 2)]
        [char[]] $Delimiter = '',

        [Parameter(Position = 3)]
        [string]$PhraseFile = [Environment]::GetFolderPath("MyDocuments") +"\WindowsPowerShell\RandomPassword.txt"
    )

    begin {
        if (Test-Path $PhraseFile) {
            $wordlist = ([String[]]@(Get-Content -Path $PhraseFile))
        } else {
            Write-Error "Phrase file count not be found"
            exit
        }
    }

    process {
        $phrasearr = @()
        while ($phrase.length -lt ($MinLength)) {
            $phrasearr += $wordlist | Get-Random
            $phrase = $phrasearr -join $Delimiter
        }

        $phrasearr += (Get-Random -Minimum 0 -Maximum 10)
        $phrase = $phrasearr
    }

    end {
        $phrasearr -join $Delimiter
    }
}