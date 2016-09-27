#!/bin/bash
# FILENAME: filtertitles.sh
# FILEPATH: {docroot}/cgi-bin/utils/
# PARAMS  : $1 is the bibid
# OUTPUT  : This will call getStubTitle.sh to retrieve leading characters of title.
#	    Data file $REPT gets filtered to include only rows that match the title.
# PURPOSE : Eliminate false match based on standard number.
#
# $1 is the bibid
#
LOG=/var/www/wrlc/log/BIBID-$1.log;
REPT=/var/www/wrlc/report/$1-REPORT.txt;
#
echo 'filtering titles' >> $LOG;
#
# call query to get a few leading characters from the title for this bib
bash queries/getStubTitle.sh $1;
# outut from the query looks like this
# 1345785 | Student-to-s |
#
# grab the title specific to this bib from the output
TITLE_MATCH=`cat /tmp/TITLEMATCH-$1.out | cut -f2 -d'|'`;
echo 'applying filter on titles containing '$TITLE_MATCH' ...' >> $LOG;
#
# save the line(s) that contain the match title string. 
cat $REPT | grep -i $TITLE_MATCH > /tmp/temptitles-$1.out;
# echo "/tmp/temptitles-$1.out: " >> $LOG;
# echo `cat /tmp/temptitles-$1.out` >> $LOG;
COUNTER=`wc -l /tmp/temptitles-$1.out | cut -f1 -d' '`;
# echo "count: "$COUNTER >> $LOG;
if [ "$COUNTER" == "0" ]; then
	# search with quotes to compensate for space characters
	# echo "trying a different search " >> $LOG;
	cat $REPT | grep -i "$TITLE_MATCH" > /tmp/temptitles-$1.out;
	# echo "new temptitles:" >> $LOG;
	# echo `cat /tmp/temptitles-$1.out` >> $LOG;
	COUNTER=`wc -l /tmp/temptitles-$1.out | cut -f1 -d' '`;
	# echo "revised count: "$COUNTER >> $LOG;
else
	cat $REPT | grep ITEM_BARCODE > /tmp/filtered-$1.out;
fi
#
# combine the column heading and filtered titles into one file
cat /tmp/temptitles-$1.out >> /tmp/filtered-$1.out
#
# replace the original file with the filtered result
mv /tmp/filtered-$1.out $REPT
#
echo 'finished filtering by title' >> $LOG

