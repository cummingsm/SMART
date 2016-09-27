#!/bin/bash
#
# FILENAME: dispatchGM.sh
# FILEPATH: {docroot}/cgi-bin/queries/
# PARAMS  : bibid 
#           idtype, request, output type (for logging)
# OUTPUT  : n.a. 
# PURPOSE : Determines if a George Mason record was in the search results, 
#	    if true, call process to scrape the Mason catalog for items at the SCF.
#
# 
thisbibid=$1
idtype=$2
request=$3
output=$4
#
# Working log file
LOG=/var/www/wrlc/log/BIBID-$1.log
echo "TIMER|"`date +%T`"|dispatchGM.sh" >> $LOG
echo "Parameters: $thisbibid $idtype $request $output" >> $LOG
gmCount=`grep -c 'GM|' /var/www/wrlc/$1-REPORT.txt`;
if [[ "$gmCount" != "0" ]]; then
		echo "------------------------------" >> $LOG
		bash queries/mason/gmChecker.sh $thisbibid
fi
#
