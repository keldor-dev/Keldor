function Get-UserWithThumbnail {
<#
.SYNOPSIS
    Gets User With Thumbnail.

.DESCRIPTION
    Gets User With Thumbnail.

.EXAMPLE
    Get-UserWithThumbnail
    Runs Get-UserWithThumbnail.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Get-UserWithThumbnail
#>

        [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Get-UserWithThumbnail')]
    Param ()
if (Get-Module -ListAvailable -Name ActiveDirectory) {
        Write-Output "Getting OU names . . ."
        $ous = (Get-ADOrganizationalUnit -Filter 'Name -like "*"' | Select-Object DistinguishedName).DistinguishedName

        Write-Output "Getting Users . . ."
        $users = foreach ($ouname in $ous) {
            Get-ADUser -Filter * -Properties thumbnailPhoto -SearchBase "$ouname" -SearchScope OneLevel | Where-Object {!([string]::IsNullOrWhiteSpace($_.thumbnailPhoto))} | Select-Object Name,UserPrincipalName,thumbnailPhoto
        }

        $users | Select-Object Name,UserPrincipalName,thumbnailPhoto
    }
    else {
        Write-Warning "Active Directory module is not installed and is required to run this command."
    }
}
