# Using debian amd64 latest build
# https://hub.docker.com/_/debian
FROM debian:latest

## Debian Linux post setup....
# Update and upgrade Linux:
RUN apt-get update && apt-get upgrade -y

# Set up locales
RUN apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
	&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

# General stuff way may need:
RUN apt-get update && apt-get install -qq -y wget curl unzip apt-transport-https gpg bash jq


## HyTale Server
# https://support.hytale.com/hc/en-us/articles/45326769420827-Hytale-Server-Manual#server-setup
# https://hytale.game/en/create-server-hytale-guide/

# Java JRE 65 Adoptium
# https://adoptium.net/en-GB/installation/linux
RUN wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor | tee /etc/apt/trusted.gpg.d/adoptium.gpg > /dev/null
RUN echo "deb https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list
RUN apt-get update && apt-get install -qq -y temurin-25-jdk



# Hytale Server Preparations:
RUN mkdir /app
WORKDIR /app
RUN wget https://downloader.hytale.com/hytale-downloader.zip
RUN unzip hytale-downloader.zip
RUN rm hytale-downloader.zip
RUN chmod +x hytale-downloader-linux-amd64

# The following command may require authentication from Hytale. Follow the instructions on the screen.
RUN ./hytale-downloader-linux-amd64

RUN unzip 20*.zip
RUN chmod +x start.sh
COPY launch.sh /app/launch.sh
COPY tokens.sh /app/tokens.sh
RUN chmod +x launch.sh
RUN chmod +x tokens.sh



# Cleanup...
RUN rm *.exe
RUN rm *.bat

# Hytale server port
EXPOSE 5520

# Setup container's entry point to the launch script:
ENTRYPOINT ["/app/launch.sh"]




