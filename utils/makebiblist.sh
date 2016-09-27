#!/bin/bash
#
# FILENAME: makebiblist.sh
# FILEPATH: {docroot}/cgi-bin/utils/
# PARAMS  : bibid
# OUTPUT  : /tmp/$1QRYSET.out
# PURPOSE : Create a set of bibids for the query that searches for items.
#
# $1=bibid
# 
# Files with bibid prefix ending BL-LIST.out, BI-LIST.out, BO-LIST.out
# and BS-LIST.out are in /tmp they contain unique bibids matched by
# looking for matching standard ids.
#
# This script combines the four lists into one unique set of bibids
#
LOG=/var/www/wrlc/log/BIBID-$1.log
echo "-------------------------" >> $LOG
echo " unique set of bibids " >> $LOG
rm /tmp/$1*BIBSET.out
cat /tmp/$1*LIST.out  >> /tmp/$1COMBINED_BIBSET.out
cat /tmp/$1COMBINED_BIBSET.out | sort | uniq >> /tmp/$1UNIQUE_BIBSET.out
cat /tmp/$1UNIQUE_BIBSET.out >> $LOG
#
# This is my clumsy way of converting the list into a comma separated 
# result like ("123555","87474575","34234")
#
inputfile=/tmp/$1UNIQUE_BIBSET.out
#
# join all the lines, separated by X like this 12355X8744575X34234
Xlist=`cat $inputfile | paste -sd "X" `
#
# change X to quote comma quote like this  "12355","8744575","34234
#commalist=`echo $Xlist | sed 's/X/","/g'`
commalist=`echo $Xlist | sed "s/X/\',\'/g"`
#
# add parenthesis quote to beginning and quote parenthesis to the end
completelist=`echo "('"${commalist}"')"`
# the result looks like ("12355","8744575","34234")
#
echo "--------------------------------" >> $LOG
echo "The query will get items for" >> $LOG
echo $completelist >> $LOG
echo $completelist > /tmp/$1QRYSET.out
#

