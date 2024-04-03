#! /usr/bin/env python

import os

def setup_systemd():
  pwd = os.getcwd()
  with open('start.sh','r') as infile:
    lines = [line.rstrip() for line in infile.readlines()]
  done = False
  with open('start.sh','w') as outfile:
    for line in lines:
      if not done and pwd in line: done = True
      elif not done and 'netmon.sh' in line:
        outfile.write(f'  cd {pwd} || exit\n')
        done = True
      outfile.write(line+'\n')
  if not os.path.isfile('/etc/systemd/system/ipmon.service'):
    user = os.getlogin()
    lines = [ '[Unit]',
              'Description=Net and IP monitor', '',
              'After=syslog.target', '',
              '[Service]',
              'Type=forking',
              f'ExecStart={pwd}/start.sh',
              f'PIDFile={pwd}/pid',
              f'User={user}',
              'Group=systemd-journal', '',
              '[Install]',
              'WantedBy=multi-user.target']
    servicefile = '/etc/systemd/system/ipmon.service'
    try:
      with open(servicefile,'w') as outfile:
        outfile.write('\n'.join(lines)+'\n')
    except PermissionError:
      print(f'Need sudo permissions to write to {servicefile}')
      print('Re-run this script with sudo, or create the file')
      print('Create the file with the contents:\n')
      print('\n'.join(lines))
      return
    print('Systemd service file created, follow these steps:')
    print('# Reload the daemon:')
    print('$ sudo systemctl daemon-reload')
    print('# Start the service:')
    print('$ sudo systemctl start ipmon')
    print('# Verify the service is running:')
    print('$ sudo systemctl status ipmon')
    print('# You should see output in these files:')
    print('$ cat outages')
    print('$ cat pid')
    print('# Enable the service to automatically start with the computer:')
    print('$ sudo systemctl enable ipmon\n')
  print('Systemd setup completed successfully')

if __name__ == '__main__':
  setup_systemd()

