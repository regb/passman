PassMan
=======

Password Manager in a one-file shell script.


Introduction
------------

Store passwords in an encrypted file (by default "passwords.dat" in the current
working directory). If the file does not exist it will create an empty one.
The data file is protected by a password. This will work as your master password
and is the only password you will need to remember. The underlying implementation
is done by `openssl` and PassMan works as a lightweight interface on top to
simplify the management of password files.

Each password is associated with a tag, and the script provides commands to
add/remove/edit a tag.

Why would you use PassMan? When you need *simplicity*. There is no hidden
binary executable or other files stored in unexpected location. Your whole
password manager system consists of two files, the `passman.sh` script and one
data file. The only thing you need to protect and bckup is the data file.

Usage
-----

General usage is:

    ./passman.sh CMD [ARGS]

Here is the list of usage per commands:

    ./passman.sh add-random

Prompt a few questions, a tag, a username and an email, and
generate a random password associated with this tag.

    ./passman.sh get TAG

Find and put in the clipboard the password corresponding to TAG.
TAG needs not be exact matching, but cannot be ambiguous.

    ./passman.sh delete TAG

Delete the entry associated with TAG. TAG must be an exact matching.

    ./passman.sh tags

List all the tags.

    ./passman.sh set TAG

Can set password for TAG. TAG must be an exact matching.

    ./passman.sh set-random TAG

Set a random password for TAG. TAG must be an exact matching.

    ./passman.sh set-username TAG

Set a new username for TAG. TAG must be an exact matching.

    ./passman.sh set-email TAG
    
Set a new email for TAG. TAG must be an exact matching.

    ./passman.sh help

Print a help message.

    ./passman.sh print

Print the decrypted file. This will output all your tags and passwords in clear text.

OPTIONS
-------

Options can be passed before the cmd (described above):

    --file=FILENAME

Use FILENAME for the password database instead of the default "passwords.dat".

    --noxclip

Prevent the use of xclip, instead print in clear the password.
