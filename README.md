# linux-script-ocamlfuse-auto-backup

The paths in this script assume that it executes from home directory, and creates (and later overwrites) another shell script in /home/ called list-files-out.sh. 

Auxiliary text files are created (and subsequently overwritten) in an existing directory /home/google-drive-backup/ and are called gdrive-timefile.txt and list-files.txt

google-drive-backup.sh, when executed, opens google-drive-backup/gdrive-timefile.txt and reads a value in seconds since Epoch. This value was written to file last time the script executed

The current time is subtracted from this, and the result, ie time elapsed since last execution, is converted to decimal minutes with the bash 'bc' command

Passes minutes to 'find' command

Writes 'find' output to google-drive-backup/list-files.txt as a record of files and paths which have been modified since the last time the script was executed

A Python routine is called (because I can't code in Bash) to read list-files.txt and process files into source and destination paths in various arrays

Python concatenates with some syntax constants (also in array form) and writes line-by-line commands to list-files-out.sh. These commands create new directories in the destination (Google Drive mounted drive) if they don't exist, and then copies files from /home/Documents/[filepath]/file.ext to identical filepaths in the mounted drive

Back in Bash, overwrites timefile with current time

with Ocamlfuse, mounts label [your Gmail Account Name] at ~/[name of mounted drive]

Finally, the auxiliary script list-files-out.sh is called in order to make the actual backup
