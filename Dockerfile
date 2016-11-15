FROM biocontainers/proteowizard:latest

MAINTAINER PhenoMeNal-H2020 Project ( phenomenal-h2020-users@googlegroups.com )

LABEL Description="Convert LC/MS or GC/MS RAW vendor files to mzML."

#USER xclient
USER biodocker

#ENTRYPOINT [ "wine", "/home/xclient/.wine/drive_c/Program Files/ProteoWizard/ProteoWizard/msconvert.exe" ]

