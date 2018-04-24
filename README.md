# Proteowizard msconvert container

The first step in a metabolomics data processing workflow with Open
Source tools is the conversion to an open raw data format like
[mzML](https://github.com/HUPO-PSI/mzML/). One of the main routes to mzML-formatted data is using Open Source converter
msconvert developed by the Proteowizard team (Chambers et al. 2012),
which is one of the reference implementations for mzML. It can convert
to mzML from Sciex, Bruker, Thermo, Agilent, Shimadzu, Waters
and also the earlier file formats like mzData or mzXML.
Although Proteowizard was initially targeting LC/MS data, it can also readily
convert GC/MS data for example from the Waters GCT Premier or Agilent instruments.

## Building the Docker image

Please note that for licensing reasons we can not include all required
files in this repository. Upon container building, the Proteowizard files
will be downloaded from http://proteowizard.sourceforge.net/downloads.shtml and included
in the created container. By building this container, you agree
to all the vendor licenses that are shown at the above download links,
and also included in the container and Dockerfile repository. To build, please use

`docker build --tag="phnmnl/pwizphnmnl/pwiz--i-agree-to-the-vendor-licenses:latest" .`

Also note that the build is known to fail with Docker-1.9, make sure to use Docker-1.10 or above.

## Using the Docker image

After building the image, the conversion can be started with e.g.

`docker run -v $PWD:/data:rw phnmnl/phnmnl/pwiz--i-agree-to-the-vendor-licenses:latest /data/neg-MM8_1-A,1_01_376.d -o /data/ --mzML`

The currently tested vendor formats are:

* mzXML: `docker run -it -v $PWD:/data phnmnl/pwizphnmnl/pwiz--i-agree-to-the-vendor-licenses:latest threonine_i2_e35_pH_tree.mzXML`
* Bruker *.d: `docker run -it -v $PWD:/data phnmnl/phnmnl/pwiz--i-agree-to-the-vendor-licenses:latest neg-MM8_1-A,1_01_376.d`

## Galaxy usage

A rudimentary Galaxy node description is included as `msconvert.xml`,
it was obtained from the `msconvert.ctd` using
`python CTD2Galaxy/generator.py -i /vol/phenomenal/vmis/docker-pwiz/msconvert.ctd -m sample_files/macros.xml -o /vol/phenomenal/vmis/docker-pwiz/msconvert.xml`

## Licensing: APACHE LICENSE
Please see LICENSES/LICENSE, this Apache License Covers Core ProteoWizard Tools and Library. This software does, however, depend on other software libraries which place further restrictions on its use and redistribution, see below.

### ADDENDUM TO APACHE LICENSE

To the best of our ability we deliver this software to you under the Apache 2.0 License listed below (the source code is available in the ProteoWizard project). This software does, however, depend on other software libraries which place further restrictions on its use and redistribution. By accepting the license terms for this software, you agree to comply with the restrictions imposed on you by the license agreements of the software libraries on which it depends:

* AB Sciex WIFF Reader Library
* Agilent Mass Hunter Data Access Component Library
* Bruker CompassXtract
* Shimadzu SFCS
* Thermo-Scientific MSFileReader Library
* Waters Raw Data Access Component Library

NOTE: If you do not plan to redistribute this software yourself, then you are the "end-user" in the above agreements.
