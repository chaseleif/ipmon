#! /usr/bin/env bash

(
  nice -n 19 ./net/netmon.sh >> outages 2>&1 &
  echo "$!" > pid
)

