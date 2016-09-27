#!/bin/bash
#
# FILENAME: 2getlccn.sh
# FILEPATH: {docroot}/cgi-bin/queries/
# PARAMS  : bibid
# OUTPUT  : the LCCN(s) associated with the given bibid
# PURPOSE : collect LCCN values that will be used to find related records
#
#
LD_LIBRARY_PATH=/usr/lib/oracle/10.2.0.4/client64/lib
export LD_LIBRARY_PATH
echo 'LD_LIBRARY_PATH:' $LD_LIBRARY_PATH
#
SQLPATH=/usr/lib/oracle/10.2.0.4/client64/bin/
export SQLPATH
echo 'SQLPATH:' $SQLPATH
#
$SQLPATH/sqlplus -S dbread/<PASSWORD>@'(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=<HOST>)(PORT=1521)))(CONNECT_DATA=(SID=VGER)))'<<EOF
set HEADING off
set ECHO off
set WRAP off
set PAGESIZE 1000
set RECSEP off
set TERMOUT off
set FEEDBACK off
set SCAN off
set VERIFY off
set HEADSEP off
column bib_index.normal_heading format A20
spool /tmp/$1BL.out
select bib_index.bib_id,'|',bib_index.normal_heading,'|'
from bib_index
where 
bib_index.bib_id='$1' and
bib_index.index_code='010A'
/
spool off
EOF
LOG=/var/www/wrlc/log/BIBID-$1.log
echo "TIMER|"`date +%T`"|2getlccn" >> $LOG
echo "--------------------------------------------------" >> $LOG
echo "Retrieving LCCNs in bib_index with index_code 010A" >> $LOG
echo "output from 2getlccn.sh (BL)" >> $LOG
sed -i -e 's/  //g'  /tmp/$1BL.out
cat /tmp/$1BL.out | grep '|' >> $LOG
