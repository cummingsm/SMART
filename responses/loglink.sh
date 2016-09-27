#!/bin/bash
#
# FILENAME: loglink.sh
# FILEPATH: {docroot}/cgi-bin/responses/
# PARAMS  : bibid, search value, id type
# OUTPUT  : HTML table, ROW for the log file link
# PURPOSE : Displays a link for the user to download or view the log file
#
# $1 id type
# $2 search value
# $3 bib id
#
echo "<TABLE cellpadding='2' cellspacing='1' border='0' bgcolor='#EAEAEA' width='90%'>";
echo "<tr bgcolor='LIGHTSTEELBLUE'><td colspan='3'> <strong>Downloads</strong></td></tr>";
# row for log links
	echo "<tr valign='top' bgcolor='#FFFFFF'> <td>1. Log </td>";
	# echo "<td><a href='http://gwreports.wrlc.org/wrlc/log/$1-$2-$3.log'>$3 $1</a></td>";
	echo "<td><a href='http://gwreports.wrlc.org/wrlc/log/BIBID-$3.log'>View / Download Log File</a></td>";
	echo "<td>";
	#echo `wc -l /var/www/wrlc/log/$1-$2-$3.log | cut -f1 -d' '`;
	echo `wc -l /var/www/wrlc/log/BIBID-$3.log | cut -f1 -d' '`;
	echo " lines, ";
	#echo `wc -m /var/www/wrlc/log/$1-$2-$3.log | cut -f1 -d' '`;
	echo `wc -m /var/www/wrlc/log/BIBID-$3.log | cut -f1 -d' '`;
	echo " characters. </TD>";
	echo "</TR>";
#
# this html is continued by datalink.sh

