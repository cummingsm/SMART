#!/bin/bash
#
# FILENAME: pagefooter.sh 
# FILEPATH: {docroot}/cgi-bin/responses/
# PARAMS  : bibid, search value, id type
# OUTPUT  : HTML table containing a footer; appends lines with "TIMER" to the end of the log file 
# PURPOSE : Display the page footer, generate the summary section of the log file
#
if [[ "$1" != "" ]]; then
	LOG=/var/www/wrlc/log/BIBID-$1.log
	echo "TIMER|"`date +%T`"|FINISH" >> $LOG
	echo "======= summary ==========" >> $LOG
	cat $LOG | grep TIMER  >> $LOG
fi
echo "<TABLE CELLPADDING='2' CELLSPACING='1' WIDTH='90%'><TR BGCOLOR='#EAEAEA'><TD ALIGN='CENTER'> ";
echo "----[ Shared Materials Audit Reporting Tool ]---- </TD><TR></TABLE>";
echo "</BODY></HTML>";
