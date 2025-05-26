#!/bin/bash

send_mail()
{
        echo "I sent email at "$1" address"
        echo "Felicitari! Ati fost autentificat!" | mail -s "Autentificare" $1
}

if  systemctl is-active --quiet postfix && command -v mail &> /dev/null ; then
        echo "Sending email for verification. Check your inbox!"
else
        echo "Serviciile de mail nu pot fi utilizate"
        exit 1
fi
#
send_mail $1
echo "Done"
exit 0
