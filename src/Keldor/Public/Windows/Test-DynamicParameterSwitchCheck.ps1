function Test-DynamicParameterSwitchCheck {
    <#
.SYNOPSIS
    Non-functional. For reference.

.DESCRIPTION
    Shows how to create a function with dynamic parameters (Add and Modify) that only appear if the username parameter is populated and the Enable switch is added.

.PARAMETER UserName
    Specifies the User Name value.

.PARAMETER Enable
    Specifies whether to enable the Enable option.

.EXAMPLE
    Test-DynamicParameterSwitchCheck
    Runs Test-DynamicParameterSwitchCheck.

.OUTPUTS
    System.Object

.LINK
    https://docs.keldor.dev/powershell/keldor/Test-DynamicParameterSwitchCheck
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Test-DynamicParameterSwitchCheck')]
    param (
        [Parameter(Mandatory = $false)]
        [Alias('EDIPI', 'DisplayName')]
        [string[]]$UserName,

        [Parameter(Mandatory = $false)]
        [switch]$Enable

    )
    dynamicparam {
        if (![string]::IsNullOrWhiteSpace($Username) -and $Enable -eq $true) {
            #Parameter
            $parameterAttribute = [System.Management.Automation.ParameterAttribute]@{
                ParameterSetName = "AddingMembers"
                Mandatory        = $false
            }

            $attributeCollection = [System.Collections.ObjectModel.Collection[System.Attribute]]::new()
            $attributeCollection.Add($parameterAttribute)

            $dynParam1 = [System.Management.Automation.RuntimeDefinedParameter]::new(
                'Add', [switch], $attributeCollection
            )

            $paramDictionary = [System.Management.Automation.RuntimeDefinedParameterDictionary]::new()
            $paramDictionary.Add('Add', $dynParam1)

            #Parameter2
            $parameterAttribute2 = [System.Management.Automation.ParameterAttribute]@{
                ParameterSetName = "ModifyingMembers"
                Mandatory        = $false
            }

            $attributeCollection2 = [System.Collections.ObjectModel.Collection[System.Attribute]]::new()
            $attributeCollection2.Add($parameterAttribute2)

            $dynParam2 = [System.Management.Automation.RuntimeDefinedParameter]::new(
                'Modify', [switch], $attributeCollection2
            )

            $paramDictionary.Add('Modify', $dynParam2)
            return $paramDictionary
        }
    }#dynamic
    process {
        $PSBoundParameters['Add'].IsPresent
    }
}
