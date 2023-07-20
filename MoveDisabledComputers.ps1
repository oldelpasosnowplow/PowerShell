$s = New-PSSession -ComputerName "YourARSServerGoesHere" -UseSSL -Credential (get-credential)
$SearchOU = "Your OU you want to search here example OU=Computers,DC=domain,DC=local"
$DisabledCompOU = "OU where you keep your disabled objects example: OU=Computers,OU=DisabledObjects,DC=domain,DC=local"

# Store Return value of Invoke-Command to $status to display computers that were moved
$status = Invoke-Command -Session $s -ScriptBlock {
    $startOu = $Args[0]
    $disOU = $Args[1]
    $disComp = get-qadcomputer -proxy -IncludedProperties edsaAccountIsDisabled -SearchRoot $startOU -SizeLimit 0 | where {($_.edsaAccountisDisabled -eq $true)}
    
    foreach($comp in $disComp)
    {
       move-qadobject -proxy -Identity $comp.name -NewParentContainer $disOU
       $value += $comp.name + " was moved. `r`n"
        
    }
    return $value
} -ArgumentList $SearchOU, $DisabledCompOU

#Display computers that were moved
Write-Host $status

#Close PS Session
Remove-PSSession -Session $s