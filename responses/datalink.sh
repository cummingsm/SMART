#!/bin/bash
#
# FILENAME: datalink.sh
# FILEPATH: {docroot}/cgi-bin/responses/
# PARAMS  : bibid, search value, id type
# OUTPUT  : HTML ROW for the data file link, closing HTML for table
# PURPOSE : Displays a link for the user to download or view the data file
#
#
# $1 BIBID
# $2 SEARCH VALUE
# $3 ID TYPE
# 
REPT="/var/www/wrlc/report/$1-REPORT.txt";
#
# this is a continuation of a table already started by loglinks.sh
#
# row for data links
#
echo "<tr bgcolor='#FFFFFF' valign='top' width='90%'><td> 2. Data </td>";
echo "<td><a href='../wrlc/report/$1-REPORT.txt'>View / Download Data File</a></td>";
echo "<td>";
LINES=`wc -l $REPT | cut -f1 -d'/'`;
RECORDS=`expr $LINES - 1 `;
echo " $RECORDS records, ";
echo `wc -m $REPT | cut -f1 -d'/'`;
echo " characters. </td></tr>"
#
# this concludes the log and data link table section of the page
echo "</table>";
