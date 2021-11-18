#!/bin/bash

# The paths in this script assume that it executes from home directory, and creates (and later overwrites) another shell script in /home/ called list-files-out.sh. 

# Auxiliary text files are created (and subsequently overwritten) in an existing directory /home/google-drive-backup/ and are called gdrive-timefile.txt and list-files.txt

# google-drive-backup.sh, when executed, opens                   google-drive-backup/gdrive-timefile.txt and reads a value in seconds since Epoch. This value was written to file last time the script executed

# The current time is subtracted from this, and the result, ie time elapsed since last execution, is converted to decimal minutes with the bash 'bc' command

# Passes minutes to 'find' command

# Writes 'find' output to google-drive-backup/list-files.txt as a record of files and paths which have been modified since the last time the script was executed

# A Python routine is called (because I can't code in Bash) to read list-files.txt and process files into source and destination paths in various arrays

# Python concatenates with some syntax constants (also in array form) and writes line-by-line commands to list-files-out.sh. These commands create new directories in the destination (Google Drive mounted drive) if they don't exist, and then copies files from /home/Documents/[filepath]/file.ext to identical filepaths in the mounted drive

# Back in Bash, overwrites timefile with current time
# with Ocamlfuse, mounts label [your Gmail Account Name] at ~/[name of mounted drive]

# Auxiliary script list-files-out.sh is called in order to make the actual backup



# Read calculate time elapsed since last backup
TIME_THEN=$(sed '1!d' google-drive-backup/gdrive-timefile.txt)
TIME_NOW=$(date +%s)
TIME_ELAPSED_SEC=$(($TIME_NOW - $TIME_THEN))
TIME_ELAPSED_MIN_DIV=$(($TIME_ELAPSED_SEC / 60))
TIME_ELAPSED_MIN_REM=$(($TIME_ELAPSED_SEC % 60))
# Convert to decimal minutes
TIME_ELAPSED_MIN=$(echo "scale=5; $TIME_ELAPSED_MIN_DIV + $TIME_ELAPSED_MIN_REM / 60" | bc)

# Comment-out the above line and uncomment line below
# in order to maunually supply argument in minutes to this script

#TIME_ELAPSED_MIN=$1

# Files to be backed are saved to list-files.txt
find /home/user/Documents/ -type f -mmin -$TIME_ELAPSED_MIN > google-drive-backup/list-files.txt

# Python now (very inelegantly) concatenates copy commands
python3 - <<END 

import os

#make list of lines from list-files.txt
lines = []
with open('google-drive-backup/list-files.txt') as f:
    lines = [line.rstrip('\n') for line in f]
f.close()

n = len(lines)

#save lines as source files
targetlines = [0] * n
for i in range(0, n):
    targetlines[i] = lines[i]

#trim lines and put in array trimlines
trimlines = [0]*n
for i in range(0,n):
    trimlines[i] = lines[i][13:]

# Separate paths and filenames
filepath = [0]*n
file = [0]*n
for i in range(0, n):
	head_tail = os.path.split(trimlines[i])
	filepath[i] = head_tail[0]
	file[i] = head_tail[1]

# Define various string constants for concatenating Bash cp command
constarrmkdir = ['mkdir -p ']*n
constarrpath = ['~/google-drive2/pc-backup/'] * n
constandcp = [' && cp '] * n
constspace = [' '] * n

#concatenate
res = [0] * n
res = [f + g + h + i + j + k + l + m for f, g, h, i, j, k, l, m in zip(constarrmkdir, constarrpath, filepath, constandcp, lines, constspace, constarrpath, filepath)]

# Display some output
print("\nSounrce:")
for i in range(0, n):
    print(lines[i])
print("\nDestination:")
for i in range(0, n):
    print(constarrpath[i] + filepath[i])	
print("\n")

# Overwrite list-files-out.txt with Bash cp commands
with open('list-files-out.sh', 'w') as g:
    for line in res:
        g.write(line)
        g.write('\n')
g.close()
END

echo "Time since last backup (mins) = $TIME_ELAPSED_MIN"

TIME_NOW=$(date +%s)

# Writes current time to gdrive-timefile.txt
echo "$TIME_NOW" > google-drive-backup/gdrive-timefile.txt

# mount drive
google-drive-ocamlfuse -label [gmailuser123] ~/[mountpoint]

# run shell script with Bash copy commands
./list-files-out.sh

#unmount gdrive
fusermount -u ~/[mountpoint]


