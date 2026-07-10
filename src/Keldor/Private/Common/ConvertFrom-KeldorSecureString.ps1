function ConvertFrom-KeldorSecureString {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [System.Security.SecureString]$SecureString
    )

    $Bstr = [IntPtr]::Zero

    try {
        $Bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)
        [Runtime.InteropServices.Marshal]::PtrToStringBSTR($Bstr)
    }
    finally {
        if ($Bstr -ne [IntPtr]::Zero) {
            [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($Bstr)
        }
    }
}
