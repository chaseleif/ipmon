#! /usr/bin/env python3

import re, subprocess, sys

'''
  Take an action with an IP

  Given the implementation provided:
    implement the function 'receivedip' in the file 'ipaction.py'

  ipaction.py:
  def receivedip(ip: str): -> bool:
    # record ip somewhere
    # test ip against last known ip
    # handle any actions
    return True if success else False
'''
# If there is no action to do then it can't fail, just return True
try:
  from ipaction import receivedip
except ModuleNotFoundError:
  receivedip = lambda ip: True

# Get our current ip
def getipaddr():
  # $ curl ifconfig.me
  proc = subprocess.Popen(['curl', 'ifconfig.me'],
                          stdout=subprocess.PIPE,
                          stderr=subprocess.DEVNULL)
  # verify success and return the ip address
  try:
    output = proc.communicate(timeout=15)
  except subprocess.TimeoutExpired:
    proc.kill()
    print('curl timed out')
    return False
  if proc.returncode != 0:
    print(f'curl returned code {proc.returncode}')
    return False
  ipaddr = output[0].decode('utf-8')
  if not re.match(r'\d+\.\d+\.\d+\.\d+', ipaddr):
    print(f'Invalid IP address, received {ipaddr=}')
    return False
  return ipaddr

if __name__ == '__main__':
  # get our current ip address
  currentip = getipaddr()
  # if there was a failure then exit failure
  if not currentip:
    sys.exit(1)
  # exit with status depending on the return of the receivedip function
  sys.exit(0 if receivedip(currentip) else 1)

