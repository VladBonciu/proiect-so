#/!bin/bash

servicii=("postfix" "mail")

send_mail() 
{
	echo "I sent email at "$1" address"
	echo "Felicitari! Ati fost autentificat!" | mail -s "Autentificare" $1
}

for service in "${servicii[@]}"; do
	if ! systemctl is-active --quiet "$service"; then
		echo "Error: $service not available!"
		exit 1
	fi
done

echo "Sending email for verification. Check your inbox!"
send_mail $1
echo "Done"
exit 0
