#!/bin/bash

show_ui()
{
	clear
	toilet -f mono9 "Database"
	printf "$1\n"
}
create_user()
#10
{
        printf "$1, $2, $3\n" >> "Users.csv"
        echo "User adaugat"
}

search_for_user()
{
	grep -F $1 Users.csv 
}
#21
start_screen()
{
	read login_option
	if [ $login_option -eq 0 ] ; then
		show_ui "Log In"
		printf "Email / Username: "
		read id

		found=$(search_for_user $id)
		echo $found

		if [[ $found -eq 0 ]] ; then
			printf "Invalid Login Information"
			sleep 2
			show_ui "Please select a valid option: log in [0] / sign up [1]"
			start_screen
		else
			
			printf "Password: "
			read password
			clear
			encrypted_pass=$(echo "$password" | sha256sum | sed 's/\s.*//g')
		fi

	elif [ $login_option -eq 1 ] ; then
		show_ui "Sign Up"
		printf "Email: "
		read email
		printf "Username: "
		read username
		printf "Password: "
		read password
		printf "Reconfirm Password: "
		read password2
#49		
		clear

		if [ $password == $password2 ] ; then
			#do sign up logic
			printf "Setting up account...\n"
			sleep 1
			printf "While you wait, here is the word of the day"

			encrypted_pass=$(echo "$password" | sha256sum | sed 's/\s.*//g')

			create_user $username $email $encrypted_pass
			clear
			printf "Account created!"
#59
		else
			show_ui "Passwords don't match! Press [1] to retry."
			start_screen
		fi
	else
		show_ui "Please select a valid option: log in [0] / sign up [1]"
		start_screen
	fi
}

show_ui "Welcome! Time to log in [0] or sign up [1]."
start_screen

