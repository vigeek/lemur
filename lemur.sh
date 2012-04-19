## Lemur - Dat Dare Code
##

## Accept parms: dry, update
##

LOG_FILE="rambo.log"
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
      fi
}

function run_updates {
   for server in `cat server.list` ; do
      # ping -s 1 -c 1 $REMOTE > /dev/null; echo $?
       if [ "$(ping -s 1 -c 1 $(echo $server | awk  -F ":" '{print $2}') > /dev/null ; echo $?)" -eq "0" ] ; then
         log "Preparing to update: $(echo $server | awk -F ":"'{print $2}')"
	      run_remote "sudo apt-get update &> /dev/null ; echo $?" "repository update"
       fi
   done
}

run_updates
