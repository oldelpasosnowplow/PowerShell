$s = New-PSSession -ComputerName "YourARSServerGoesHere" -UseSSL -Credential (get-credential)
$SearchOU = "Your OU you want to search here example OU=Users,DC=domain,DC=local"
$DisabledUserOU = "OU where you keep your disabled objects example: OU=Users,OU=DisabledObjects,DC=domain,DC=local"

# Store Return value of Invoke-Command to $status to display users that were moved
$status = Invoke-Command -Session $s -ScriptBlock {
    $startOu = $Args[0]
    $disOU = $Args[1]
    $depoUsers = get-qaduser -proxy -IncludedProperties edsvaDeprovisionStatus, edsaAccountIsDisabled, edsvaMITStatusChange, edsvaMITDeprovision_T30 -SearchRoot $startOU -SizeLimit 0 | where {($_.edsvaDeprovisionStatus -eq 1) -AND ($_.edsaAccountisDisabled -eq $true)}
   #Loop through each user that has been disabled and Deprovisioned and move them to Disabled User OU.
    foreach($user in $depoUsers)
    {
        move-qadobject -proxy -Identity $user.UserPrincipalName -NewParentContainer $disOU
        $value += $user.UserPrincipalName + " was moved. `r`n"
    }
    return $value
} -ArgumentList $SearchOU, $DisabledUserOU

#Display users that were moved
Write-Host $status

#Close PS Session
Remove-PSSession -Session $s