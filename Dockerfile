FROM suchja/wine:dev

MAINTAINER PhenoMeNal-H2020 Project ( phenomenal-h2020-users@googlegroups.com )

LABEL Description="Convert LC/MS or GC/MS RAW vendor files to mzML."

# unfortunately we later need to wait on wineserver.
# Thus a small script for waiting is supplied.
USER root
COPY waitonprocess.sh /scripts/
RUN chmod a+rx /scripts/waitonprocess.sh

## Freshen packages
RUN apt-get -y update

## Get dummy X11 server
RUN apt-get install -y xvfb winbind cabextract

# Patch wintricks
RUN apt-get install wget patch

WORKDIR /usr/local/bin
RUN wget -O /tmp/winetricks.patch "https://github.com/Winetricks/winetricks/commit/a5e32a8a4329ec663690a4a8cf40e3ab071aad2d.patch"
RUN patch -u -p1 winetricks /tmp/winetricks.patch
RUN mv winetricks winetricks_old
RUN wget -O winetricks "https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks"
RUN chmod 755 winetricks

# WINE does not like running as root
USER xclient
WORKDIR /home/xclient

# BUG: Download msxml3 manually
RUN wget -O /tmp/cnet.tmp 'http://download.cnet.com/Microsoft-XML-Parser-MSXML-3-0-Service-Pack-7-SP7/3000-7241_4-10731613.html'
RUN export ln="$(cat /tmp/cnet.tmp | grep -n 'Download Now' | sed -e 's/\:.*//')" \
		&& export ln=$(expr $ln - 3) \
		&& export dl="$(sed -n -e "$ln,$ln p" /tmp/cnet.tmp | perl -pe "s/.*href\=\'//" | perl -pe "s/\'.*//")" \
		&& wget -O /tmp/cnet2.tmp "$dl"
RUN sleep 10
RUN export dl2="$(cat /tmp/cnet2.tmp | grep msxml3 | grep data-dw-wrap | perl -pe "s/.*href\=\"//" | perl -pe "s/\".*//")" \
		&& mkdir -p .cache/winetricks/msxml3 \
		&& wget -O .cache/winetricks/msxml3/msxml3.msi --user-agent="Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:58.0) Gecko/20100101 Firefox/58.0" "$dl2"

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

# Pull from TeamCity
USER xclient
ADD http://teamcity.labkey.org:8080/repository/download/bt36/3391%20(9098)/pwiz-setup-3.0.9098-x86.msi?guest=1 /tmp/pwiz-setup.msi
USER root
RUN chmod 755 /tmp/pwiz-setup.msi
RUN echo -n "3.0.9098" > /tmp/pwiz.version

# Pull linux CLI from BioDocker
# also see: https://raw.githubusercontent.com/BioContainers/containers/master/proteowizard/3_0_9740/Dockerfile
USER root
ENV PWIZ_LINUX="pwiz-bin-linux-x86_64-gcc48-release-3_0_9740"
RUN curl -L -o /tmp/${PWIZ_LINUX}.zip https://github.com/BioDocker/software-archive/releases/download/proteowizard/${PWIZ_LINUX}.zip
WORKDIR /tmp
RUN unzip ${PWIZ_LINUX}.zip
RUN install -m755 /tmp/${PWIZ_LINUX}/*[^xsd] /usr/local/bin/

USER xclient
RUN wine wineboot --init \
		&& /scripts/waitonprocess.sh wineserver \
		&& msiexec /i /tmp/pwiz-setup.msi \
		&& ln -s "/home/xclient/.wine/drive_c/Program Files/ProteoWizard/ProteoWizard $(cat /tmp/pwiz.version)" "/home/xclient/.wine/drive_c/Program Files/ProteoWizard/ProteoWizard" \
		&& xvfb-run wine "/home/xclient/.wine/drive_c/Program Files/ProteoWizard/ProteoWizard/msconvert.exe" \
		&& /scripts/waitonprocess.sh wineserver

# Set up working directory and permissions to let user xclient save data
USER root
RUN mkdir /data
RUN chmod 777 /data
RUN chown xclient:xusers /data
RUN chown xclient:xusers /
WORKDIR /data

#USER xclient

#ENTRYPOINT [ "wine", "/home/xclient/.wine/drive_c/Program Files/ProteoWizard/ProteoWizard/msconvert.exe" ]
#ENTRYPOINT [ "/bin/bash", "-c" ]

## If you need a proxy during build, don't put it into the Dockerfile itself:
## docker build --build-arg http_proxy=http://www-cache.ipb-halle.de:3128/  -t phnmnl/pwiz:3.0.9098-0.1 .


