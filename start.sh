#!/bin/bash

export NEWT_COLORS='
root=white,black
title=white,black
border=white,black
window=white,black
button=black,white
label=black,white
textbox=white,black
acttextbox=white,black
listbox=white,black
compactbutton=white,black
entry=black,white
'

show_ui()
{
	clear
	toilet -f mono9 "Database"
	printf "$1\n"
}

create_user()
{
        printf "$1, $2, $3\n" >> "Users.csv"
        echo "User adaugat"
}

search_for_user()
{
	grep -s $1 Users.csv
}

loading()
{

	for i in {1..20}
	do
		printf  "[]"
		sleep 0.15
	done
}

scrie_mare()
{
	toilet -f  mono9 "$1"
}

start_screen()
{
	login_option=$(whiptail --title "Database" \
	--menu "Select option: "  15 50 3 \
	 "1" "Login" \
	 "2" "Sign In" \
	 3>&1 1>&2 2>&3)
	exit_status=$?
	if [ $exit_status -eq 1 ] ; then
		toilet -f mono9 "Exiting"
		loading
		printf "\n"
		clear
		exit 0
	fi

	if [ $login_option -eq 1 ] ; then
		id=$(whiptail --inputbox "Enter Username" 10 60 --title "Log In" --nocancel 3>&1 1>&2 2>&3)

		found=$(search_for_user $id)
		#echo $found

		if [ -z "$found"] ; then
			whiptail --title "Log In" --msgbox "User not found in database." 7 0
			start_screen
		else
			password=$(whiptail --title "Log In" --passwordbox "Enter password:" --nocancel 10 60 3>&1 1>&2 2>&3)
			clear
			encrypted_pass=$(echo "$password" | sha256sum | sed 's/\s.*//g')
			doc_pass=$(echo $found | sed 's/.*,.//g')

			if [ $doc_pass = $encrypted_pass ] ; then
				whiptail --title "Log In" --msgbox "Welcome $id!" 7 0
				exit 0
			else
				whiptail --title "Log In" --msgbox "Incorrect password." 7 0
				start_screen
			fi
		fi

	elif [ $login_option -eq 2 ] ; then
		email=$(whiptail --title "Sign In 0/4 Completed" --inputbox "Email:" --nocancel 10 50 3>&1 1>&2 2>&3)
		username=$(whiptail --title "Sign In 1/4 Completed" --inputbox "Username: " --nocancel 10 50 3>&1 1>&2 2>&3)
		password=$(whiptail --title "Sign in 2/4 Completed" --passwordbox "Password: " --nocancel 10 50 3>&1 1>&2 2>&3)
		password2=$(whiptail --title "Sign In 3/4 Completed" --passwordbox "Confirm password: " --nocancel 10 50 3>&1 1>&2 2>&3)

		clear

		if [ "$password" = "$password2" ] ; then
			#TODO sign up logic
			encrypted_pass=$(echo "$password" | sha256sum | sed 's/\s.*//g')

			create_user $username $email $encrypted_pass

			whiptail --title "Sign Up" --msgbox "Account Created!" 7 0
			clear
			#scrie_mare "Account created!"
		else
			whiptail --title "Sign Up" --msgbox "Passwords don't match." 7 0
			start_screen
		fi
	fi
}

clear
start_screen

