#!/bin/bash

show_ui()
{
	clear
	toilet -f mono9 "Database"
	printf "$1\n"
}

start_screen()
{
	read login_option
	if [ $login_option -eq 0 ] ; then
		show_ui "Log In"
		printf "Email / Username: "
		read id
		printf "Password: "
		read password
		clear

		#ecriptare parola
		echo $password > temp.txt #cream un fisier in care stocam parola pentru a utiliza sha256sum
		encrypted_pass=$(sha256sum temp.txt | sed 's/\s.*//g') #aplicam functia sha256sum si apoi sed pentru a elimina  '__temp.txt' de la final
		rm temp.txt

		echo $encrypted_pass

	elif [ $login_option -eq 1 ] ; then
		show_ui "Sign Up"
		printf "Email: "
		read email
		printf "Username: "
		read username
		printf "Password: "
		read password
		clear
	else
		show_ui "Please select a valid option: log in [0] / sign up [1]"
		start_screen
	fi
}

create_user()
{
	return
}

search_for_user()
{
	return
}

show_ui "Welcome! Time to log in [0] or sign up [1]."
start_screen

