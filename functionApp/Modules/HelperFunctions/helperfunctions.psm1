function ConvertTo-Key {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [String]$value,

        [Parameter(Mandatory = $true)]
        [String]$KeySet,

        [Parameter(Mandatory = $true)]
        [Int]$subKey
    )

    $offSet = $KeySet -replace "[a-zA-Z -]"
    $keyValue = $offSet.Substring($subKey, 1)

    try {
        $key = [System.Text.Encoding]::Unicode.GetBytes(($KeySet.Substring($keyValue, 16)))
        $SecureString = $value | ConvertTo-SecureString -key $key

        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)
        $secretName = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

        return $SecureString

    }
    catch {
        Throw $_
    }
}

function Get-Prefix {
    [CmdletBinding()]
    [OutputType([string])]

    param(
        [Parameter(Mandatory = $true)]
        [String]$ProcessId,

        [Parameter(Mandatory = $true)]
        [String]$value

    )

    $keyVaultName = "$env:keyVaultName"
    $offSet = $ProcessId -replace "[a-zA-Z -]"

    $secValue = ConvertTo-Key -value $value -KeySet $ProcessId -subKey 0
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secValue)
    $_prefix = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
    return $_prefix
}

Export-ModuleMember -Function "ConvertTo-Key", "Get-Prefix"
