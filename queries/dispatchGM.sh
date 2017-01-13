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
gmCount=`grep -c 'GM|' /var/www/wrlc/report/$1-REPORT.txt`;
if [[ "$gmCount" != "0" ]]; then
		echo "------------------------------" >> $LOG
		# add the title to the parameters
		thistitle=`cat /var/www/wrlc/report/$1-REPORT.txt | grep -v BARCODE | cut -d'|' -f22 | head -1`
		echo "Title sent is $thistitle" >> $LOG
		bash /var/www/cgi-bin/queries/mason/gmChecker.sh $thisbibid "'$thistitle'"
fi
#
