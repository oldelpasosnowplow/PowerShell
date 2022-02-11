$OldManager = 'OldManagerGoesHere'
$NewManager = 'NewManagerGoesHere'

Get-Aduser $OldManager -Properties directReports | 
    Select-Object -ExpandProperty directreports | 
    Set-ADUser -Manager $NewManager