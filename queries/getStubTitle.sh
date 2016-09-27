#!/bin/bash
#
# FILENAME: getStubTitle.sh
# FILEPATH: {docroot}/cgi-bin/queries/
# PARAMS  : bibid
# OUTPUT  : the first 12 characters of a title
#	    as /tmp/$1TITLEMATCH.out
# PURPOSE : The stub title is used to compare search results and
#	    eliminate any that might be false due to more than one
#	    title having the same standard id number.
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
set LINESIZE 250
set RECSEP off
set TERMOUT off
set FEEDBACK off
set SCAN off
set VERIFY off
set HEADSEP off
spool /tmp/TITLEMATCH-$1.out
select bib_text.bib_id,'|',SUBSTR(bib_text.title_brief,1,12),'|'
from bib_text
where 
bib_text.bib_id='$1'
/
spool off
EOF
