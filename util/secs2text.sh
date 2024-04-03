#! /usr/bin/env bash

# the seconds were passed as a command-line argument
if [ -n "$1" ] ; then
  str="$1"
# the seconds were passed through pipe
elif [[ ! -t 0 ]] ; then
  read -d' ' -r -s str
fi

# verify the number of seconds is strictly numeric
case "$str" in
  ''|*[!0-9]* ) echo "seconds must be at least 0, not \"$str\"" && exit ;;
  * ) ;;
esac

# the type of values (text) in non-decreasing order
valstr=(second minute hour day week)

# accumulate the actual values, corresponding to the valstr array
vals=($((str%60)))  # secs
str=$((str/60))
vals+=($((str%60))) # mins
str=$((str/60))
vals+=($((str%24))) # hours
str=$((str/24))
vals+=($((str%7)))  # days
vals+=($((str/7)))  # weeks

# build the output string
str=""
# begin with the largest type of value
for i in $(seq $((${#vals[@]}-1)) -1 0) ; do
  # if (not at seconds or not string empty) and (the value is zero), continue
  { [ "$i" -ne 0 ] || [ -n "$str" ]; } && [ "${vals[$i]}" -eq 0 ] && continue
  # if the string is not empty, append a comma and a space
  [ -n "$str" ] && str="${str}, "
  # append the value and the name of the value
  str="${str}${vals[$i]} ${valstr[$i]}"
  # append an s is the value is not 1
  [ "${vals[$i]}" -ne 1 ] && str="${str}s"
done
# print the output string
echo "$str"

