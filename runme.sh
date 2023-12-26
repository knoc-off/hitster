function hit() {

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
    fi

    echo $ran >> numbers.txt

    clear

    # can change url
    qr "https://www.hitstergame.com/de/$ran"
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


