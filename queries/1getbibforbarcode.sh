#!/bin/bash
#
# FILENAME: 1getbibforbarcode.sh
# FILEPATH: {docroot}/cgi-bin/queries/
# PARAMS  : barcode
# OUTPUT  : bibid
# PURPOSE : find the voyager bib record for a given barcode
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
#
$SQLPATH/sqlplus -S dbread/<PASSWORD>@'(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=<HOST>)(PORT=1521)))(CONNECT_DATA=(SID=VGER)))'<<EOF
set HEADING off
set ECHO off
set RECSEP off
set LINESIZE 150
set TERMOUT off
set FEEDBACK off
set SCAN off
set VERIFY off
set HEADSEP off
select bib_item.bib_id,'|' from item_barcode
inner join bib_item on item_barcode.item_id=bib_item.item_id 
where item_barcode.item_barcode='$1'
/
EOF
