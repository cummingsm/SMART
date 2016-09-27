#!/bin/bash
#
# FILENAME: cleanup.sh
# FILEPATH: {docroot}/cgi-bin/utils/
# PARAMS  : bibid
# OUTPUT  : four files in /tmp are edited
# PURPOSE : eliminate blank lines and spacing before or after sql pipe symbol 
#
# -----------------------------------------------------------------------------------------------------
LOG=/var/www/wrlc/log/BIBID-$1.log
echo '-------------------------------' >> $LOG
# clean the LCCN output
#
grep '|' /tmp/$1BL.out | sort | uniq > /tmp/$1tempfile
mv /tmp/$1tempfile /tmp/$1BL.out
sed -i -e 's/  //g' /tmp/$1BL.out 
sed -i -e 's/| /|/g' /tmp/$1BL.out
sed -i -e 's/ |/|/g' /tmp/$1BL.out
echo 'cleanup: edited LCCN ouptut (BL)' >> $LOG
cat /tmp/$1BL.out >> $LOG
#
# -----------------------------------------------------------------------------------------------------
# clean the ISBN output
#
# get the lines with data 
grep '|' /tmp/$1BI.out | sort | uniq > /tmp/$1tempfile
mv /tmp/$1tempfile /tmp/$1BI.out
# 
# the query outputs bibid, index code, and isbn value. 
# get the third field which is the ISBN value
cat /tmp/$1BI.out | cut -f3 -d'|' >  /tmp/$1tempfile
mv /tmp/$1tempfile /tmp/$1BI.out
#
# get only the isbn number, not PBK, etc. 
# the value in the file is a space, followed by the number, possibly followed by a space and some chars
# get field 2 when you consider the first character is a space
# output sorted, unique values
cat /tmp/$1BI.out | cut -f2 -d' ' | sort | uniq > /tmp/$1tempfile
mv /tmp/$1tempfile /tmp/$1BI.out
#
sed -i -e 's/  //g' /tmp/$1BI.out
sed -i -e 's/| /|/g' /tmp/$1BI.out
sed -i -e 's/ |/|/g' /tmp/$1BI.out
echo 'cleanup: edited IBSN output (BI)' >> $LOG
cat /tmp/$1BI.out >> $LOG
# -------------------------------------------------------------------------------------------------------
# clean the OCLC output
#
grep '|' /tmp/$1BO.out | sort | uniq > /tmp/$1tempfile
mv /tmp/$1tempfile /tmp/$1BO.out
#
sed -i -e 's/  //g' /tmp/$1BO.out 
sed -i -e 's/| /|/g' /tmp/$1BO.out
sed -i -e 's/ |/|/g' /tmp/$1BO.out
echo 'cleanup: edited OCLC output (BO)' >> $LOG
cat /tmp/$1BO.out >> $LOG
# -----------------------------------------------------------------------------------------------------
# clean the ISSN output
#
grep '|' /tmp/$1BS.out | sort | uniq > /tmp/$1tempfile
mv /tmp/$1tempfile /tmp/$1BS.out
sed -i -e 's/  //g' /tmp/$1BS.out 
sed -i -e 's/| /|/g' /tmp/$1BS.out
sed -i -e 's/ |/|/g' /tmp/$1BS.out
echo 'cleanup: edited ISSN output (BS)' >> $LOG
cat /tmp/$1BS.out >> $LOG
