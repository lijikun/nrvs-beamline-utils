# Utility Scripts for NRVS Data Processing

A bunch of Bash scripts. Requires [PHOENIX](https://www.nrixs.com/products.html), which in turn requires [MDA utilities](https://epics.anl.gov/bcda/mdautils/) for data generated at [APS](https://www.aps.anl.gov/) in ANL. Also requires bash, sed, awk and gnuplot. [SciPhon](https://originslab.uchicago.edu/Software-and-Facilities) is optional but strongly recommended.

## What Individual Scripts Do

The scripts allow some parameters. Usage notes are included in the scripts themselves.

* `switch_sample.bash` creates folders and symlinks for a sample, and automatically edits the input files for PHOENIX such that it generates output files with correct names.

* `res_func.bash` automatically generates an edited input file and calls `padd` to generate a resolution function file from forward scattering data.

* `phox_plot.bash` automatically edits inputs to make use of the resolution function, calls `phox` to generate the density of states (DOS) data, then integrates the DOS, and finally generates a plot containing the DOS and integration.

## Getting the Scripts

* Download the `.tar.gz` archive for the newest release. Extract all files, including the Example folder and symlinks, to the same directory where the `scans/` subdirectory is located:

    ```
    wget https://github.com/lijikun/nrvs-beamline-utils/archive/v1.0.tar.gz
    tar -xvf v1.0beta3.tar.gz --strip-components=1
    ```
    
  This will provide sample in_padd and in_phox files which one can edit as necessary.
  
* Alternatively, if you only need the bash scripts:

    ```tar -xvf v1.0beta2.tar.gz --wildcards '*.bash" --strip-components=1```
    
* To use the latest development version, clone this repo and copy the scripts and/or examples to where your data files are.

## General Data Processing Step-by-Step

* Acquire your experimental data. Raw scans should be stored in the `scans/` subdirectory, e.g. `scans/scan_0003.mda`.

* Use the `switch_sample.bash` script to name a sample, setting up the proper folder and symlinks:

    ```./switch_sample.bash Sample1```

* Edit the (15.1) section of the `in_padd` file, such that the correct raw scan data files are included.

* Run `padd` to generate the sum file `[Sample Name]_sum.dat`.

* (Optional) Run `./res_func.bash` to generate the resolution function, which will be named `[Sample Name]_res_sum.dat`.

* (Optional) Using SciPhon and the generated files above, determine the temperature and background noise level for the spectra. For its usage, one should consult [this paper](https://journals.iucr.org/s/issues/2018/05/00/fv5085/).

* Edit the `in_phox` file such that it contains the correct temperature and background noise.

* Run `./phox_plot.bash` to generate the density of state (DOS) file, and a plot will be shown as well.

* (Optional) Use `switch_sample.bash` again to switch to another sample, or just collect the files in the proper directory.

  * `./switch_sample.bash Sample2` (another existing or new sample name) collects files for Sample1 into the `Sample1/` directory, and sets up the `Sample2/` directory for a second sample.

  * `./switch_sample.bash Sample1` (the same sample name) merely collects the files into the folder without setting up for another sample. `in_padd` and `in_phox` symlinks will still be linked to the files for this sample.

## Tips for Transferring Data

* To transfer this whole directory structure, it is recommended to use
    
    ```rsync -avz --copy-unsafe-links source destination``` 
    
    to perserve the directory and symlink structure. 
    
* Also, one should use
    
    ```tar -czvhf myfile.tar.gz mydir``` 
    
    to dereference symlinks while making archives.
