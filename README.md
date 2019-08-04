# Utility Scripts for NRVS Data Processing

Requires [PHOENIX](https://www.nrixs.com/products.html), which in turn requires [MDA utilities](https://epics.anl.gov/bcda/mdautils/) for data generated at ANL. Also requires bash, sed, awk and gnuplot. Optionally, [SciPhon](https://originslab.uchicago.edu/Software-and-Facilities) is also recommended.

## General Usage

* Download the `.tar.gz` archive for the newest release. Extract all files, including the Example folder and symlinks, to the same directory where the `scans/` subdirectory is located.

* Collect your data. Raw scans should be stored in the `scans/` subdirectory, e.g. `scans/scan_0003.mda`.

* Use the `switch_sample.bash` script to name a sample, setting up the proper folder and symlinks, e.g.:

    ```./switch_sample.bash Sample1```

* Edit the end of the `in_padd` file, such that the corrected raw files are included.

* Run `padd` to generate the sum file.

* (Optional) Run `./res_func.bash` to generate the resolution function.

* Edit the `in_phox` file such that it contains the correct temperature and background.

* Run `./phox_plot.bash` to generate the density of state (DOS) file, and a plot will be shown as well.

* (Optional) Use `switch_sample.bash` again to switch to another sample, or just collect the files in the proper directory.

  * `./switch_sample.bash Sample2` collects files for Sample1 into the `Sample1/` directory, and sets up the `Sample2/` directory for a second sample.

  * `./switch_sample.bash Sample1` merely collects the files into the folder without setting up for another sample.

* (Optional) To transfer this whole directory structure, it is recommended to use
    ```rsync -avz --copy-unsafe-links source destination```
     
to perserve the directory and symlink structure. Also, one can use
    ```tar -czvhf myfile.tar.gz mydir```

to dereference symlinks while making archives.
