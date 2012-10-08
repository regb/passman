Simple shell script that manage passwords.

Store passwords in a file named "passwords.enc" in the current working
directory. If the file does not exist it will create an empty one.

Usage:
  
./password.sh add-random
Prompt a few questions, a tag, a username and an email, and
generate a random password associated with this tag.

./password.sh get TAG
Find and put in the clipboard the password corresponding to TAG.

./password.sh delete TAG
Delete the entry associated with TAG.

./password.sh tags
List all the tags.
