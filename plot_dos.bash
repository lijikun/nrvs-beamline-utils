#!/bin/bash
#
# Integrates and plots density of states (DOS). 
#
# Outputs a file named [Sample Name]_dos_int.dat and plots it using gnuplot.
#
# Defaults to cm^-1 as energy unit. Optionally, use --meV for meV energy unit.
#
## ./plot_dos.bash		    # Generates file and plot with cm^-1 as energy unit.
## ./plot_dos.bash --meV	# With meV as energy unit.

file2=$(basename $(readlink in_phox))
string2=${file2#in_phox_}

factor=8.06554
unitString='cm^{-1}'
for i in $@; do
    if [[ $i == '--meV' ]]; then
        factor=1.0;
	    unitString='meV'
    fi
done
        
if [[ -e "${string2}_dos.dat" ]]; then
	dosfile="${string2}_dos.dat"
else 
	if [[ -e "${string2}/${string2}_dos.dat" ]]; then
		dosfile="${string2}/${string2}_dos.dat"
	else
		echo "Cannot find DOS file!"
		exit 1
	fi
fi
intfile="${dosfile/_dos.dat/_dos_int.dat}"

awk 'BEGIN {fac = '${factor}'; total = 0}; \
	NR==1 {total = $2; x1 = $1; print ($1 * fac) "\t" $2 "\t" $3 "\t" total}; \
 	NR!=1 {total += ($2 * ($1 - x1) * 0.001); x1 = $1; print ($1 * fac) "\t" $2 "\t" $3 "\t" total}' ${dosfile} > ${intfile}
gnuplot --persist -e 'set ytics nomirror; set xlabel "Energy ('${unitString}')"; plot "'${intfile}'" using 1:2:3 with yerrorbars lw 2 axis x1y1 title "'${string2}' PVDOS", "'${intfile}'" using 1:4 with lines lw 2 axis x1y2 title "Integration"'

