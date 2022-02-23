# Script Created by Oldelpasosnowplow 
# On Wednesday, February 23rd, 2022 @ 16:45 UTC
# This is completely open to any and all that want to use it, modify it to meet the needs of your network.
# This script will prompt for a user's AD SAM Account and employee clock number, set the clock number to the AD account.  
# Then created documents folder giving the user modify permissions and then prompting to remove any permissions
# given by inheritence if it isn't needed.
# Enjoy and I hope this helps others

# Received this function from https://jpearson.blog/2019/11/08/prompting-the-user-for-input-with-powershell/
# Thank you James
# Published Nov 8th, 2019
function Get-SelectionFromUser 
{
    param ([Parameter(Mandatory=$true)][string[]]$Options,[Parameter(Mandatory=$true)][string]$Prompt)
    
    [int]$Response = 0;
    [bool]$ValidResponse = $false    

    while (!($ValidResponse)) {            
        [int]$OptionNo = 0

        Write-Host $Prompt -ForegroundColor DarkYellow
        Write-Host "[0]: Cancel"

        foreach ($Option in $Options) {
            $OptionNo += 1
            Write-Host ("[$OptionNo]: {0}" -f $Option)
        }

        if ([Int]::TryParse((Read-Host), [ref]$Response)) {
            if ($Response -eq 0) {
                return ''
            }
            elseif($Response -le $OptionNo) {
                $ValidResponse = $true
            }
        }
    }

    return $Options.Get($Response - 1)
} 

# Loop through until valid AD account is found
$valid = $false
while (!($valid))
{
    $username = Read-Host -Prompt "Enter username (samAccountName)"
    

    # Find user and set EmployeeID
    try
    {
        $aduser = Get-ADUser -identity $username
        $valid = $true
    }
    catch
    {
        Write-Output "User Doesn't Exist"
    }
}

#Values to change to meet your needs
$domain = "yourdomainhere"
$basedirpath = "C:\Temp"

# Set Employee Clock Number
$employeeID = Read-Host -Prompt "Enter Employee Clock Number"
$aduser | Set-ADUser -EmployeeID $employeeID

# Create Documents Folder and set permissions
$dept = Get-SelectionFromUser -Options ('Accounting','Administration','Engineering','Human Resources','Information Systems') -Prompt 'Select Department Folder' #Add as many options as you like
$docPath = "$basedirpath\$dept\$username"

# If Directory exists exit the script
if (-not (Test-Path $docPath -PathType Container))
{
    New-Item -Path $docPath -ItemType Directory
}
else
{
    Write-Output "Directory Exists"
    Exit
}

# SET Modify permissions on the created directory for the user
$acl = Get-Acl $docPath
$acl.SetAccessRuleProtection($True, $True)
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("$domain\$username", "Modify", "ContainerInherit, ObjectInherit", "None", "Allow")
$acl.SetAccessRule($accessRule)
$acl | Set-Acl $docPath

# Loop through all the ACLs to find any inheritence that isn't needed on the directory
foreach($identity in $acl.Access)
{
    $idname = $identity.IdentityReference
    $in = Read-Host -Prompt "Do you want to remove this $idname (y/n)"

    if ($in -eq "y")
    {
        $dAcl = get-Acl $docPath
        $uID = New-Object System.Security.Principal.NTAccount($identity.IdentityReference)
        $dAcl.PurgeAccessRules($uID)
        Set-Acl -Path $docPath -AclObject $dACl
    }
}


