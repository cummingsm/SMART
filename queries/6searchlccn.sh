#!/bin/bash
#
# FILENAME: 6searchlccn.sh
# FILEPATH: {docroot}/cgi-bin/queries/
# PARAMS  : bibid (used for logging)
#	    reads output from 2getlccn.sh in /tmp/$1BL-LIST.out
#	    that file has 1 or more LCCN values 
# OUTPUT  : the BIBID(s) that have a match on the LCCN
#	    will be saved in /tmp/ having name format $1BLX-$i.out
# PURPOSE : collect BIBID(s) of records related by LCCN
#
LOG=/var/www/wrlc/log/BIBID-$1.log
# there will be a file /tmp/bibidBLX-id for each lccn looked up
echo "TIMER|"`date +%T`"|6searchlccns" >> $LOG
echo "-------------------------------------" >> $LOG
echo "6searchlccn: Bibid(s) that match LCCN" >> $LOG
# remove list from previous processing of this bibid
rm /tmp/$1BL-LIST.out 2>/dev/null
max=`wc -l /tmp/$1BL.out | cut -f1 -d' '`;
for (( i=1; i<=$max; i++ ))
do
	awk NR==$i /tmp/$1BL.out > /tmp/$1-tempfile
	# this synax gets the LCCN value from the output, then
	sed -i -e 's/ //g'  /tmp/$1-tempfile
	normheading=`cat /tmp/$1-tempfile | cut -f2 -d'|'`
#
LD_LIBRARY_PATH=/usr/lib/oracle/10.2.0.4/client64/lib
export LD_LIBRARY_PATH
echo 'LD_LIBRARY_PATH:' $LD_LIBRARY_PATH
#
SQLPATH=/usr/lib/oracle/10.2.0.4/client64/bin/
export SQLPATH
echo 'SQLPATH:' $SQLPATH
#
$SQLPATH/sqlplus -S dbread/libs8db@'(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=oracle.wrlc.org)(PORT=1521)))(CONNECT_DATA=(SID=VGER)))'<<EOF
set HEADING off
set ECHO off
set PAGESIZE 1000
set WRAP off
set RECSEP off
set TERMOUT off
set FEEDBACK off
set SCAN off
set VERIFY off
set HEADSEP off
spool /tmp/$1BLX-$i.out
select bib_index.bib_id,'|',library_name
from bib_index,bib_master,library
where 
bib_index.index_code ='010A' and
bib_index.normal_heading='$normheading' and
bib_index.bib_id=bib_master.bib_id and
bib_master.library_id=library.library_id
/
spool off
EOF
echo 'iteration '$i $normheading >> $LOG
cat /tmp/$1BLX-$i.out >> $LOG
done
#
# formatting
bash /var/www/cgi-bin/utils/reformatsql.sh $1 'BL'
#
