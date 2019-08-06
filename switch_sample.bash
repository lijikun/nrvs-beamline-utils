#!/bin/bash
#
# Switches the sample data being processed.
# 
# Reads in_padd and in_phox symlinks for the current sample name, 
# and moves the files starting with the sample name into a folder with the same name.
# 
# If the PHOENIX input files already exist for the new sample name,
# will just re-make the symlinks in_padd and in_phox pointing to them.
# If no such files are found, will make a new directory, copy the input files,
# and edit them to fit the new sample name. New symlinks are also made.
#
# Usage: 
## ./switch_sample.bash [New Sample Name]

echo
if [[ ! $1 ]]; then
	echo "Input error. Usage: ./switch_sample.bash SampleName"
	exit 1
fi

# Strips trailing slashes possibly at the end of $1 due to shell autocomplete.
target="${1%%/*}"

prevFile1=$(basename $(readlink in_padd))
prevFile2=$(basename $(readlink in_phox))
prevString1=${prevFile1#in_padd_}
prevString2=${prevFile2#in_phox_}

if [[ -e ${target} && -e ${target}/in_padd_${target} && -e ${target}/in_phox_${target} ]]; then
	# Sample input files already exist.
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
		mkdir -p ${target}
		cp -L in_padd ${target}/in_padd_${target}
		cp -L in_phox ${target}/in_phox_${target}
		if [[ ${prevString1} && ${prevString2} ]]; then
			sed -i "s:${prevString1}:${target}:g" ${target}/in_padd_${target}
			sed -i "s:${prevString2}:${target}:g" ${target}/in_phox_${target}
		fi
	else
		echo "Must have existing in_padd and in_phox files to begin with!"
		exit 1
	fi
fi

# Moves files belonging to previous sample.
if [[ ${prevString1} && ${prevString2} && -d ${prevString1} && -d ${prevString2} ]]; then
    for x in ${prevString1}?*; do
        if [[ -e $x ]]; then	
            echo "Moving file ${x} to folder ${prevString1}/"
            mv $x ${prevString1}/
        fi
    done
    for x in ${prevString2}?*; do
        if [[ -e $x ]]; then 
            echo "Moving file ${x} to folder ${prevString2}/"
            mv $x ${prevString2}/
        fi
    done
else
    echo "Cannot find the correct directory for old files. Skipping moving them."
fi

# Creates soft links.
echo "Creating soft links:"
rm -f in_padd in_phox
ln -fs ${target}/in_padd_${target} in_padd
ln -fs ${target}/in_phox_${target} in_phox
ls -l in_padd in_phox
echo

