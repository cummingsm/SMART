#!/bin/bash
# FILENAME: 4getoclc.sh
# FILEPATH: {docroot}/cgi-bin/queries/
# PARAMS  : bibid
# OUTPUT  : the OCLC(s) associated with the given bibid
# PURPOSE : collect OCLC values that will be used to find related records
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
set PAGESIZE 1000
set LINESIZE 1000
set WRAP off
set RECSEP off
set TERMOUT off
set FEEDBACK off
set SCAN off
set VERIFY off
column bib_index.normal_heading format A20
set HEADSEP off
spool /tmp/$1BO.out
select 
bib_index.bib_id,'|',
bib_index.normal_heading,'|',bib_index.display_heading
from bib_index
where 
bib_index.bib_id='$1' and
bib_index.index_code ='035A' and
bib_index.display_heading like '(OCoLC)%' and
bib_index.display_heading not like '(OCoLC)mom%'
/
spool off
EOF
# remove blanks from output!!
sed -i -e 's/  //g'  /tmp/$1BO.out
#
LOG=/var/www/wrlc/log/BIBID-$1.log
echo "TIMER|"`date +%T`"|4getoclc" >> $LOG
echo "----------------------------------" >> $LOG
echo "OCLCs in bib_index with code 035A " >> $LOG
echo "having (OCoLC) prefix" >> $LOG
echo "output from 4getoclc.sh (BO)" >> $LOG
cat /tmp/$1BO.out | grep '|' >> $LOG
