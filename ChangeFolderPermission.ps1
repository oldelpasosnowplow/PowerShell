# Script Created by Oldelpasosnowplow 
# On Tuesday, February 22nd, 2022
# This is completely open to any and all that want to use it
# The following script was created because I needed a way to modify folder permissions after an installation
# Using PDQ I deployed the installation package and after it was installed 
# I needed to add users to be able to have modify rights so configuration files would be updated as well as 
# updates pushed down from the server could be applied without the need for admin rights
# This could be used as a standalone script or part of a deployment.

#The user or group you want to give permission to.
$accountname = "User or Group here"
#The folder you want to change the permissions on.
$folderpath = "Folder Path goes here"
#Get the security descriptor of the folder
$acl = Get-Acl $folderpath
#Create a new access rule - This one will add the modify rights to the $accountname and pass the inheritance to the children.
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($accountname, "Modify", "ContainerInherit, ObjectInherit", "None", "Allow")
#Set the rule on the folder path
$acl.SetAccessRule($accessRule)
#Apply rule to the folder
$acl | Set-Acl $folderpath