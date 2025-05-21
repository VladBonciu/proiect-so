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
	grep -s $1 Users.csv #To FIX
}

patrat(){
printf  "[]"
}
loading(){

for i in {1..12}
do
patrat
sleep 0.15
done
}
scrie_mare(){

toilet -f  mono9 "$1"

}

start_screen()
{
	login_option=$(whiptail --title "Database" \
	--menu "Select option: " 15 50 3 \
	 "1" "Login" \
	 "2" "Sign In" \
	 "3" "Exit" \
	 3>&1 1>&2 2>&3)
	if [ $login_option -eq 1 ] ; then
		id=$(whiptail --inputbox "Enter Username" 10 60 --title "Log In" 3>&1 1>&2 2>&3)

		found=$(search_for_user $id)
		echo $found

		if [[ $found -eq 0 ]] ; then
			whiptail --title "Log In" --msgbox "User not found in database." 7 0
			start_screen
		else
			password=$(whiptail --title "Log In" --passwordbox "Enter password:" 10 60 3>&1 1>&2 2>&3)
			clear
			encrypted_pass=$(echo "$password" | sha256sum | sed 's/\s.*//g')
		fi

	elif [ $login_option -eq 2 ] ; then
		email=$(whiptail --title "Sign In 0/4 Completed" --inputbox "Email:" 10 50 3>&1 1>&2 2>&3)
		username=$(whiptail --title "Sign In 1/4 Completed" --inputbox "Username: " 10 50 3>&1 1>&2 2>&3)
		password=$(whiptail --title "Sign in 2/4 Completed" --passwordbox "Password: " 10 50 3>&1 1>&2 2>&3)
		password2=$(whiptail --title "Sign In 3/4 Completed" --passwordbox "Confirm password: " 10 50 3>&1 1>&2 2>&3)

		clear

		if [ "$password" = "$password2" ] ; then
			#do sign up logic
			sleep 2
			printf "While you wait, here is the word of the day"

			encrypted_pass=$(echo "$password" | sha256sum | sed 's/\s.*//g')

			create_user $username $email $encrypted_pass
			clear
			scrie_mare "Account created!"
#59
		else
			show_ui "Passwords don't match! Press [1] to retry."
			sleep 1
			start_screen
			fi

	elif [ $login_option -eq 3 ] ; then
		scrie_mare "Exiting"
		loading
   	 	exit 0

	else
		show_ui "Please select a valid option: log in [0] / sign up [1]"
		start_screen
	fi
}

clear
start_screen

