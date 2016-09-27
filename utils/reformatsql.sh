#!/bin/bash
#
# FILENAME: reformatsql.sh
# FILEPATH: {docroot}/cgi-bin/utils/
# PARAMS  : bibid, a 2-letter log type (BL, BI, BO, BS, BD)
# OUTPUT  : /tmp/$1$2-LIST.out 
# PURPOSE : strip spaces before and after sql output; create a
#	    sorted, unique list
#
LOG=/var/www/wrlc/log/BIBID-$1.log
#
# merge all outputs from searching into the LIST output
# save lines with data | from LIST output
# then remove individual outputs
# write the current bib to ensure it is output
#
echo "$1|default" > /tmp/$1$2X-0.out
cat /tmp/$1$2X*.out | grep '|' >> /tmp/$1$2-LIST.out
rm /tmp/$1$2X*.out
# remove space before after pipes
sed -i -e 's/  //g'  /tmp/$1$2-LIST.out 
sed -i -e 's/| /|/g' /tmp/$1$2-LIST.out
sed -i -e 's/ |/|/g' /tmp/$1$2-LIST.out
# append to log 
sed -i -e 's/ //g' /tmp/$1$2-LIST.out
echo $2-LIST >> $LOG
cat /tmp/$1$2-LIST.out  >> $LOG
# get just the bibids
cat /tmp/$1$2-LIST.out | cut -f1 -d'|'  > /tmp/$1-tempfile
cat /tmp/$1-tempfile | sort | uniq > /tmp/$1$2-LIST.out
echo 'Unique Bibid(s) that match ' >> $LOG
cat /tmp/$1$2-LIST.out >> $LOG
