#!/bin/bash
#
# FILENAME: 8searchoclc.sh
# FILEPATH: {docroot}/cgi-bin/queries/
# PARAMS  : bibid (used for logging)
#           reads output from 4getoclc.sh in /tmp/$1BO-LIST.out
#           that file has 1 or more OCLC values 
# OUTPUT  : the BIBID(s) that have a match on the OCLC
#           will be saved in /tmp/ having name format $1BOX-$i.out
# PURPOSE : collect BIBID(s) of records related by OCLC
# 
LOG=/var/www/wrlc/log/BIBID-$1.log
# remove list from previous processing of this bibid
echo "TIMER|"`date +%T`"|8searchoclcs" >> $LOG
echo "--------------------------------------" >> $LOG
echo "8searchoclc: Bibid(s) that match OCLC " >> $LOG
rm /tmp/$1BO-LIST.out 2>/dev/null
max=`wc -l /tmp/$1BO.out | cut -f1 -d' '`;
for (( i=1; i<=$max; i++ ))
do
	awk NR==$i /tmp/$1BO.out > /tmp/$1-tempfile
	cat /tmp/$1-tempfile >> $LOG
	oclc=`cat /tmp/$1-tempfile`
	# this syntax strips all blank characters
	normoclc=`cat /tmp/$1-tempfile | cut -f2 -d'|' `
	cat $normoclc >> $LOG
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
spool /tmp/$1BOX-$i.out
select bib_index.bib_id,'|',library_name
from bib_index,bib_master,library
where 
bib_index.index_code='035A' and
bib_index.normal_heading='$normoclc' and
bib_index.display_heading like '(OCoLC)%' and
bib_index.display_heading not like '(OCoLC)mom%' and
bib_index.bib_id=bib_master.bib_id and
bib_master.library_id=library.library_id
order by bib_index.bib_id,bib_index.index_code
/
spool off
EOF
echo 'iteration '$i $normoclc >> $LOG
cat /tmp/$1BOX-$i.out >> $LOG
done
# 
# formatting
bash /var/www/cgi-bin/utils/reformatsql.sh $1 'BO'
