#!/bin/bash
# tps-report-interactive AKA tps-waive/tps-report wizard
# initial coding by rbiba

$dbg_flag

server=errata.engineering.redhat.com
baseurl=http://$server/errata/get_tps_txt

footprint_tps=variable-names.sh

if [ "$DEBUG" ]; then
  function tps-report {
    echo "DEBUG: would call: tps-report $@"
  }
  function tps-waive {
    echo "DEBUG: would call: tps-waive $@"
  }
fi

# If this is not a TPS directory, the user had better avoid running tps-report here as the link in the ET would be invalid:
if [ ! -r $footprint_tps ]; then
  echo "Error: you do not appear to be in a TPS working directory. Exiting." >&2
  exit 1
fi

# Try to guess the full errata ID from the CWD. Ask for it if it cannot be parsed:
errata=$(echo $PWD | sed 's|^.*/\([0-9:]*\)/.*$|\1|')
if [ "$errata" == "$PWD" ]; then
  read -p "The errata ID could not be parsed from your working directory. Enter it (YYYY:NNNNN): " errata
fi

#jobid=$(/mnt/qa/scratch/rbiba/tps-utils/tps-get-jobs $errata | grep $(uname -m) | awk -F ',' '{print $1}')
jobdata_raw=$(wget --timeout=20 --tries=2 -q -O - $baseurl/$errata)
if [ $? -ne 0 ]; then
  echo "Uh-oh, the Errata Tool is in trouble. This is what happened:"
  wget --timeout=10 --tries=1 -O - $baseurl/$errata
  echo "Please report this issue to eng-ops@redhat.com."
  exit 2
fi
jobdata=$(echo "$jobdata_raw" | grep ^$jobid,)
if [ $? -ne 0 ]; then
  echo "Error: Job $jobid was not found. Exiting." >&2
  exit 1
fi

read runid rhnqa errata <<<$(echo $jobdata | cut -d , --output-delimiter=" " -f 2,3,8)
[ $rhnqa == true ] && rhnqaswitch="--rhnqa" || rhnqaswitch=

text=${text:-"Ran manually successfully"}
result=${result:-"GOOD"}
echo "Reporting the result to the Errata Tool..."
tps-report $rhnqaswitch --errata "$errata" --jobid "$jobid" --runid "$runid" --result "$result" --logdir $(pwd) --text "$text"
