#!/bin/bash
#
# Edits and generates resolution function file according to in_padd w/o overwriting it.
# Optional: Use command line parameter as the limit of energy (in meV). 
# Will cut the file from - to +limit. If not specified, 20 is used as default.
# e.g.: ./res_func.bash 14.4 	# Will generate a *_res_sum.dat from -14.4 to +14.4 meV.

file1=$(basename $(readlink in_padd))
string1=${file1#in_padd_}
resString="${string1}_d9_in_padd"

if [[ "$1" -gt 0 ]]; then
	limit="$1"
else
	limit=20
fi

sed -e 's: d11 : d9 :g' -e 's:'"${string1}"':'"${string1}"'_d9:g' in_padd > "${resString}"
padd --infile="${resString}" --nographics
awk '{ if ($1 <= '"${limit}"' && $1 >= '"-${limit}"') print }' "${string1}_d9_sum.dat" > "${string1}_res_sum.dat"


