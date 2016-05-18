# Proteowizard msconvert Docker Buildfile

The first step in a metabolomics data processing workflow with Open
Source tools is the conversion to an open raw data format like
[mzML]:https://github.com/HUPO-PSI/mzML/ .

One of the main routes to mzML-formatted data is using Open Source converter
msconvert developed by the Proteowizard team (Chambers et al. 2012), 
which is one of the reference implementations for mzML. It can convert 
to mzML from Sciex, Bruker, Thermo, Agilent, Shimadzu, Waters 
and also the earlier file formats like mzData or mzXML.

Although Proteowizard was initially targeting LC/MS data, it can also readily 
convert GC/MS data for example from the Waters GCT Premier or Agilent instruments.

Please note that for licensing reasons we can not include all required 
files in this repository. Please head over to http://proteowizard.sourceforge.net/downloads.shtml
and place the installer pwiz-setup-3.0.9098-x86.msi in this directory.

After building the image, the conversion can be started with e.g. 

`docker run -v $PWD:/data phnmnl/pwiz:3.0.9098-0.1 /data/neg-MM8_1-A,1_01_376.d/
/data/neg-MM8_1-A,1_01_376.mzML`

The currently tested vendor formats are:

* mzXML: `docker run -it -v $PWD:/data phnmnl/pwiz:3.0.9098-0.1 threonine_i2_e35_pH_tree.mzXML`
* Bruker *.d: `docker run -it -v $PWD:/data phnmnl/pwiz:3.0.9098-0.1 neg-MM8_1-A,1_01_376.d`










