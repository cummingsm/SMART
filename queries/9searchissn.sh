#!/bin/bash
#
# FILENAME: 9searchissn.sh
# FILEPATH: {docroot}/cgi-bin/queries/
# PARAMS  : bibid (used for logging)
#           reads output from 5getssn.sh in /tmp/$1BS-LIST.out
#           that file has 1 or more ISSN values 
# OUTPUT  : the BIBID(s) that have a match on the ISSN
#           will be saved in /tmp/ having name format $1BSX-$i.out
# PURPOSE : collect BIBID(s) of records related by ISSN
# 
LOG=/var/www/wrlc/log/BIBID-$1.log
# remove list from previous processing of this bibid
echo "TIMER|"`date +%T`"|9searchissns" >> $LOG
echo "------------------------------------" >> $LOG
echo '9searchissn:Bibid(s) that match ISSN' >> $LOG
rm /tmp/$1BS-LIST.out 2>/dev/null
max=`wc -l /tmp/$1BS.out | cut -f1 -d' '`;
for (( i=1; i<=$max; i++ ))
do
	awk NR==$i /tmp/$1BS.out > /tmp/$1-tempfile
	issn=`cat /tmp/$1-tempfile`
	# this syntax strips all blank characters
	normissn=`cat /tmp/$1-tempfile | cut -f2 -d'|'`
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
spool /tmp/$1BSX-$i.out
select bib_index.bib_id,'|',library_name
from bib_index,bib_master,library
where 
bib_index.index_code='022A' and
bib_index.normal_heading='$normissn' and
bib_index.bib_id=bib_master.bib_id and
bib_master.library_id=library.library_id
order by bib_index.bib_id,bib_index.index_code
/
spool off
EOF
echo 'iteration '$i $normissn >> $LOG
done
# 
# formatting
bash /var/www/cgi-bin/utils/reformatsql.sh $1 'BS'
#
