#!/bin/bash
#
# FILENAME: dispatchWRLC.sh
# FILEPATH: {docroot}/cgi-bin/queries/
# PARAMS  : bib, idtype, request type, output option
# OUTPUT  : n.a.
# PURPOSE : This script calls other scripts that handle all the 
#	    queries and calculations related to WRLC bib records.
#	    Another script, dispatchGM.sh is invoked when there
#	    are Mason records in the search result. 
#
# Parameters
thisbibid=$1
idtype=$2
request=$3
output=$4
#
# Working log file
LOG=/var/www/wrlc/log/BIBID-$1.log
echo "TIMER|"`date +%T`"|START" >> $LOG
echo "TIMER|"`date +%T`"|dispatchWRLC.sh" >> $LOG
echo "Parameters: $thisbibid $idtype $request $output" >> $LOG
# the following syntax counts characters in the bibid
if [ ${#thisbibid} -ne 0 ]
	then
	{
	# --------------------------------------------
	# SAVE THE ORIGINAL BIB BY DEFAULT
	# --------------------------------------------
	#
	echo "$1|default" > /tmp/$1BBX-0.out
	bash utils/reformatsql.sh $thisbibid 'BD'
	#
	# ---------------------------------------------
	# GET THE STANDARD NUMS FOR THIS BIB RECORD
	# ---------------------------------------------
	#
	bash queries/2getlccn.sh $thisbibid 
	bash queries/3getisbn.sh $thisbibid
	bash queries/4getoclc.sh $thisbibid
	bash queries/5getissn.sh $thisbibid
	chmod 777 /tmp/$1*out
	bash utils/cleanup.sh $thisbibid
 	bash utils/logcounts.sh $thisbibid
	#
	# ----------------------------------------------
	# SEARCH WRLC BIB RECORDS FOR MATCHING NUMBERS
	# ----------------------------------------------
	# 
	lccnfile=/tmp/$1BL.out
	BLcount=`wc -l $lccnfile | cut -f1 -d' '`
	if [ $BLcount != 0 ]
   		then
   		{
		bash queries/6searchlccn.sh $thisbibid 'BL'
		}
	fi
	# 
	isbnfile=/tmp/$1BI.out
	BIcount=`wc -l $isbnfile | cut -f1 -d' '`
	if [ $BIcount != 0 ]
   		then
   		{
		bash queries/7searchisbn.sh $thisbibid 'BI'
		}
	fi
	# 
	oclcfile=/tmp/$1BO.out
	BOcount=`wc -l $oclcfile | cut -f1 -d' '`
	if [ $BOcount != 0 ]
   		then
   		{
		bash queries/8searchoclc.sh $thisbibid 'BO'
		}
	fi
	# 
	issnfile=/tmp/$1BS.out
	BScount=`wc -l $issnfile | cut -f1 -d' '`
	if [ $BScount != 0 ]
   		then
   		{
		bash queries/9searchissn.sh $thisbibid 'BS'
		}
	fi
	# -----------------------------------------------
	# COMBINE RESULTS OF SEARCHES INTO BIBS TO SEARCH
	# -----------------------------------------------
	#
	bash utils/makebiblist.sh $thisbibid
	#
	# -----------------------------------------------
	# GET THE WRLC ITEMS FOR ALL OF THE SELECTED BIBS
	# -----------------------------------------------
	#
	biblist=`cat /tmp/$1QRYSET.out`
	bash queries/10searchitems.sh $thisbibid $biblist
	#
	# ---------------------------------------
	# TRIM SPACES from SQL OUTPUT; 
	# TRANSLATE CERTAIN WRLC LOCS TO "IS_SCF"
	# ---------------------------------------
	#
	bash utils/reformatitemsql.sh $thisbibid
	# 
	# ------------------------------------------
	# NEED TO GET DATA FROM GEORGE MASON MAGIK?
	# ------------------------------------------
	#
	#
	#
	}
	else
	echo "No bibid for the barcode was identified. Processing stopped." >> $LOG
fi
#
# ALL DONE
