#!/bin/bash
## Lemur - Dat Dare Code
## Currently:  Debian/Ubuntu only.

# This is our main loop function

for server in `cat server.lst` ; do
       if [ "$(ping -s 1 -c 1 $(echo $server | awk  -F ":" '{print $2}') > /dev/null ; echo $?)" -eq "0" ] ; then
         SERVER_IP=`$(echo $server | awk -F ":"'{print $2}')`
         SERVER_HOST=`$(echo $server | awk -F ":"'{print $1}')`
         SERVER_PACKAGES=`$LOG_PATH/$SERVER_HOST/packages.lst`
         log "Preparing to update: $SERVER_HOST"
               server_store()
       fi
done
