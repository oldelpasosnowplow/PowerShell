# Script Created by Oldelpasosnowplow 
# On Tuesday, November 4th, 2018
# This is completely open to any and all that want to use it
# The following script was created because I needed a fast way to change a users manager 
# in Active Directory when there is turn over in that position.

$OldManager = 'OldManagerGoesHere'
$NewManager = 'NewManagerGoesHere'

Get-Aduser $OldManager -Properties directReports | 
    Select-Object -ExpandProperty directreports | 
    Set-ADUser -Manager $NewManager
