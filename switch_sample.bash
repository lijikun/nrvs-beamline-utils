#!/bin/bash
#
# Usage: ./switch_sample.bash NewSampleName

echo
if [[ ! $1 ]]; then
	echo "Input error. Usage: ./switch_sample.bash SampleName"
	exit 1
fi

prevFile1=$(basename $(readlink in_padd))
prevFile2=$(basename $(readlink in_phox))
prevString1=${prevFile1#in_padd_}
prevString2=${prevFile2#in_phox_}

if [[ -e $1 && -e $1/in_padd_$1 && -e $1/in_phox_$1 ]]; then
	# Sample data already exist.
	if [[ -e in_padd ]]; then
		echo "Backing up in_padd to in_padd.bak"
		cp -L in_padd in_padd.bak
	fi
	if [[ -e in_phox ]]; then
		echo "Backing up in_phox to in_phox.bak"
		cp -L in_phox in_phox.bak
	fi
else 
	# Creates new folder. Copies existing input files into it and makes edits.
	if [[ -e in_padd && -e in_phox ]]; then
		mkdir -p $1
		cp -L in_padd $1/in_padd_$1
		cp -L in_phox $1/in_phox_$1
		if [[ $prevString1 && $prevString2 ]]; then
			sed -i "s:$prevString1:$1:g" $1/in_padd_$1
			sed -i "s:$prevString2:$1:g" $1/in_phox_$1
		fi
	else
		echo "Must have existing in_padd and in_phox files to begin with!"
		exit 1
	fi
fi

# Moves files belonging to previous sample.
if [[ $prevString1 && $prevString2 ]]; then
    for x in ${prevString1}?*; do
        if [[ -e $x ]]; then	
            echo "Moving file ${x} to folder ${prevString1}/"
            mv $x $prevString1/
        fi
    done
    for x in ${prevString2}?*; do
        if [[ -e $x ]]; then 
            echo "Moving file ${x} to folder ${prevString2}/"
            mv $x $prevString2/
        fi
    done
fi

# Creates soft links.
echo "Creating soft links:"
rm -f in_padd in_phox
ln -fs $1/in_padd_$1 in_padd
ln -fs $1/in_phox_$1 in_phox
ls -l in_padd in_phox
echo

