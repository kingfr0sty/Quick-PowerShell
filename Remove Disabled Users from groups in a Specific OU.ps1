# import AD module
Import-module ActiveDirectory
'''
This Script will remove users that are currently in the Disabled Users OU from any groups that they happen to be in and log the user in a terminated.csv file that is updated every iteration of the script
'''

# import CSV file, populate an array with users that have already been cleaned
Import-Csv C:\Scripts\TerminatedUsers.csv |
ForEach-Object {
	
	# $_.User because the header is User
 	$CompletedUser += $_.Users
}

# run through all users from DisabledAccounts
#replace DC=thisisadomain with real domain 
foreach ($username in (Get-ADUser -SearchBase "OU=DisabledAccounts,DC=thisisadomain,DC=org" -filter *)) {

# Check array for user and proceed if user doesn't exist
if ($CompletedUser -Match $username.name) {
	# Do nothing, the username has been cleaned
	}

Else{
	# Get all group memberships
	$groups = get-adprincipalgroupmembership $username;

	# Loop through each group
	foreach ($group in $groups) {

	    # Exclude Domain Users group
	    if ($group.name -ne "domain users") {
	
		# Remove user from group
	        remove-adgroupmember -Identity $group.name -Member $username.SamAccountName -Confirm:$false;
       
		# Write progress to screen
        	write-host "removed" $username "from" $group.name;

	        # Define and save group names into filename in C:\Logs\Users Removed From Groups\username.txt
        	$grouplogfile = "C:\Logs\UsersRemoved\" + $username.SamAccountName + ".txt";
	        $group.name >> $grouplogfile
	    }
	}
	
	# Once the user has been processed add to CSV file
	Add-Content C:\Scripts\TerminatedUsers.csv $username.name;
}
} 
