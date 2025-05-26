#!/bin/bash

send_mail()
{
        #echo "I sent email at "$1" address"
        echo "Felicitari! Ati fost autentificat!" | mail -s "Autentificare" $1
}

if systemctl is-active --quiet postfix && command -v mail &> /dev/null ; then
	send_mail $1
        echo "Sending email for verification. Check your inbox!"
	exit 0
else
        echo "Mail services cannot be used."
        exit 1
fi

