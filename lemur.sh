#!/bin/bash
## Lemur - Dat Dare Code
## Currently:  Debian/Ubuntu only.

## Accept parms: dry, update, interactive

LOG_FILE="rambo.log"
LOG_PATH="log/"

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

function run_remote {
   retval=`ssh $(echo $server | awk -F ":" '{print $1}') "$1"`
      if [ "$retval" -eq "1" ] ; then
         log "Error -> [$2] failed on $(echo $server | awk -F ":" '{print $1}')"
         return "1"
      fi
}

function run_updates {
   for server in `cat server.list` ; do
       if [ "$(ping -s 1 -c 1 $(echo $server | awk  -F ":" '{print $2}') > /dev/null ; echo $?)" -eq "0" ] ; then
         log "Preparing to update: $(echo $server | awk -F ":"'{print $2}')"
	      run_remote "sudo apt-get update &> /dev/null ; echo $?" "repository update"
            if [ $? -eq "0" ] ; then
               run_remote "sudo apt-get upgrade --show-upgraded --dry-run | grep "Inst" | awk '{print $2 " " $3}'" "package upgrade" &> /tmp/return.txt
            fi
       fi
   done
}

# Logic -> Initially generate a report of all packages installed.
# We then add newly updated items to the report for tracking.
function server_store {
	C_SERV=`cat server.list | awk -F ":" '{print $1}') "$1" > /dev/null`
	if [ -f "$LOG_PATH/$C_SERV" ] ; then
		# Exists, proceed updating.
	else
		touch $LOG_PATH/$C_SERV
		run_remote "dpkg -l | sed 's/ii//g'" "Initial package pull for $C_SERV" 
	fi
}

run_updates
