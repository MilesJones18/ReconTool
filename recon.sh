#!/bin/bash

if [ -z "$1" ]
then
    echo "Usage: ./recon.sh <IP>"
    exit 1
fi


printf "\n----- NMAP -----\n\n" > results

echo "Running Nmap..."
nmap $1 | tail -n +5 | head -n -3 >> results


while read line
do
    if [[ $line == *open* ]] && [[ $line == *http* ]]
    then
        echo "Running Gobuster..."
        gobuster dir -u $1 -w /usr/share/wordlists/dirb/common.txt -b "201,301,302,307,401,403,404" -qz > temp1

    echo "Running WhatWeb..."
    whatweb $1 -v > temp2
    fi
done < results


if [ -e temp1 ]
then
    printf "\n----- DIR -----\n\n" >> results
    cat temp1 >> results
    rm temp1
fi

if [ -e temp2 ]
then
    printf "\n----- WEB -----\n\n" >> results
        cat temp2 >> results
        rm temp2
fi

awk -v t=$SECONDS 'BEGIN{t=int(t*1000); printf "Elapsed Time (HH:MM:SS): %d:%02d:%02d\n", t/3600000, t/60000%60, t/1000%60}'

cat results
