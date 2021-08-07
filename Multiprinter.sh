#!/bin/bash

# Check if cups-pdf printer is installed
# If it's not then install it
# using for printing pdf files separately
check=$(lpstat -p)
if [[ $check != *PDF* ]]; then
	sudo apt install cups
fi

# Also check for zenity package
# using for GUI
if ! (command -v zenity >/dev/null 2>&1); then
	sudo apt install zenity
fi

# Same for the pdftk package
# using for merge pdfs in a single one
if ! (command -v pdftk >/dev/null 2>&1); then
	sudo apt install pdftk
fi

# Temporarily rename your /home/PDF directory,
# if it exists
if [[ -d "/home/$USER/PDF" ]]; then
	legacy=1
	mv "/home/$USER/PDF" "/home/$USER/PDF1"	
fi

# Create clear PDF directory
mkdir "/home/$USER/PDF"

# Multiple files selection window
files=$(zenity --file-selection --multiple)

# The variable counts how many files
# are to be printed
i=0

# Temporarily using new separator
OLFIDF=$IFS
IFS="|"

# Printing each selected file separately
for e in $files; do
	lpr -o fit-to-page -P PDF $e
	i=$((i+1))
done

# Returning IFS to the previous value
IFS=$OLDIFS

echo "Printing..."

# Waiting till the printing ends
while [[ $(ls -1q "/home/$USER/PDF/" | wc -l) -ne $i ]]; do
	sleep 3
done

echo "Done"
echo "Choose directory to save the file:"
sleep 2

# Using variable to contain the path to save
szSavePath=$(zenity --file-selection --save --confirm-overwrite)

# Merging files and saving the result
pdftk /home/$USER/PDF/*.pdf cat output $szSavePath

echo $szSavePath

# Deleting temporary directory used for printing
if [[ $legacy -eq 1 ]]; then
	rm -r "/home/$USER/PDF"
	mv "/home/$USER/PDF1" "/home/$USER/PDF"
fi
