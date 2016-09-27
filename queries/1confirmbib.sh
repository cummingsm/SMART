#!/bin/bash
#
# FILENAME: 1confirmbib.sh
# FILEPATH: {docroot}/cgi-bin/queries/
# PARAMS  : bibid
# OUTPUT  : bibid
# PURPOSE : verify that the users bibid is in Voyager
#
NORMBIB=$(echo $1 | sed 's/-/ /g');
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
set WRAP off
set RECSEP off
set TERMOUT off
set FEEDBACK off
set SCAN off
set VERIFY off
set HEADSEP off
select bib_master.bib_id
from bib_master
where 
bib_master.bib_id='$NORMBIB'
/
EOF
