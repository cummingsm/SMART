#!/bin/bash
#
# FILENAME: flush.sh
# FILEPATH: {docroot}/cgi-bin/utils/
# PARAMS  : none
# OUTPUT  : none
# PURPOSE : Admin script to remove all temporary output, logs, and reports
#
#
echo 'This script will remove /tmp /var/www/wrlc/log and /var/www/wrlc/report files.';
echo 'Are you sure you want to proceed? [enter] to proceed, or ctrl/c to break';
read keyboardinput
sudo rm /tmp/*out
sudo rm /tmp/*log
sudo rm /tmp/*tempfile
sudo rm /var/www/wrlc/log/*log
sudo rm /var/www/wrlc/report/*.txt
sudo rm /tmp/*titlefound
sudo rm /tmp/*itemdetail
