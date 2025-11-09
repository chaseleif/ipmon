#! /usr/bin/env bash

# domains to ping to test connectivity
domains=(8.8.8.8
          4.2.2.2
          8.8.4.4
          4.1.1.1)

# try to ping and return whether it was successfull
try() {
  domaini=$((domaini+1))
  [ "$domaini" -eq "${#domains[@]}" ] && domaini=0
  ping -c1 -q "${domains[$domaini]}" >/dev/null 2>&1 && return 0 || return 1
}

# log the signal to terminate or interrupt and exit
signal() {
  echo "monitor received $1 ~ $(date)" && exit
}
trap 'signal SIGTERM' SIGTERM
trap 'signal SIGINT' SIGINT

# if we have an outages file with a total outage time
if grep -q "Total" "outages" 2>/dev/null ; then
  # retain the total outage time from the prior process
  totaloutage=$(grep "Total" "outages" | tail -n1)
  totaloutage=$(echo "$totaloutage" | cut -d'(' -f2 | cut -d')' -f1)
  totaloutage=$(echo "$totaloutage" | ./util/text2secs.sh)
  # gaurd against something weird, e.g., a bad line in the outages file
  case "$totaloutage" in
    ''|*[!0-9]* ) totaloutage=0 ;;
    * ) ;;
  esac
else
  totaloutage=0
fi

# begin monitoring connectivity
domaini=-1
echo "monitor starting ~ $(date)"
while true ; do
  # sleep for 40-90 seconds
  sleep "$((RANDOM%51+40))"
  # if we can ping restart the loop
  try && continue
  outage="$timer"
  # sleep for 30-60 seconds
  sleep "$((RANDOM%31+30))"
  # if we can ping restart the loop
  try && continue
  # if we can connect to ifconfig.me for an ip address then restart the loop
  curl --no-fail --connect-timeout 5 ifconfig.me >/dev/null 2>&1 && continue
  # we are in an outage
  outage=$((outage+timer+5))
  echo " ~ Outage detected ~"
  date
  timer=$(date "+%s")
  # wait for the network to come back up
  false
  while [ "$?" -ne 0 ] ; do
    ./net/wait4net.sh >/dev/null 2>&1
    # the network is back up
    # call the script to determine+handle if our ip changed
    python3 -B ip/ipmon.py
  done
  # update our current outage and total outage values
  outage=$((outage+$(date "+%s")-timer))
  totaloutage=$((totaloutage+outage))
  # log outage times
  echo "This outage: $(./util/secs2text.sh $outage)"
  echo "Total outages: ($(./util/secs2text.sh $totaloutage))"
  date
  echo " ~ Outage end ~"
done

