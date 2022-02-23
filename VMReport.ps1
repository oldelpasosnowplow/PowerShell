# Script Created by Oldelpasosnowplow 
# On Tuesday, July 14th, 2018 
# This is completely open to any and all that want to use it
# The following script was created because I wanted a quick way to see notes, server counts and host hardware usage on my vCenter server.
# Enjoy and I hope this helps others

Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
#Enter your vm credentials here
$vmcredentials = "root@localos"
#Enter your vCenter server name here
$vmvcentername = "vCenterServer"
#Enter where you want the report to be stored
$reportpath = "C:\temp\vmreport.html"

$cred = Get-Credential $vmcredentials
Connect-VIServer $vmvcentername -cred $cred

$vms = Get-VM -Name *

$vms | ConvertTo-Html -Title "$vmvcentername Report" -PreContent "<H1> $vmvcentername Report</H1>" -Property Name, Notes, PowerState, Guest, NumCpu, CoresPerSocket, MemoryGB, VMHost, HardwareVersion  | Out-File $reportpath

Start-Process $reportpath
