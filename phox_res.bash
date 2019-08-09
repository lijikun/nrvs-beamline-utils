#!/bin/bash
#
# Runs phox to generate the density of states (DOS) file,
# named [Sample Name]_dos.dat
#
# Will use resolution function to fit the inelastic peak, 
# if a [Sample Name]_res_sum.dat file is found.
# Otherwise, a Gaussian function will be used instead.
# Adding --Gau flag will force the use of Gaussian function.
#
# Usage:
## ./phox_res.bash		    # Generates DOS file.
## ./phox_res.bash --Gau	# Forces Gaussian fit for inelastic peak.

file2=$(basename $(readlink in_phox))
string2=${file2#in_phox_}

resString=
for i in $@; do
    if [[ $i == '--Gau' ]]; then
        resString=2;
    fi
done
        
if [[ ! $resString ]]; then 
    if [[ -e "${string2}_res_sum.dat" ]]; then
        resString="${string2}_res_sum.dat 1 2 process"
    else
        if [[ -e "${string2}/${string2}_res_sum.dat" ]]; then
            resString="${string2}/${string2}_res_sum.dat 1 2 process"
        else
            resString="2"
        fi
    fi
fi
awk 'BEGIN {FS="::"} /^[^\*]*\(3.8\.?\).*::/ {print $1 ":: '"${resString}"'" ($3? " ::" %3: ""); next} {print}' in_phox > ${string2}_res_in_phox
# sed -i --follow-symlinks -e 's|^[[:space:]]*(3.8).*| (3.8) shape, 2=Gaussian :: '"${resString}"'|g' in_phox
phox --infile=${string2}_res_in_phox --nographics

