#!/bin/bash
# FILENAME: getGMBib.sh
# FILEPATH: {docroot}/cgi-bin/queries/mason/
# PARAMS  : bibid 
# OUTPUT  : The George Mason bibid according to Voyager
#	    Note: There are rare cases where the GM bibid is not stored on the Voyager bib.
# PURPOSE : find the GM Bibid id so the next step can scrape GM's catalog for the items at SCF

# $1 is the voyager bibid
#
LD_LIBRARY_PATH=/usr/lib/oracle/10.2.0.4/client64/lib
export LD_LIBRARY_PATH
SQLPATH=/usr/lib/oracle/10.2.0.4/client64/bin/
export SQLPATH
#
$SQLPATH/sqlplus -S dbread/<PASSWORD>@'(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=<HOST>)(PORT=1521)))(CONNECT_DATA=(SID=VGER)))'<<EOF > /dev/null set HEADING off
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
spool /tmp/$1gmbib.out
SELECT $1,'|',max(BIB_INDEX.NORMAL_HEADING)
FROM BIB_INDEX 
INNER JOIN BIB_INDEX BIB_INDEX_1 ON BIB_INDEX.NORMAL_HEADING = BIB_INDEX_1.DISPLAY_HEADING AND 
BIB_INDEX.INDEX_CODE = BIB_INDEX_1.INDEX_CODE AND BIB_INDEX.BIB_ID = BIB_INDEX_1.BIB_ID
WHERE 
BIB_INDEX.BIB_ID=$1 AND 
BIB_INDEX.INDEX_CODE='035A' AND 
BIB_INDEX.NORMAL_HEADING Not Like '% %'
/
spool off
EOF
