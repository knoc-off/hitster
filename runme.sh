#/usr/bin/env bash

function hit() {

    # check if environment is set
    if [ -z "$HITSTER_COUNTRYCODE" ]
    then
        echo "HITSTER_COUNTRYCODE is unset"
        echo "Please set HITSTER_COUNTRYCODE to your country code"
        echo "Example: export HITSTER_COUNTRYCODE=de"
        exit
    fi


    # based on the country code,
    # us jq, to get the field url from the json under the country code
    URL=$(jq -r ".countryCode.$HITSTER_COUNTRYCODE.url" countries.json)


    ran=$((RANDOM%350)) # needs tweaking.
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

    # can change url
    # For america, theres a strange url:
    qr "$URL$ran"
    #qr "https://www.hitstergame.com/$HITSTER_COUNTRYCODE/$ran"

    echo "$URL$ran"
    #echo "https://www.hitstergame.com/$HITSTER_COUNTRYCODE/$ran"
}

qr () {
  if [[ $1 == "--share" ]]; then
    declare -f qr | qrencode -l H -t UTF8;
    return
  fi

  local S
  if [[ "$#" == 0 ]]; then
    IFS= read -r S
    set -- "$S"
  fi

  sanitized_input="$*"

  echo "${sanitized_input}" | qrencode -l H -t UTF8
}

# loop forever wait for read
while true; do read -n1; hit; done

