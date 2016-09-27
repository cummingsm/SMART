#!/bin/bash
#
# FILENAME: logcounts.sh
# FILEPATH: {docroot}/cgi-bin/utils/
# PARAMS  : bibid
# OUTPUT  : updated $LOG
# PURPOSE : To log the number of standard identifiers that were found for a given bibid
#	    in queries 2 through 5
#
#
LOG=/var/www/wrlc/log/BIBID-$1.log
#
echo "----- FOUND THESE STANDARD IDS ON THE BIB ---------------" >> $LOG
# the LCCN value is the second field of the SQL output
echo "logcounts:Unique LCCN count " ` wc -l /tmp/$1BL.out | cut -f1 -d' '` >> $LOG
cat /tmp/$1BL.out | cut -f2 -d'|' >> $LOG
echo "logcounts:Unique ISBN count " ` wc -l /tmp/$1BI.out | cut -f1 -d' '` >> $LOG
cat /tmp/$1BI.out  >> $LOG
# the OCLC value is the second field of the SQL output
echo "logcounts:Unique OCLC count " ` wc -l /tmp/$1BO.out | cut -f1 -d' '` >> $LOG
cat /tmp/$1BO.out | cut -f2 -d'|' >> $LOG
# the ISSN value is the second field of the SQL output
echo "logcounts:Unique ISSN count " ` wc -l /tmp/$1BS.out | cut -f1 -d' '` >> $LOG
cat /tmp/$1BS.out  | cut -f2 -d'|' >> $LOG
#
