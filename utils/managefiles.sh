#!/bin/bash
#
# This script will be called by cron. It removes logs and reports
# that are older than one week. It will be called once a week.
find /var/www/wrlc/report/*txt -mtime +7 -exec rm {} \;
find /var/www/wrlc/log/*log -mtime +7 -exec rm {} \;

