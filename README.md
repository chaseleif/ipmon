# ipmon
### These scripts monitor network connectivity and IP address changes

Created to keep a record of outages for speaking to an ISP about poor service
___
### Usage
___
#### Automatic
Use an init system, e.g., Systemd or OpenRC

**NOTE:** `./start.sh` runs `./net/netmon.sh`, i.e., *the relative path should be this repo directory !*

In `start.sh`, add a line below the open parenthesis, before the command to run `./net/netmon.sh`:

`  cd $(pwd) || exit`

*replace $(pwd) with the directory of this repo*

Add the script to your init system, start and enable it
___
#### Manual
*The script must be ran from the repo directory for relative paths to work!*

Manual invocation can be done by running the `start.sh` script:

`$ ./start.sh`

The PID of the background process launched will be stored in `./pid`

Outages, when detected, will be stored in `./outages`

The process will continue to run until it is killed, e.g., upon logoff
___
### Components
**Network connectivity monitoring - ./net/netmon.sh**

- General network connectivity is monitored in `./net/netmon.sh` by periodic pings to DNS servers
- There is a "random" `sleep` between each ping attempt
- Following 2 failed pings an attempt will be made to `curl ifconfig.me`
- When the `curl` command fails, the outage has begun and `./net/wait4net.sh` will be called
  - `wait4net.sh` will continuously try the `curl ifconfig.me` command
  - There are small sleeps between each attempt
- Upon success, `wait4net.sh` will exit and we note that as the outage ending
- There is then a call to `./ip/ipmon.py`
  - This script will get the current IP and pass it to a method in `./ip/ipaction.py` (not included)
  - This allows logging of IP address changes, notifications upon changes, etc.
- Date timestamps for outage starts and ends, and current outage and total outage times are all logged in `./outages`

**Wait for network - ./net/wait4net.sh**

- This script is ran by `./net/netmon.sh`
- This script can be ran by itself when the network is down, to notify when the network becomes available

**IP address monitoring - ./ip/ipmon.py**

- The Python script, `./ip/ipmon.py`, is called by `./net/netmon.sh`
  - Each time an outage has ended
  - Can be called independently
- The purpose is to provide a place to handle IP address changes
  - The script will get the current IP
  - Call the function `receivedip` in `./ip/ipaction.py` with the IP as an argument
- The script `./ip/ipaction.py` can be added and implemented with whatever action is desired
  - If there is an error importing the method, the method will be defined as: `receivedip = lambda ip: True`
- Exits 0 for success in both getting the IP and `receivedip` returning True

**Utilities**
- `./util/secs2text.sh` - converts seconds, e.g., 10 or 100, to a human-friendly text string
- `./util/text2secs.sh` - converts the human-friendly string to seconds
- Both `secs2text.sh` or `text2secs.sh` can be given arguments via command-line or through an stdin<-stdout pipe
___
