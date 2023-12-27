#/usr/bin/env nix-shell
#nix-shell -i bash -p jq qrencode

#/usr/bin/env bash

function hit() {

    ran=$((RANDOM%$MAXRANGE)) # needs tweaking.
    ran=$(printf "%05d" $ran)

    if [ -f numbers.txt ]
    then
        echo "numbers.txt exists"
    else
        echo "numbers.txt does not exist"
        touch numbers.txt
    fi

    # check if the number is already in use
    if grep -Fxq "$ran" numbers.txt
    then
        echo "Number already in use, try again"
        hit
        return
    fi

    echo $ran >> numbers.txt

    clear

    echo "$URL$ran" | qrencode -l H -t UTF8
    echo "$URL$ran"
}

function init() {
    # check if environment is set
    if [ -z "$HITSTER_COUNTRYCODE" ]
    then
        # put country codes into an array
        codes=($(jq -r '.countryCode | keys[]' countries.json))
        #jq -r '.countryCode | keys[]' countries.json
        # print out the country codes and an index next to them
        for i in "${!codes[@]}"; do
            echo "$i ${codes[$i]}"
        done

        # ask for input
        read -p "Enter a number: " input

        # check if input is a number
        if ! [[ "$input" =~ ^[0-9]+$ ]]
        then
            echo "Not a number"
            hit
            return
        fi

        export HITSTER_COUNTRYCODE=${codes[$input]}
    fi


    # based on the country code,
    URL=$(jq -r ".countryCode.$HITSTER_COUNTRYCODE.url" countries.json)
    MAXRANGE=$(jq -r ".countryCode.$HITSTER_COUNTRYCODE.max" countries.json)
}


init

# loop forever wait for read
while true; do hit; read -n1; done

