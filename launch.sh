#!/bin/bash

# This assumes you've copied the following files out to your PWD:
# serversettings.xml: Obvious
# clientpermissions.xml: Stores permissions you've granted to players
# bannedplayers.txt: Obvious
# ServerLogs: Obvious, though the dedicated server doesn't current log to a file...

docker run --rm -it \
  -v ${PWD}/serversettings.xml:/app/serversettings.xml \
  -v ${PWD}/clientpermissions.xml:/app/Data/clientpermissions.xml \
  -v ${PWD}/bannedplayers.txt:/app/Data/bannedplayers.txt \
  -v ${PWD}/ServerLogs:/app/ServerLogs \
  -p 27015:27015/udp \
  -p 27016:27016/udp \
  tjhowse/barotrauma $1
  
