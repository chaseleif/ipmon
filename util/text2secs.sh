#! /usr/bin/env bash

# handle either command-line arguments or text pipe
if [[ "${*}" ]] ; then
  # gather command-line arguments into the array 'arg'
  while read -r arg ; do
    args[${#args[@]}]="$arg"
  done < <(printf '%s\n' "${@}")
elif [[ ! -t 0 ]] ; then
  # gather pipe into the array 'arg'
  read -ra args
fi

# for each argument, numbers are preceded by their type
for arg in "${args[@]}" ; do
  # numbers are preceded by their type, store the number when encountered
  # when the type is encountered increment seconds by the type
  if [[ "$arg" =~ ^[1-9][0-9]*$ ]] ; then
    numba="$arg"
  elif [[ "$arg" =~ ^week[s]?[,]?$ ]] ; then
    seconds=$((seconds+numba*604800))
  elif [[ "$arg" =~ ^day[s]?[,]?$ ]] ; then
    seconds=$((seconds+numba*86400))
  elif [[ "$arg" =~ ^hour[s]?[,]?$ ]] ; then
    seconds=$((seconds+numba*3600))
  elif [[ "$arg" =~ ^minute[s]?[,]?$ ]] ; then
    seconds=$((seconds+numba*60))
  elif [[ "$arg" =~ ^second[s]?$ ]] ; then
    seconds=$((seconds+numba))
  fi
done

# print the number of seconds
echo "$seconds"

