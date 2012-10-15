#!/bin/sh

#WARNING: passing content of passwords file as argument to cmd is not actually 100% safe
# Well, it will still be safer than decrypting the file and storing
# it on the disk

#Format of password.txt : TAG:USER:PASSWORD:EMAIL:DESC

noxclip=false

if [ "$1" = "--noxclip" ]; then 
  noxclip=true
  shift
fi

passwordfile=passwords.enc
if [ ! -f "$passwordfile" ]; then 
  echo "Password file not existing. Creating new one ..."
  touch "$passwordfile"
  passwords=""
else
  #decrypt and store content in variable passwords
  passwords=$(openssl aes-256-cbc -d -in $passwordfile 2> /dev/null)
  if [ $? -ne 0 ]; then
    echo "Could not decrypt password file!"
    exit 1
  fi
fi

#this ignores comments and empty lines
filteredpasswords=`echo "$passwords" | grep -v "^#" | grep -v "^$"`

die () {
  echo "$1" 1>&2
  exit 1
}

chkcmd () {

  cmd="$1"
  args="$2"

  if ! $cmd $args < /dev/null > /dev/null 2>&1; then
    echo "Could not succesfully run $cmd !"
    echo "You probably need to install it ..."
    exit 1
  fi
  return 0
}

stpasswd () {
  printf "$1" | openssl aes-256-cbc -salt -out "$passwordfile"
  return 0
}

#check that the tag is non ambiguous and prints the line corresponding to the tag
gettag () {
  tag="$1"
  if [ `printf $tag | wc -w` -ne 1 ]; then
    echo "Tag must be a single word"
    exit 1
  fi

  tags=`echo "$filteredpasswords" | cut -f 1 -d : | grep "$tag"`
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
  fi

  #assume tags contains only the correct tag
  tag=$tags
  echo $(echo "$filteredpasswords" | grep "^${tag}:")
  return 0
}

case $1 in
  get)
    line=$(gettag "$2") || die "Could not identify the correct tag !"
    tag=$(echo "$line" | cut -f 1 -d :)
    pass=$(echo "$line" | cut -f 3 -d :)
    if $noxclip; then
      echo "password for $tag is $pass"
    else
      chkcmd xclip "-selection c"
      echo "$pass" | xclip -selection c
      sleep 10 && echo "" | xclip -selection c &
      echo "password for $tag is in clipboard for 10 seconds"
    fi
    ;;
  tags)
      tags=`echo "$filteredpasswords" | cut -f 1 -d : | sort | tr '\n' ' '`
      printf "The following tags are present:\n"
      for tag in $tags; do printf "\t$tag\n"; done
    ;;
  set)
      tag="$2"
      stty -echo
      read newpass
      stty echo
      passwords=`echo "$filteredpasswords" | awk -F: -v "tag=$tag" -v "newpass=$newpass" '$1 == tag {printf "%s:%s:%s:%s:%s\n", $1, $2, newpass, $4, $5} $1 != tag {print $0}'`
      stpasswd "$passwords"
    ;;
  add)
    printf "tag: "
    read tag
    printf "username: "
    read user
    printf "email: "
    read email
    stty -echo
    printf "password: "
    read password
    printf "\n"
    stty echo
    newentry="$tag:$user:$password:$email:"
    passwords="$passwords\n$newentry"
    stpasswd "$passwords"
    ;;
  add-random)
    printf "tag: "
    read tag
    printf "username: "
    read user
    printf "email: "
    read email
    chkcmd pwgen "12 -s"
    password=`pwgen 12 -s`
    newentry="$tag:$user:$password:$email:"
    passwords="$passwords\n$newentry"
    stpasswd "$passwords"
    ;;
  delete)
    line=$(gettag "$2") || die "Could not identify the correct tag !"
    passwords=$(echo "$passwords" | grep "$line" -v)
    stpasswd "$passwords"
    ;;

esac
