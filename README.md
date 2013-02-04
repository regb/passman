Simple shell script that manage passwords.

=== Introduction ===
Store passwords in a file named "passwords.dat" in the current working
directory. If the file does not exist it will create an empty one.

=== Usage ===
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

./password.sh help
Print a help message.

./password.sh print
Print the decrypted file.

=== OPTIONS ===
Options can be passed before the cmd (described above):
  --file=FILENAME
    Use FILENAME for the password database instead of the default "passwords.dat".
  --noxclip
    Prevent the use of xclip, instead print in clear the password.

=== WISHLIST ===
  - Set tags/login/email
  - Use markdown to format this README file
