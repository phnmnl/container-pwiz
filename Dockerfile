#FROM suchja/wine:dev

MAINTAINER PhenoMeNal-H2020 Project ( phenomenal-h2020-users@googlegroups.com )

# unfortunately we later need to wait on wineserver.
# Thus a small script for waiting is supplied.
USER root
COPY waitonprocess.sh /scripts/
RUN chmod +x /scripts/waitonprocess.sh

## Freshen packages
RUN apt-get -y update
RUN apt-get -y upgrade

## Get dummy X11 server
RUN apt-get install -y xvfb winbind cabextract

# You might need a proxy:
# ENV http_proxy http://www-cache.ipb-halle.de:3128

# WINE does not like running as root
USER xclient

# get at least error information from wine
ENV WINEDEBUG -all,err+all

# Install Visual Runtime
RUN wine wineboot --init \
                && /scripts/waitonprocess.sh wineserver \
                && /usr/bin/xvfb-run winetricks --unattended vcrun2008 \
                && /scripts/waitonprocess.sh wineserver

# Install Visual Runtime
RUN wine wineboot --init \
                && /scripts/waitonprocess.sh wineserver \
                && /usr/bin/xvfb-run winetricks --unattended msxml3 \
                && /scripts/waitonprocess.sh wineserver

# Install .NET Framework 3.5sp1
RUN wine wineboot --init \
                && /scripts/waitonprocess.sh wineserver \
                && /usr/bin/xvfb-run winetricks --unattended dotnet35sp1 \
                && /scripts/waitonprocess.sh wineserver

# Install .NET Framework 4.0
RUN wine wineboot --init \
                && /scripts/waitonprocess.sh wineserver \
                && /usr/bin/xvfb-run winetricks --unattended dotnet40 dotnet_verifier \
                && /scripts/waitonprocess.sh wineserver

# Install CompassXport
RUN wine wineboot --init \
                && /scripts/waitonprocess.sh wineserver \
                && /usr/bin/xvfb-run wine "/tmp/CompassXport_3.0.9.2_Setup.exe" /S /v/qn \
                && /scripts/waitonprocess.sh wineserver

USER xclient

# Local copy:
# COPY pwiz-setup-3.0.9098-x86.msi /tmp

# Pull from TeamCity:
ADD http://teamcity.labkey.org:8080/repository/download/bt36/3391%20(9098)/pwiz-setup-3.0.9098-x86.msi?guest=1 /tmp/pwiz-setup-3.0.9098-x86.msi

RUN wine wineboot --init \
		&& /scripts/waitonprocess.sh wineserver \
		&& msiexec /i  /tmp/pwiz-setup-*.msi \
		&& /scripts/waitonprocess.sh wineserver

WORKDIR /data
ENTRYPOINT [ "wine", "/home/xclient/.wine/drive_c/Program Files/ProteoWizard/ProteoWizard 3.0.9098/msconvert.exe" ]

## Later try something like:
## wget 'http://teamcity.labkey.org:8080/repository/download/bt36/.lastSuccessful/pwiz-setup-'$(wget -O- http://teamcity.labkey.org:8080/repository/download/bt36/.lastSuccessful/VERSION?guest=1)'-x86.msi?guest=1'
