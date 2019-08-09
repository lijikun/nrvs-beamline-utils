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
	echo "Input error. Usage: ./switch_sample.bash [Sample Name]"
	exit 1
fi

# Strips trailing slashes possibly at the end of $1 due to shell autocomplete.
target="${1%%/*}"

prevFile1=$(basename $(readlink in_padd))
prevFile2=$(basename $(readlink in_phox))
prevString1=${prevFile1#in_padd_}
prevString2=${prevFile2#in_phox_}

# Backs up old input files if they already exist.
if [[ -e in_padd ]]; then
    echo "Backing up in_padd to in_padd.bak"
    cp -L in_padd in_padd.bak
fi
if [[ -e in_phox ]]; then
    echo "Backing up in_phox to in_phox.bak"
    cp -L in_phox in_phox.bak
fi

# Creates new input files.
if [[ -e ${target} && -e ${target}/in_padd_${target} && -e ${target}/in_phox_${target} ]]; then
    echo "Target directory already has input files. Will be using them."
else 
	# Creates new folder. Copies existing input files into it and makes edits.
	if [[ -e in_padd && -e in_phox ]]; then
        echo "New sample name. Will create new input files by editing existing templates."
		mkdir -p ${target}
		if [[ ${prevString1} && ${prevString2} ]]; then
            # Can read sample name data from symlinks. Uses simple global search-and-replace.
			sed -e "s:${prevString1}:${target}:g" in_padd > ${target}/in_padd_${target}
			sed -e "s:${prevString2}:${target}:g" in_phox > ${target}/in_phox_${target}
        else
            # Cannot read existing sample name data. Try to edit in_padd and in_phox by section numbers instead.
            awk 'BEGIN {FS="::"} /^[^\*]*\(8\.?\).*::/ {print $1 ":: '${target}'" ($3? " ::" $3: "" ) ; next} {print}' in_padd > ${target}/in_padd_${target}
            awk 'BEGIN {FS="::"} /^[^\*]*\(3.2\.?\).*::/ {print $1 ":: '"${target}_sum.dat 1 2"'" ($3? " ::" $3 : ""); next} /^[^\*]*\(3.4\.?\).*::/ {print $1 ":: '"${target} p 1 2 3 d n r s"'" ($3? " ::" $3 : ""); next} /^[^\*]*\(3.8\.?\).*::/ {print $1 ":: 2" ($3? " ::" $3 : ""); next} {print}' in_phox > ${target}/in_phox_${target}
		fi
	else
        # No existing input files. Cannot create new ones w/o them.
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

