FROM i386/debian:stretch-backports

################################################################################
### set metadata
ENV TOOL_NAME=msconvert
ENV TOOL_VERSION=phenomenal_2018_03_23
ENV CONTAINER_VERSION=1.0
ENV CONTAINER_GITHUB=https://github.com/phnmnl/container-pwiz

LABEL version="${CONTAINER_VERSION}"
LABEL software.version="${TOOL_VERSION}"
LABEL software="${TOOL_NAME}"
LABEL base.image="i386/debian:stretch-backports"
LABEL description="Convert LC/MS or GC/MS RAW vendor files to mzML."
LABEL website="${CONTAINER_GITHUB}"
LABEL documentation="${CONTAINER_GITHUB}"
LABEL license="${CONTAINER_GITHUB}"
LABEL tags="Metabolomics"

# we need wget, bzip2, wine from winehq, 
# xvfb to fake X11 for winetricks during installation,
# and winbind because wine complains about missing 
RUN apt-get update && \
    apt-get -y install wget gnupg && \
    echo "deb http://dl.winehq.org/wine-builds/debian/ stretch main" >> \
      /etc/apt/sources.list.d/winehq.list && \
    wget http://dl.winehq.org/wine-builds/Release.key -qO- | apt-key add - && \
    apt-get update && \
    apt-get -y --install-recommends install \
      bzip2 unzip curl \
      winehq-devel \
      winbind \
      xvfb \
      cabextract \
      && \
    apt-get -y clean && \
    rm -rf \
      /var/lib/apt/lists/* \
      /usr/share/doc \
      /usr/share/doc-base \
      /usr/share/man \
      /usr/share/locale \
      /usr/share/zoneinfo \
      && \
    wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
      -O /usr/local/bin/winetricks && chmod +x /usr/local/bin/winetricks
ENV WINEARCH win32
WORKDIR /root/
ADD waitonprocess.sh /root/waitonprocess.sh
RUN chmod +x waitonprocess.sh
# wineserver needs to shut down properly!!! 
ENV WINEDEBUG -all,err+all
RUN winetricks -q win7 && ./waitonprocess.sh wineserver
RUN xvfb-run winetricks -q vcrun2008 corefonts && ./waitonprocess.sh wineserver
RUN xvfb-run winetricks -q dotnet452 && ./waitonprocess.sh wineserver
# download ProteoWizard and extract it to C:\pwiz
# Pull latest version from TeamCity
RUN wget -O /tmp/pwiz.version 'https://teamcity.labkey.org/repository/download/bt36/.lastSuccessful/VERSION?guest=1'
RUN mkdir /root/.wine/drive_c/pwiz && \
    wget https://teamcity.labkey.org/repository/download/bt36/561098:id/pwiz-bin-windows-x86-vc120-release-`cat /tmp/pwiz.version | tr " " "_"`.tar.bz2?guest=1 -qO- | \
      tar --directory=/root/.wine/drive_c/pwiz -xj

# put C:\pwiz on the Windows search path
ENV WINEPATH "C:\pwiz"
#ENV DISPLAY :0

# Set up working directory and permissions to let user xclient save data
RUN mkdir /data
WORKDIR /data

CMD ["wine", "msconvert" ]


## If you need a proxy during build, don't put it into the Dockerfile itself:
## docker build --build-arg http_proxy=http://www-cache.ipb-halle.de:3128/  -t phnmnl/pwiz:3.0.9098-0.1 .
