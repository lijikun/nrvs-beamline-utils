#!/bin/bash
#
# Integrates and plots density of states (DOS). 
#
# Outputs a file named [Sample Name]_dos_int.dat and plots it using gnuplot.
#
# Will use resolution function to fit the inelastic peak, 
# if a [Sample Name]_res_sum.dat file is found.
# Otherwise, a Gaussian function will be used instead.
# Adding --Gau flag will force the use of Gaussian function.
#
# Defaults to cm^-1 as energy unit. Optionally, use --meV for meV energy unit.
#
## ./phox_plot.bash		# Generates file and plot with cm^-1 as energy unit.
## ./phox_plot.bash --Gau	# Forces Gaussian fit for inelastic peak.
## ./phox_plot.bash --meV	# With meV as energy unit.

file2=$(basename $(readlink in_phox))
string2=${file2#in_phox_}

factor=8.06554
unitString='cm^{-1}'
resString=
for i in $@; do
    if [[ $i == '--meV' ]]; then
        factor=1.0;
	unitString='meV'
    fi
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


awk 'BEGIN {fac = '${factor}'; total = 0}; \
	NR==1 {total = $2; x1 = $1; print ($1 * fac) "\t" $2 "\t" $3 "\t" total}; \
 	NR!=1 {total += ($2 * ($1 - x1)); x1 = $1; print ($1 * fac) "\t" $2 "\t" $3 "\t" total}' ${dosfile} > ${intfile}
gnuplot --persist -e 'set ytics nomirror; set xtitle "Energy ('${unitString}')"; \
	plot "'${intfile}'" using 1:2:3 with yerrorbars axis x1y1 title "'${string2}' PVDOS", \
	"'${intfile}'" using 1:4 with lines axis x1y2 title "Integral"'

