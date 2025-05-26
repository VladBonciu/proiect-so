#!/bin/bash

theme_variants=(\
'root=white,black
title=white,black
border=white,black
window=white,black
button=black,white
label=black,white
textbox=white,black
acttextbox=white,black
listbox=white,black
compactbutton=white,black
entry=black,white' \
'root=black,gray
title=black,gray
border=black,gray
window=black,gray
button=white,gray
label=white,gray
textbox=white,black
acttextbox=black,white
listbox=black,white
compactbutton=black,white
entry=white,black' \
'root=green,magenta
title=red,brown
border=pink,gray
window=red,brown
button=blue,yellow
label=white,blue
textbox=red,gray
acttextbox=blue,gray
listbox=red,green
compactbutton=blue,white
entry=white,red')
export NEWT_COLORS=${theme_variants[0]}

show_ui()
{
	clear
	toilet -f mono9 "Database"
	printf "$1\n"
}

create_user()
{
        uid=$(cat Users.csv | wc -l)
        printf "$uid, $4, $1, $2, $3\n" >> "Users.csv"
	echo "User adaugat"
}

search_for_user()
{
	grep -s -w $1 Users.csv | sed 's/.*\n//g'
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
	toilet -f mono9 "$1"
}

start_screen()
{
	cd $initial_dir
	login_option=$(whiptail --title "Database" \
	--menu "Select option: " --cancel-button "Exit" --notags 15 50 3 \
	 "1" " Log In" \
	 "2" " Sign In " \
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
		unset id
		id=$(whiptail --inputbox "Enter Username " 10 60 --title "Log In" --nocancel 3>&1 1>&2 2>&3)

		found=$(search_for_user $id)
		is=$(echo "$found" | cut -d "," -f2)
		if [ -z "$found" ] || [ $is -eq 0 ]; then
			whiptail --title "Log In" --msgbox "User not found in database." 7 0
			start_screen
		elif grep -q "^$id$" "$active_users_file"; then
			whiptail --title "ERROR" --msgbox "User active on another device" 30 60
                        start_screen
		else
			password=$(whiptail --title "Log In" --passwordbox "Enter password:" --nocancel 10 60 3>&1 1>&2 2>&3)
			clear
			encrypted_pass=$(echo "$password" | sha256sum | sed 's/\s.*//g')
			doc_pass=$(echo $found | sed 's/.*,.//g')

			if [ $doc_pass = $encrypted_pass ] ; then
				whiptail --title "Log In" --msgbox "Welcome $id!" 7 0
				emaill=$(grep -w $id Users.csv | grep -o '[^[:space:]]*@[^[:,:]]*')
				ident=$(grep -w $id Users.csv | sed 's/,.*//g')
				cd folders/Home-$ident
				time=$(date +"%Y-%m-%d %H:%M:%S")
				echo "Logged in: $time " >> ".jrn-$ident"
				cd ../..
				echo "$id logged in: $time " >> "admin-jrn.txt"
				cd folders/Home-$ident
				#if ! grep -q "^$id$" "$active_users_file"; then
    					echo "$id" >> "$active_users_file"
				#fi
				home
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
		emaill=$email
		clear

		if [ "$password" = "$password2" ] ; then
			#TODO sign up logic
			encrypted_pass=$(echo "$password" | sha256sum | sed 's/\s.*//g')
			is=1
			create_user $username $email $encrypted_pass $is

			ident=$(grep -w $username Users.csv | sed 's/,.*//g')

                        cd folders
                        mkdir "Home-$ident"
			cd "Home-$ident"
			touch ".jrn-$ident"
			cd ../..

                        loading
                        clear

                        whiptail --title "Sign Up" --msgbox "Account Created! Your user id is: $ident" 7 0
			start_screen
		else
			whiptail --title "Sign Up" --msgbox "Passwords don't match." 7 0
			start_screen
		fi
	fi
}

home()
{
	dir=$(pwd | sed 's/.*\//...\//g')
	home_option=$(whiptail --title "$dir" --menu "Select option:"  --cancel-button "Log Out" --notags 30 30 10 \
	"1" "Open File/Folder" \
        "2" "Create File/Folder" \
        "3" "Delete File/Folder" \
        "4" "List Items in Directory" \
        "5" "See User Information" \
        "6" "Create User Report" \
	"7" "Change Theme" \
	"8" "Delete User" \
	3>&1 1>&2 2>&3)
	exit_status=$?
	if [ $exit_status -eq 1 ] ; then
		cd $initial_dir
		cd folders/Home-$ident
                                time=$(date +"%Y-%m-%d %H:%M:%S")
                                echo "Logged out: $time " >> ".jrn-$ident"
				cd ../..
				echo "$id logged out: $time " >> "admin-jrn.txt"
				sed -i "/^$id$/d" "$active_users_file"
		start_screen
	fi

	case $home_option in
	1)
		file_folder_option=$(whiptail --title "Open File / Folder" --yesno "Would you like to open a file or a folder?" \
                --yes-button "File" \
                --no-button "Folder" \
                --nocancel 10 50 3>&1 1>&2 2>&3)
                exit_status=$?
                if [ $exit_status -eq 0 ] ; then
                        file_name=$(whiptail --title "Create File" --inputbox "What is the name of the file?" \
                        --nocancel 10 50 3>&1 1>&2 2>&3 | sed 's/ /_/g')
                        nano $file_name && home || whiptail --title "Error" --msgbox "File not found!" 7 0 3>&1 1>&2 2>&3
			home
		else
                        folder_name=$(whiptail --title "Create Folder" --inputbox "What is the name of the folder?" \
                        --nocancel 10 50 3>&1 1>&2 2>&3 | sed 's/ /_/g')
                        cd $folder_name || whiptail --title "Error" --msgbox "Folder not found!" 7 0 3>&1 1>&2 2>&3
                	home
		fi
		#open a file/ folder mentioned in a user input box (first input file/folder, next input field for name
	;;

	2)
		file_folder_option=$(whiptail --title "Create File / Folder" --yesno "Would you like to create a file or a folder?" \
                --yes-button "File" \
                --no-button "Folder" \
                --nocancel 10 50 3>&1 1>&2 2>&3)
                exit_status=$?
                if [ $exit_status -eq 0 ] ; then
                        file_name=$(whiptail --title "Create File" --inputbox "What would you like to name the file? (Including extension)" \
                        --nocancel 10 50 3>&1 1>&2 2>&3 | sed 's/ /_/g')
                        touch $file_name
			home
                else
                        folder_name=$(whiptail --title "Create Folder" --inputbox "What would you like to name the folder?" \
                        --nocancel 10 50 3>&1 1>&2 2>&3 | sed 's/ /_/g')
                        mkdir $folder_name
                	home
		fi
                #create a file/ folder mentioned in a user input box (first input file/folder, next input field for name
	;;

	3)
		file_folder_option=$(whiptail --title "Delete File / Folder" --yesno "Would you like to open a file or a folder?" \
                --yes-button "File" \
                --no-button "Folder" \
                --nocancel 10 50 3>&1 1>&2 2>&3)
                exit_status=$?
                if [ $exit_status -eq 0 ] ; then
                        file_name=$(whiptail --title "Delete File" --inputbox "What is the name of the file?" \
                        --nocancel 10 50 3>&1 1>&2 2>&3 | sed 's/ /_/g')
                        rm $file_name && home || whiptail --title "Error" --msgbox "File not found!" 7 0 3>&1 1>&2 2>&3
			home
                else
                        folder_name=$(whiptail --title "Delete Folder" --inputbox "What is the name of the folder?" \
                        --nocancel 10 50 3>&1 1>&2 2>&3 | sed 's/ /_/g')
                        rm $folder_name && home || whiptail --title "Error" --msgbox "Folder not found!" 7 0 3>&1 1>&2 2>&3
                        home
                fi
		#delete a file/ folder mentioned in a user input box
	;;

	4)	#!!!!de schimbat fisierele din al doilea cd dupa ce se face directoru cu proiectu
		ls_out=$(ls -l | sed 's/ .* / /g' | sed 's/.\{9\} / /' | sed 's/-/f/g')
		whiptail --title "Files in current directory:" --msgbox "$ls_out" --scrolltext 20 60
		home
		#see current files/folders in current directory
	;;

	5)
		dir=$(pwd) #save current directory location to use after extracting info
		#whiptail --title "User Information" --msgbox "$dir \n$initial_dir " 20 50
		cd $initial_dir #go to initial location of the script to extract user info from Users.csv
                etc=$(grep -w "$id" Users.csv)
		touch temp.txt
		echo "$etc" >> temp.txt
		emaill=$(grep -o '\S*@\S*' temp.txt)
		emaill=${emaill::-1}
		whiptail --title "User Information" --msgbox " User ID: $ident  \n Username: $id \n Email: $emaill " 20 50
		rm temp.txt

		cd $dir #go back to intial location
		home

		#see user info (uid, username, email)
	;;

	6)
		dir=$(pwd) #save current directory location to use after extracting info
		cd $initial_dir/folders/Home-$ident
		cur=$(pwd)
		num_files=$(find "$cur" -type f | wc -l)
		num_dir=$(find "$cur" -type d | wc -l)
		size=$(du -hs $cur | cut -f1)
		size_b=$(du -bs $cur | cut -f1)
		whiptail --title "User report " --msgbox " Number of files: $num_files \n Number of directories: $num_dir \n Size on disk: $size \n Size (bytes): $size_b" 20 50
		#TODO REPORT
		cd $dir
		home
	;;

	7)
		theme_option=$(whiptail --title "Theme" --menu "Select a theme:"  --nocancel --notags 30 30 10 \
        	"1" "Classic" \
	        "2" "Old School" \
	        "3" "Acid Rain" \
	        3>&1 1>&2 2>&3)

		case $theme_option in
		1)
			NEWT_COLORS=${theme_variants[0]}
			home
		;;

                2)
			NEWT_COLORS='${theme_variants[1]}' #nu stiu dece varianta din mijloc necesita ghilimele extra
                	home
		;;

               	3)
			NEWT_COLORS=${theme_variants[@]}
                	home
		;;

		*)
			home
                ;;

		esac
	;;

	8)
		password=$(whiptail --title "Log In" --passwordbox "Enter password:" --nocancel 10 60 3>&1 1>&2 2>&3)
        	                clear
                	        encrypted_pass=$(echo "$password" | sha256sum | sed 's/\s.*//g')
                        	doc_pass=$(echo $found | sed 's/.*,.//g')

       		if [ $doc_pass = $encrypted_pass ] ; then
			cd $initial_dir
			touch temp.txt
			temp="temp.txt"
			while IFS=',' read -r id1 stare username email parola; do
  			if [ "$id1" = "$ident" ]; then
   				 echo "$id1, 0,$username,$email,$parola" >> "$temp"
  			else
 	   			 echo "$id1,$stare,$username,$email,$parola" >> "$temp"
 	 		fi
			done < "Users.csv"

			cp  "$temp" "Users.csv"
			scrie_mare "Loading"
			loading
			clear
			whiptail --title "Success!" --msgbox "User has been removed." 30 60
			rm temp.txt
			start_screen
		else

			whiptail --title "Error!" --msgbox "You are not authorised to delete this user!" 30 60
			home
		fi


	;;

	*)
		printf "Invalid Command!\n"
	;;
	esac

}

clear
initial_dir=$(pwd) #save initial location in the project to access late
active_users_file="$initial_dir/active_users.txt"
touch "$active_users_file"
start_screen
