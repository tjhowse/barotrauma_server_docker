FROM mono:5.20.1.19 AS builder

ENV STEAMCMDDIR /home/steam/steamcmd

# The game directory must be a copy of the purchased Barotrauma.
COPY ./game/Content /build/Barotrauma/BarotraumaShared/Content

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
        && rm -rf /var/lib/{apt,dpkg,cache,log}/ ; \
    cd /home/steam/steamcmd/linux32/ ; \
    ./steamcmd ; \
    cd /build ; \
    git init ; \
    git remote add origin https://github.com/Regalis11/Barotrauma.git ; \
    git pull ; \
    git checkout e79c980a5cf3f3a194a1df0d37f4875a8c866391 ; \
    nuget restore Barotrauma_Solution.sln ; \
    msbuild Barotrauma_Solution.sln /property:Configuration=ReleaseLinux /property:Platform=x64 ; \
    nuget locals all -clear

FROM mono:5.20.1.19-slim as runner

COPY --from=builder /build/Barotrauma/bin/ReleaseLinux /app
COPY --from=builder /home/steam/steamcmd/linux64/steamclient.so /lib/x86_64-linux-gnu/

WORKDIR /app

CMD [ "/app/DedicatedServer" ]
