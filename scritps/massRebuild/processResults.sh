RESULTS_DIR=${1}
# without bugzilla setup logs are just scanned  and summary printed. Both those vars are passed to submitBug.py	
export BUGZILLA_API_KEY=${2}
export FEATURE_BUG_ID=${3}
# see also variable URLS true/false
# see TASK_URL for usage. Tahat one is good with grep -A1
#   to double check runing tasks: TASK_URL=true sh processResults.sh  results  | grep running -A1
# see UPDATE_RUNNING=true for a feature which will update running tasks
#   this fill update status of all "runnign" jobs, as those could be simply stuck.
#   check the few trouble makers, whcih could get broken earlier, be seeing stderr

## resolve folder of this script, following all symlinks,
## http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in
SCRIPT_SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SCRIPT_SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  SCRIPT_DIR="$( cd -P "$( dirname "$SCRIPT_SOURCE" )" && pwd )"
  SCRIPT_SOURCE="$(readlink "$SCRIPT_SOURCE")"
  # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
  [[ $SCRIPT_SOURCE != /* ]] && SCRIPT_SOURCE="$SCRIPT_DIR/$SCRIPT_SOURCE"
done
readonly SCRIPT_DIR="$( cd -P "$( dirname "$SCRIPT_SOURCE" )" && pwd )"


function fillBug() {
  package="$1"
  urls="$2"
  copr="https://copr.fedorainfracloud.org/coprs/jvanek/java17/"
  python $SCRIPT_DIR/submitBug.py "$package" "$urls"  $copr #copr is optional, no quotes
  sleep 120 #to not get ban from bugzilla
}

function pout() {
  local name=${1}
  local status=${2}
  local alignment=${3}
  if [ "0$alignment" -le 0 ] ; then
    echo ${name} ${status}
  else
    printf "%-${alignment}s %s\n" "${name}" "${status}"
  fi
}
##################################
## main iteration over all logs ##
##################################
for logFile in `ls ${RESULTS_DIR} | sort ` ; do
# grep in above ls for some testing pkg(s). eg |grep forbidden-apis
  pkg=`echo $logFile | sed "s;.log$;;g"`
  log=$RESULTS_DIR/$logFile
  cat $log | tail -n 1 | grep -q success
  s1=$?
  cat $log | tail -n 1 | grep -q failed
  f1=$?
  cat $log | grep -q "retired. The action has stopped."
  r1=$?
  urls=`cat $log | grep -e "https:.*koji.*" | sed "s/.*https:/https:/"`
  if [ $s1 -eq 0 ] ; then
    pout "$pkg" "passed!" 30
  elif [ $r1 -eq 0 ] ; then
    pout "$pkg" "retired" 30
  elif [ $f1 -eq 0 ] ; then
    pout "$pkg" "FAILED" 30
    if [ ! "x$BUGZILLA_API_KEY" = "x" -a ! "x$FEATURE_BUG_ID" = "x" ] ; then
     echo filling bug > /dev/null
     fillBug "$pkg" "$urls"
    else
     echo no bug > /dev/null
    fi
  else
    pout "$pkg" "running?" 30
    if [ ! "x$TASK_URL" == "x" ] ;  then
      a=`cat $log | grep "Task info: https://koji.fedoraproject.org/koji/taskinfo?taskID="`
      pout "  $a"  "" 0
    fi
    if [ ! "x$UPDATE_RUNNING" == "x" ] ;  then
      taskId=`cat $log | grep "Task info: https://koji.fedoraproject.org/koji/taskinfo?taskID=" | sed "s/.*taskID=//g"`
      koji watch-task $taskId  >> $RESULTS_DIR/${pkg}.log &
      sleep 5
    fi
  fi
  if [ "x$URLS" = "xtrue" ] ; then
    echo "$urls"
  fi
done
