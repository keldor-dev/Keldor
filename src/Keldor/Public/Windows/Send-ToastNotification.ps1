#needs Get-NotificationApp
function Send-ToastNotification {
    <#
.SYNOPSIS
    Sends a Windows toast notification.

.DESCRIPTION
    Builds and displays a Windows toast notification locally or through PowerShell remoting. The notification can
    include sender and title text, a supported sound, and duration or dismissal behavior.

.PARAMETER Message
    Specifies the Message value.

.PARAMETER Sender
    Specifies the Sender value.

.PARAMETER ComputerName
    Specifies the name of one or more computers.

.PARAMETER Title
    Specifies the Title value.

.PARAMETER AudioSource
    Specifies the Audio Source value.

.PARAMETER ShortDuration
    Specifies whether to enable the Short Duration option.

.PARAMETER RequireDismiss
    Specifies whether to enable the Require Dismiss option.

.EXAMPLE
    Send-ToastNotification -Message 'Maintenance begins in 15 minutes.' -Title 'Maintenance'

    Displays a local toast notification with a title and message.

.EXAMPLE
    Send-ToastNotification -Message 'Restart required.' -ComputerName 'SERVER01' -RequireDismiss

    Sends a dismissible notification to SERVER01 through PowerShell remoting.

.OUTPUTS
    None

.LINK
    https://docs.keldor.dev/powershell/keldor/Send-ToastNotification
#>

    [CmdletBinding(HelpUri = 'https://docs.keldor.dev/powershell/keldor/Send-ToastNotification')]
    param(
        [Parameter(
            HelpMessage = "Enter the message to send.",
            Mandatory = $true,
            Position = 0
        )]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        [Parameter(
            HelpMessage = "Enter the name of the sender.",
            Mandatory = $false,
            Position = 1
        )]
        [string]$Sender = " ",

        [Parameter(
            Mandatory = $false,
            Position = 2
        )]
        [Alias('Host', 'Name', 'Computer', 'CN')]
        [string[]]$ComputerName,

        [Parameter(
            Mandatory = $false
        )]
        [string]$Title,

        [Parameter(Mandatory = $false)]
        [ValidateSet('ms-winsoundevent:Notification.Default',
            'ms-winsoundevent:Notification.IM',
            'ms-winsoundevent:Notification.Mail',
            'ms-winsoundevent:Notification.Reminder',
            'ms-winsoundevent:Notification.SMS',
            'ms-winsoundevent:Notification.Looping.Alarm',
            'ms-winsoundevent:Notification.Looping.Alarm2',
            'ms-winsoundevent:Notification.Looping.Alarm3',
            'ms-winsoundevent:Notification.Looping.Alarm4',
            'ms-winsoundevent:Notification.Looping.Alarm5',
            'ms-winsoundevent:Notification.Looping.Alarm6',
            'ms-winsoundevent:Notification.Looping.Alarm7',
            'ms-winsoundevent:Notification.Looping.Alarm8',
            'ms-winsoundevent:Notification.Looping.Alarm9',
            'ms-winsoundevent:Notification.Looping.Alarm10',
            'ms-winsoundevent:Notification.Looping.Call',
            'ms-winsoundevent:Notification.Looping.Call2',
            'ms-winsoundevent:Notification.Looping.Call3',
            'ms-winsoundevent:Notification.Looping.Call4',
            'ms-winsoundevent:Notification.Looping.Call5',
            'ms-winsoundevent:Notification.Looping.Call6',
            'ms-winsoundevent:Notification.Looping.Call7',
            'ms-winsoundevent:Notification.Looping.Call8',
            'ms-winsoundevent:Notification.Looping.Call9',
            'ms-winsoundevent:Notification.Looping.Call10',
            'Silent')]
        [string]$AudioSource = 'ms-winsoundevent:Notification.Looping.Alarm3',

        [Parameter()]
        [switch]$ShortDuration,

        [Parameter()]
        [switch]$RequireDismiss #overrides ShortDuration
    )
    dynamicparam {
        # Set the dynamic parameters' name. You probably want to change this.
        $ParameterName = 'Notifier'

        # Create the dictionary
        $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

        # Create the collection of attributes
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]

        # Create and set the parameters' attributes. You may also want to change these.
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute.Mandatory = $false
        $ParameterAttribute.Position = 3

        # Add the attributes to the attributes collection
        $AttributeCollection.Add($ParameterAttribute)

        # Generate and set the ValidateSet. You definitely want to change this. This part populates your set.
        $arrSet = ((Get-NotificationApp).Name)
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)

        # Add the ValidateSet to the attributes collection
        $AttributeCollection.Add($ValidateSetAttribute)

        # Create and return the dynamic parameter
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
        return $RuntimeParameterDictionary
    }
    begin {
        $Notifier = $PsBoundParameters[$ParameterName]
        if ([string]::IsNullOrWhiteSpace($Notifier)) { $Notifier = "Windows.SystemToast.NfpAppAcquire" }
        if ([string]::IsNullOrWhiteSpace($Title)) {
            $ttext = $null
        } else {
            $ttext = "<text>$Title</text>"
        }

        if ($AudioSource -eq 'Silent') {
            $atext = '<audio silent="true"/>'
        } else {
            $atext = '<audio src="' + $AudioSource + '"/>'
        }
        if ($RequireDismiss) {
            $scenario = '<toast scenario="reminder">'
            $actions = @"
        <actions>
            <action arguments="dismiss" content="Dismiss" activationType="system"/>
        </actions>
"@
        } else {
            if ($ShortDuration) { $dur = "short" }
            else { $dur = "long" }
            $scenario = '<toast duration="' + $dur + '">'
            $actions = $null
        }

        [xml]$ToastTemplate = @"
            $scenario
                <visual>
                <binding template="ToastGeneric">
                    <text>$Sender</text>
                    $ttext
                    <group>
                        <subgroup>
                            <text hint-style="subtitle" hint-wrap="true">$Message</text>
                        </subgroup>
                    </group>
                </binding>
                </visual>
                $actions
                $atext
            </toast>
"@

        [scriptblock]$ToastScript = {
            param($ToastTemplate)
            #Load required assemblies
            [void][Windows.UI.Notifications.ToastNotification, Windows.UI.Notifications, ContentType = WindowsRuntime]
            [void][Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom, ContentType = WindowsRuntime]

            #Format XML
            $FinalXML = [Windows.Data.Xml.Dom.XmlDocument]::new()
            $FinalXML.LoadXml($ToastTemplate.OuterXml)

            #Create the Toast
            $Toast = [Windows.UI.Notifications.ToastNotification]::new($FinalXML)

            #Show the Toast message
            [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($Notifier).show($Toast)
        }
    }
    process {
        if (![string]::IsNullOrEmpty($ComputerName)) {
            Invoke-Command -ComputerName $ComputerName -ScriptBlock $ToastScript -ArgumentList $ToastTemplate #DevSkim: ignore DS104456
        } else { Invoke-Command -ScriptBlock $ToastScript -ArgumentList $ToastTemplate } #DevSkim: ignore DS104456
    }
    end {
        #done
    }
}
