#!/bin/sh

#WARNING: 
#passing content of passwords file as argument to cmd is 
#not actually 100% safe
#But, it will still be safer than decrypting the file and storing
#it on the disk anyway
#Notice however that the master password is never saved ! We let openssl
#handle that password at all time. 

#Format of password.txt : TAG:USER:PASSWORD:EMAIL:DESC

printhelp() {
  echo "TODO"
}

#options: 
# -noxclip desactivates the usage of xclip and will print the password on STDOUT
# -file=PATH is the PATH to the encrypted file containing passwords
NOXCLIP=false
PASSWORDFILE=passwords.dat

#process options
cont=true
while $cont
do
  case "$1" in
    --noxclip)
      NOXCLIP=true
      shift
      ;;
    --file=*)
      PASSWORDFILE="$(echo "$1" | sed -re 's/--file=(.*)/\1/')"
      shift
      ;;
    *)
      cont=false
      ;;
  esac
done

#load passwords in variable PASSWORDS and FILTEREDPASSWORDS
#PASSWORDS contains the exact content, while FILTEREDPASSWORDS
#only has the lines with fields. PASSWORDS is used to keep
#comments and other manually added information if necessary.
ldpasswd() {
  if [ ! -f "$PASSWORDFILE" ]; then 
    echo "Password file not existing. Creating new one ..."
    touch "$PASSWORDFILE"
    PASSWORDS=""
  elif [ ! -s "$PASSWORDFILE" ]; then 
    PASSWORDS=""
  else
    #decrypt and store content in variable passwords
    PASSWORDS=$(openssl aes-256-cbc -d -in $PASSWORDFILE 2> /dev/null)
    if [ $? -ne 0 ]; then
      echo "Could not decrypt password file!"
      exit 1
    fi
  fi
  #this ignores comments and empty lines
  FILTEREDPASSWORDS=`echo "$PASSWORDS" | grep -v "^#" | grep -v "^$"`
}

#exit with an error message
die () {
  echo "$1" 1>&2
  exit 1
}

#check if command exists and can be run
chkcmd () {
  cmd="$1"
  args="$2"

  if ! $cmd $args < /dev/null > /dev/null 2>&1; then
    die "Could not succesfully run $cmd !"
  fi
  return 0
}

#store the new content of password in $PASSWORDFILE
stpasswd () {
  printf "$1" | openssl aes-256-cbc -salt -out "$PASSWORDFILE"
  return 0
}

#check that the tag is non ambiguous and prints the line corresponding to the tag
gettag () {
  tag="$1"
  if [ `printf $tag | wc -w` -ne 1 ]; then
    echo "Tag must be a single word"
    exit 1
  fi

  tags=`echo "$FILTEREDPASSWORDS" | cut -f 1 -d : | grep "$tag"`
  #try to do an exact matching
  completetag=$(printf "$tags" | grep "^$tag$")
  if [ $? -ne 0 ]; then
    nb=`echo "$tags" | wc -l`
    if [ $nb -eq 0 ] || [ "X$tags" = "X" ] ; then
      echo "No password corresponding to $tag" 1>&2
      exit 1
    elif [ $nb -gt 1 ]; then
      if ! echo "$tags" | grep ":${tag}$" -q; then
        echo "Ambiguous tag, you need to provide a better matching. Potential tags are:" 1>&2
        for t in $tags; do
          printf "\t$t\n" 1>&2
        done
        exit 1
      fi
      tags=$(echo "$tags" | grep ":${tag}$")
    else
      #then $tags only contains one tag
      completetag=$tags
    fi
  fi

  echo $(echo "$FILTEREDPASSWORDS" | grep "^${completetag}:")
  return 0
}

#Main
case $1 in
  get)
    ldpasswd
    line=$(gettag "$2") || die "Could not identify the correct tag !"
    tag=$(echo "$line" | cut -f 1 -d :)
    login=$(echo "$line" | cut -f 2 -d :)
    pass=$(echo "$line" | cut -f 3 -d :)
    if $NOXCLIP; then
      echo "Data for $tag:"
      echo "login: $login"
      echo "password: $pass"
    else
      chkcmd xclip "-selection c"
      echo "$pass" | xclip -selection c
      sleep 10 && echo "" | xclip -selection c &
      echo "Data for $tag:"
      echo "login: $login"
      echo "password: in clipboard for 10 seconds"
    fi
    ;;
  tags)
    ldpasswd
    tags=`echo "$FILTEREDPASSWORDS" | cut -f 1 -d : | sort | tr '\n' ' '`
    printf "The following tags are present:\n"
    for tag in $tags; do printf "\t$tag\n"; done
    ;;
  set) #set only works with an exact matching of tag
    ldpasswd
    tag="$2"
    printf "New password: "
    stty -echo
    read newpass
    stty echo
    passwords=`echo "$PASSWORDS" | awk -F: -v "tag=$tag" -v "newpass=$newpass" '$1 == tag {printf "%s:%s:%s:%s:%s\n", $1, $2, newpass, $4, $5} $1 != tag {print $0}'`
    stpasswd "$passwords"
    ;;
  set-random)
    ldpasswd
    tag="$2"
    chkcmd pwgen "12 -s"
    newpass=`pwgen 12 -s`
    passwords=`echo "$PASSWORDS" | awk -F: -v "tag=$tag" -v "newpass=$newpass" '$1 == tag {printf "%s:%s:%s:%s:%s\n", $1, $2, newpass, $4, $5} $1 != tag {print $0}'`
    stpasswd "$passwords"
    ;;
  add | add-random)
    ldpasswd
    printf "tag: "
    read tag
    tags=`echo "$FILTEREDPASSWORDS" | cut -f 1 -d : | grep "$tag"`
    echo $tags | grep "$tag" -q && die "Tag already in use"
    printf "username: "
    read user
    printf "email: "
    read email
    case "$1" in
      add)
        stty -echo
        printf "password: "
        read password
        printf "\n"
        stty echo
        ;;
      add-random)
        chkcmd pwgen "12 -s"
        password=`pwgen 12 -s`
        ;;
    esac
    newentry="$tag:$user:$password:$email:"
    passwords="$PASSWORDS\n$newentry"
    stpasswd "$passwords"
    ;;
  delete)
    ldpasswd
    line=$(gettag "$2") || die "Could not identify the correct tag !"
    passwords=$(echo "$PASSWORDS" | grep "$line" -v)
    stpasswd "$passwords"
    ;;
  print)
    ldpasswd
    printf "$PASSWORDS"
    ;;
  help)
    printhelp
    ;;
  *)
    die "Unknown command: $1"
    ;;
esac
