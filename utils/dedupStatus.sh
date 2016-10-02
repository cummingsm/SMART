#!/bin/bash
#
# FILENAME:
# FILEPATH: /var/www/cgi-bin/utils/
# PARAMS  : bibid
# OUTPUT  : revised copy of report 
# PURPOSE : Find items with status of lost, missing, withdrawan, damaged
#	    Keep those statuses, and remove any other rows for the
#	    same barcode. Voyager has multiple statuses per item.
#
#
LOG=/var/www/wrlc/log/BIBID-$1.log
sourcefile=/var/www/wrlc/report/$1-REPORT.txt
savefile=/tmp/$1-SPECIAL.out
workfile=/tmp/$1-WORK.out
# -----------------------------------------
# CHECK FOR SELECTED ITEM STATUSES
# -----------------------------------------
LOST=`grep -c '|Lost' $sourcefile`;
MISS=`grep -c '|Missing' $sourcefile`;
WDRW=`grep -c '|Withdrawn' $sourcefile`;
DAMG=`grep -c '|Damaged' $sourcefile`;
#
# ----------------------------------------
# EXTRACT FOUND STATUSES TO $savefile
# EXTRACT THE REST TO $workfile and then
# make the workfile the new sourcefile
# ---------------------------------------
if [[ "$LOST" > "0" ]]; then
	echo 'Found an item status of Lost' >> $LOG
	grep '|Lost'   $sourcefile 	 >> $savefile
        grep -v '|Lost' $sourcefile	 >  $workfile
	mv $workfile   $sourcefile
fi
if [[ "$MISS" > "0" ]]; then
	echo 'Found an item status of Missings' >> $LOG
	grep '|Missing'    $sourcefile 	 >> $savefile
	grep -v '|Missing' $sourcefile   >  $workfile
	mv $workfile       $sourcefile
fi
if [[ "$WDRW" > "0" ]]; then
	echo 'Found an item status of Withdrawn' >> $LOG
	grep '|Withdrawn'    $sourcefile >> $savefile
	grep -v '|Withdrawn' $sourcefile  > $workfile
	mv $workfile         $sourcefile
fi
if [[ "$DAMG" > "0" ]]; then
	echo 'Found an item status of Damaged' >> $LOG
	grep '|Damaged'    $sourcefile 	 >> $savefile
	grep -v '|Damaged' $sourcefile   > $workfile
	mv $workfile       $sourcefile
fi
# ----------------------------------------
# IF ANY ARE IN SAVED FILE, FIND AND PULL
# THEIR MATCHING ROW BASED ON BARCODE (f5)
# ----------------------------------------
if [ -e $savefile ]
then
	max=`wc -l $savefile | cut -f1 -d' '`;
	for (( i=1; i<=$max; i++ ))
	do
		awk NR==$i $savefile > /tmp/$1SAVELINE.out;
		barcode=`cat /tmp/$1SAVELINE.out | cut -f5 -d'|'`;
		grep -v $barcode $sourcefile > /tmp/$1UNMATCHED.out;
		    cat /tmp/$1SAVELINE.out >> /tmp/$1UNMATCHED.out;
		                            mv /tmp/$1UNMATCHED.out $sourcefile;
	done
	rm $savefile
else
	echo 'No lost, missing, damaged items' >> $LOG
fi

