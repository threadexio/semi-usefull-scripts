#!/bin/bash

if [[ "$1" == "ssc" && "$#" -eq 6 ]]; then
	openssl req -x509 -$2 -nodes -days "$3" -newkey "rsa:$4" -keyout "$6" -out "$5"
	cat "$5" "$6" > "${5%%.*}.pem"
	openssl x509 -in "$5" -text -noout

elif [[ "$1" == "csr" && "$#" -eq 4 ]]; then
	openssl req -new -newkey "rsa:$2" -nodes -out "$3" -keyout "$4"
	openssl req -in "$3" -text -noout -verify
else
	echo "Usage:"
	echo -e "Self-Signed Cert:\t$0 ssc [digest] [days] [RSA bits] [crt out] [key out]"
	echo -e "Cert Signing Request:\t$0 csr [RSA bits] [csr out] [key out]"
	echo -e "\nExamples:"
	echo "$0 ssc sha512 365 4096 cert.crt private.key"
	echo "$0 csr 4096 request.csr private.key"
fi