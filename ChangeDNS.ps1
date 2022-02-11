# Script Created by Oldelpasosnowplow 
# On Tuesday, February 8th, 2022 @ 12:13 UTC
# This is completely open source to any and all that want to use it
# The following script was created because I needed a way to change DNS settings on statically set IP Address on my servers
# Using PDQ I was able to deploy this script across my network to the statically set IP Addresses and change them
# when we changed domain controllers to a different VLAN
# Enjoy and I hope this helps others

# Get all interfaces with a connected state
$NetworkInterfaces  = Get-NetIPInterface | Where-Object ConnectionState -EQ 'Connected'
$DNSServerAddresses = Get-DnsClientServerAddress
$OldDNSIPAddress = 'Old DNS Here' # Place the DNS IP Address you want to change here
$NewDNSIPAddress1 = 'New DNS Here 1' # Place the updated DNS IP Address here 
# I had a need to get a secondary DNS in my servers so they were uniform you can remove this and the reference below to fit your needs
$NewDNSIPAddress2 = 'New DNS Here 2' 

# Get all the interfaces and DNS Settings sorted by Metric
$Combined = $NetworkInterfaces | ForEach-Object {
  [PSCustomObject]@{
    'InterfaceAlias'  = $_.InterfaceAlias
    'InterfaceIndex'  = $_.InterfaceIndex
    'InterfaceMetric' = $_.InterfaceMetric
    'DNSIPv4'         = ($DNSServerAddresses | Where-Object InterfaceIndex -EQ $_.InterfaceIndex | Where-Object AddressFamily -EQ 2).ServerAddresses
  }
} | Sort-Object InterfaceMetric -Unique

# Loop through all the interfaces and find a match to your old DNS IP address and store it
foreach ($interface in $Combined) {
    if ( $interface.DNSIPv4 -like $OldDNSIPAddress+'*'){
        $int = $interface.InterfaceAlias      
        }
}

# if the results from above are not null then change the DNS Address on the interface that is matched to your old DNS
if ($int -ne $null) {
    Set-DNSClientServerAddress -InterfaceAlias $int -ServerAddresses ($NewDNSIPAddress1, $NewDNSIPAddress2)
}
