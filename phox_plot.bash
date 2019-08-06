#!/bin/bash
#
# Integrates and prints density of states (DOS), 
# generateing a file named [Sample Name]_dos_int.dat and plots it using gnuplot.
# Defaults to cm^-1 as energy unit. Optionally, use --meV for meV energy unit, i.e.:
## ./phox_plot.bash		# Generates file and plot with cm^-1 as energy unit.
## ./phox_plot.bash --meV	# Generates file and plot with meV as energy unit.

file2=$(basename $(readlink in_phox))
string2=${file2#in_phox_}

if [[ $1 == '--meV' ]]; then
	factor=1.0;
else
	factor=8.06554
fi

if [[ -e "${string2}_res_sum.dat" ]]; then
	resString="${string2}_res_sum.dat 1 2 process"
else
	if [[ -e "${string2}/${string2}_res_sum.dat" ]]; then
		resString="${string2}/${string2}_res_sum.dat 1 2 process"
	else
		resString="2"
	fi
fi
sed -i --follow-symlinks -e 's|^[[:space:]]*(3.8).*| (3.8) shape, 2=Gaussian :: '"${resString}"'|g' in_phox
phox --nographics

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


awk 'BEGIN {total = 0; fac = '${factor}'} {total += $2; print ($1 * fac) "\t" $2 "\t" $3 "\t" total}' ${dosfile} > ${intfile}
gnuplot --persist -e 'set ytics nomirror; plot "'${intfile}'" using 1:2:3 with yerrorbars axis x1y1, "'${intfile}'" using 1:4 with lines axis x1y2'

