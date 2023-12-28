# /usr/bin/env bash
# /usr/bin/env nix-shell -i bash -p jq qrencode

# on fail exit
set -e

function hit() {
    ran=$((RANDOM%$MAXRANGE)) # needs tweaking.
    ran=$(printf "%05d" $ran)

    # check if the number is already in use
    if grep -Fxq "$ran" numbers.txt
    then
        #echo "Number already in use, try again"
        hit
        return
    fi

    echo $ran >> numbers.txt

    clear

    echo "$URL$ran" | qrencode -l H -t UTF8
    echo "$URL$ran"
}

function init() {

    if [ -f numbers.txt ]
    then
        echo "numbers.txt exists"
    else
        echo "numbers.txt does not exist"
        touch numbers.txt
    fi

    # check if environment is set
    if [ -z "$HITSTER_COUNTRYCODE" ]
    then
        # put country codes into an array
        codes=($(jq -r '.countryCode | keys[]' countries.json))
        #jq -r '.countryCode | keys[]' countries.json
        # print out the country codes and an index next to them
        for i in "${!codes[@]}"; do
            # format the index to be 2 spaces wide
            printf "%02d: %s\n" $i "${codes[$i]}"

        done

        # ask for input
        read -p "Enter a number/country code: " input

        # check if input is a number
        if [[ "$input" =~ ^[0-9]+$ ]]
        then
            export HITSTER_COUNTRYCODE=${codes[10#$input]}
        elif [[ " ${codes[@]} " =~ " ${input} " ]] then
            export HITSTER_COUNTRYCODE="$input"
        else
            echo "Invalid input"
            exit 1
        fi

    fi


    # based on the country code,
    URL=$(jq -r ".countryCode.$HITSTER_COUNTRYCODE.url" countries.json)
    MAXRANGE=$(jq -r ".countryCode.$HITSTER_COUNTRYCODE.max" countries.json)
    printf "MAXRANGE: %s\n" $MAXRANGE
}


init


while true;
do
    hit;
    # if the input is i (invalid) then use jq to set the max number to the current numbe
    read -n1;
done

