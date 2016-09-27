#!/bin/bash
# FILENAME: 7searchisbn.sh
# FILEPATH: {docroot}/cgi-bin/queries/
# PARAMS  : bibid (used for logging)
#           reads output from 3getsbn.sh in /tmp/$1BI-LIST.out
#           that file has 1 or more ISBN values 
# OUTPUT  : the BIBID(s) that have a match on the ISBN
#           will be saved in /tmp/ having name format $1BIX-$i.out
# PURPOSE : collect BIBID(s) of records related by ISBN
#
# there will be a file /tmp/bibidBI.out for each lccn looked up
LOG=/var/www/wrlc/log/BIBID-$1.log
# remove list from previous processing of this bibid
echo "TIMER|"`date +%T`"|7searchisbns" >> $LOG
echo "--------------------------------------" >> $LOG
echo "7searchisbn: Bibid(s) that match ISBN " >> $LOG
rm /tmp/$1BI-LIST.out
max=`wc -l /tmp/$1BI.out | cut -f1 -d' '`;
for (( i=1; i<=$max; i++ ))
do
	awk NR==$i /tmp/$1BI.out > /tmp/$1-tempfile
	# these lines get the isbn value and make certain it has no trailing junk
	sed -i -e 's/ //g'  /tmp/$1-tempfile
	isbn=`cat /tmp/$1-tempfile`
	normisbn=`cat /tmp/$1-tempfile | cut -f2 -d'|' | cut -f2 -d' '`
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
spool /tmp/$1BIX-$i.out
select bib_index.bib_id,'|',bib_index.index_code,'|',library_name
from bib_index,bib_master,library
where 
bib_index.index_code in ('020A','020N','020Z','ISB3') and
bib_index.normal_heading='$normisbn' and
bib_index.bib_id=bib_master.bib_id and
bib_master.library_id=library.library_id
order by bib_index.bib_id,bib_index.index_code
/
spool off
EOF
echo 'iteration '$i $normisbn >> $LOG
cat /tmp/$1BIX-$i.out >> $LOG
done
# 
# formatting
bash utils/reformatsql.sh $1 'BI'
