#FROM mono:3.10-onbuild
FROM mono:5.20.1.19

ENV STEAMCMDDIR /home/steam/steamcmd

# Install, update & upgrade packages
# Create user for the server
# This also creates the home directory we later need
# Clean TMP, apt-get cache and other stuff to make the image smaller
# Create Directory for SteamCMD
# Download SteamCMD
# Extract and delete archive
RUN set -x \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends --no-install-suggests \
		lib32stdc++6 \
		lib32gcc1 \
		wget \
		ca-certificates \
    git \
	&& useradd -m steam \
	&& su steam -c \
		"mkdir -p ${STEAMCMDDIR} \
		&& cd ${STEAMCMDDIR} \
		&& wget -qO- 'https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz' | tar zxf -" \
        && apt-get clean autoclean \
        && apt-get autoremove -y \
        && rm -rf /var/lib/{apt,dpkg,cache,log}/

RUN mkdir /build ; \
    mkdir /app ; \
    cd /build ; \
    git clone https://github.com/Regalis11/Barotrauma.git ; \
    mkdir -p /build/Barotrauma/Barotrauma/BarotraumaShared/Content

COPY ./game/Content /build/Barotrauma/Barotrauma/BarotraumaShared/Content

RUN cd /build/Barotrauma ; \
    nuget restore Barotrauma_Solution.sln ; \
    msbuild Barotrauma_Solution.sln /property:Configuration=ReleaseLinux /property:Platform=x64 ; \
    mv /build/Barotrauma/Barotrauma/bin/ReleaseLinux/* /app ; \
    cd /app ; \
    rm -rf /build  
# Switch to user steam
#USER steam

#WORKDIR $STEAMCMDDIR

# VOLUME $STEAMCMDDIR

#RUN cd /home/steam/steamcmd/linux32/; ./steamcmd ; mkdir -p /root/.steam/sdk64/; cp /home/steam/steamcmd/linux64/steamclient.so /root/.steam/sdk64/ ; exit 0
RUN cd /home/steam/steamcmd/linux32/ ; \
    ./steamcmd ; \
    cp /home/steam/steamcmd/linux64/steamclient.so /lib/x86_64-linux-gnu/ ; \
    exit 0

WORKDIR /app

CMD [ "/app/DedicatedServer" ]
