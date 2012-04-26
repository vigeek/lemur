#!/bin/bash
## Lemur - Dat Dare Code
## Currently:  Debian/Ubuntu only.

LOG_FILE="rambo.log"
LOG_PATH="log/"

## Accept parms: dry, update, interactive
if [ -z "$1" ] ; then
   echo -e "Error -> no action supplied"
   exit 1
fi

if [ ! -f "server.list" ] ; then
   echo -e "Error -> server.list does not exist"
   exit 1
fi

function log {
   if [ ! -z "$1" ] ; then
       echo -e "$1" >> $LOG_FILE
   fi
}

function log_server {
   if [ ! -z "$1" ] ; then
       echo -e "$1" >> $SERVER_PACKAGES
   fi
}

function run_remote {
   retval=`ssh $(echo $server | awk -F ":" '{print $1}') "$1"`
      if [ "$retval" -eq "1" ] ; then
         log "Error -> [$2] failed on $(echo $server | awk -F ":" '{print $1}')"
         return "1"
      fi
}

function run_updates {
   server_store()
   run_remote "sudo apt-get update &> /dev/null ; echo $?" "repository update"
      if [ $? -eq "0"] ; then
      else
         log "Failure to update server."
      fi

}

# Logic -> Initially generate a report of all packages installed.
# We then add newly updated items to the report for tracking.
function server_store {
	if [ -f "$SERVER_PACKAGES" ] ; then
      log_server "----------------------------------------------------------"
      log_server "$(date) - preparing to update..."
      run_remote "sudo apt-get upgrade --show-upgraded --dry-run | grep "Inst" | awk '{print $2 " " $3}'" "package upgrade" >> $SERVER_PACKAGES
   else
		touch $LOG_PATH/$SERVER_HOST
		run_remote "dpkg -l | sed 's/ii//g'" "Initial package pull for $C_SERV" > $SERVER_PACKAGES
	fi
}

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
