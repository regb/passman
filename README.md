#PASSMAN

Simple shell script that manage passwords.

##Introduction

Store passwords in a file named "passwords.dat" in the current working
directory. If the file does not exist it will create an empty one.

##Usage

General usage is:
    ./password.sh CMD [ARGS]

Here is the list of usage per commands:

    ./password.sh add-random
Prompt a few questions, a tag, a username and an email, and
generate a random password associated with this tag.

    ./password.sh get TAG
Find and put in the clipboard the password corresponding to TAG.
TAG does not need to be exact matching, but cannot be ambiguous.

    ./password.sh delete TAG
Delete the entry associated with TAG. TAG must be an exact matching.

    ./password.sh tags
List all the tags.

    ./password.sh set TAG
Can set password for TAG. TAG must be an exact matching.

    ./password.sh set-random TAG
Set a random password for TAG. TAG must be an exact matching.

    ./password.sh set-username TAG
Set a new username for TAG. TAG must be an exact matching.

    ./password.sh set-email TAG
Set a new email for TAG. TAG must be an exact matching.

    ./password.sh help
Print a help message.

    ./password.sh print
Print the decrypted file.

##OPTIONS
Options can be passed before the CMD (described above):

* --file=FILENAME
Use FILENAME for the password database instead of the default "passwords.dat".

* --noxclip
Prevent the use of xclip, instead print in clear the password.
