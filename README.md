# linux-script-ocamlfuse-auto-backup

When run, this shell script will automatically backup to Google Drive all files which have been modified or created since the last time it was run.

# Prerequisites:
Bash shell
Ocamlfuse FUSE system for mounting Google Drive on Linux: https://www.omgubuntu.co.uk/2017/04/mount-google-drive-ocamlfuse-linux

# Warning
This script accesses your Google Drive. Consider starting a new Google account for the purposes of backing up your desktop machine. Google has a nice "Profiles" system to switch between accounts, and seems to be happy to fling multiple chucks of 15 Gb at you.

# Summary:
This shell script looks up the last time it was run, and identifies the list of files (within a chosen directory - default = Documents) which have been modified since that time.
The filepaths and names are concatenated with string constants in a Python sub-routine, in order to create a subsidiary shell script with Bash syntax for copying the files to a chosen destination in Google-Drive.
An Ocamlfuse command is run to mount an account-labeled Google Drive.
The subsidiary script is called to make the Bash copy commands from the source destinations to the mounted Google Drive
Ocamlfuse then unmounts the Drive

# Code structure:

The paths in this script assume that it executes from home directory, and creates (and later overwrites) another shell script in /home/ called list-files-out.sh. 

Auxiliary text files are created (and subsequently overwritten) in an existing directory /home/google-drive-backup/ and are called gdrive-timefile.txt and list-files.txt

google-drive-backup.sh, when executed, opens google-drive-backup/gdrive-timefile.txt and reads a value in seconds since Epoch. This value was written to file last time the script executed

The current time is subtracted from this, and the result, ie time elapsed since last execution, is converted to decimal minutes with the bash 'bc' command

Passes minutes to 'find' command

Writes 'find' output to google-drive-backup/list-files.txt as a record of files and paths which have been modified since the last time the script was executed

A Python routine is called (because I can't code in Bash) to read list-files.txt and process files into source and destination paths in various arrays

Python concatenates with some syntax constants (also in array form) and writes line-by-line commands to list-files-out.sh. These commands create new directories in the destination (Google Drive mounted drive) if they don't exist, and then copies files from /home/Documents/[filepath]/file.ext to identical filepaths in the mounted drive
NOTE: list-files-out.sh is a shell script which is created in the same directory as this script, not in subdirectory google-drive-backup/

Back in Bash, overwrites timefile with current time

with Ocamlfuse, mounts label [your Gmail Account Name] at ~/[name of mounted drive]

Finally, the auxiliary script list-files-out.sh is called in order to make the actual backup

# You need to do the following

Install and set up Ocamlfuse: https://www.omgubuntu.co.uk/2017/04/mount-google-drive-ocamlfuse-linux

Download this ocamlfuse-auto-backup-google-drive.sh shell script to directory-path/ , and make a sub-directory directory-path/google-drive-backup

Change code to reflect your directory structure:
line 41: edit home/user/Documents
line 109: supply your gmail username (without the @gmail.com) and directory where you mount your Google Drive
line 115: directory where you mount your Google Drive

Give read/write permissions to auxiliary files in google-drive-backup/
Make this script and list-files-out.sh executable
