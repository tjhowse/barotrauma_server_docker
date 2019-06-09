FROM mono:5.20.1.19

ENV STEAMCMDDIR /home/steam/steamcmd

# This is based on cm2network/steamcmd.
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

# The git hash below is v0.9.0.4
RUN mkdir /build ; \
    mkdir /app ; \
    cd /build ; \
    git clone https://github.com/Regalis11/Barotrauma.git ; \
    cd ./Barotrauma ; \
    git checkout bea7b58ff3e2c581d4589d4fbb78b1563c2913aa ; \
    mkdir -p /build/Barotrauma/Barotrauma/BarotraumaShared/Content

# The game directory must be a copy of the purchased Barotrauma.
COPY ./game/Content /build/Barotrauma/Barotrauma/BarotraumaShared/Content

RUN cd /build/Barotrauma ; \
    nuget restore Barotrauma_Solution.sln ; \
    msbuild Barotrauma_Solution.sln /property:Configuration=ReleaseLinux /property:Platform=x64 ; \
    mv /build/Barotrauma/Barotrauma/bin/ReleaseLinux/* /app ; \
    cd /app ; \
    rm -rf /build ; \
    nuget locals all -clear

RUN cd /home/steam/steamcmd/linux32/ ; \
    ./steamcmd ; \
    cp /home/steam/steamcmd/linux64/steamclient.so /lib/x86_64-linux-gnu/ ; \
    exit 0

WORKDIR /app

CMD [ "/app/DedicatedServer" ]
