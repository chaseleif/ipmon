#! /usr/bin/env bash

# the time of the last break (ctrl-c)
lastbreak=0

# this function is called on ctrl-c
printtime() {
  # the current time
  total=$(date "+%s")
  # if less than 10 seconds have elapsed, exit this script
  [ $((total-lastbreak)) -lt 10 ] && printf "Aborted\n" && exit
  # if we have called this function before clear the previous output
  [ "$lastbreak" -gt 0 ] && printf '\e[A\e[K'
  # set the lastbreak to the current timestamp
  lastbreak="$total"
  # set total to the the total time elapsed since the start
  total=$((total-start))
  # print the elapsed time
  echo "Elapsed time: $(./util/secs2text.sh $total)"
}
# don't echo ctrl characters and trap on ctrl-c to the printtime function
stty -echoctl
trap 'printtime' SIGINT

# set the start time to the current timestamp
start=$(date "+%s")

# the url used with the curl command
url="ifconfig.me"

# print usage, ctrl-c can be used to print the elapsed time or quit early
echo "###
# Press ctrl-c to print the current elapsed time
# Press ctrl-c twice within 10 seconds to quit
###
"

# print the timestamp and wait for curl to succeed
date
printf "\nWaiting for network . . .\n"
while true ; do
  # try to get a response from curl
  addr="$(curl --no-fail --connect-timeout 20 "$url" 2> /dev/null)"
  # if we have text, print the text and exit the loop
  [ -n "$addr" ] && printf "\n%s ~ " "$addr" && break
  # if no text was received, pause and restart the loop
  sleep 1
done

# set the total elapsed time
total=$(($(date "+%s")-start))

# if the elapsed time had been printed clear that output
[ "$lastbreak" -gt 0 ] && printf '\e[A\e[K'

# print the total elapsed time waiting for the network
printf "Network up !\n\nTotal elapsed time: "
./util/secs2text.sh "$total"
date

