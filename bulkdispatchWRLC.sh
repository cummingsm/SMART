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
#
# Working log file
LOG=/var/www/wrlc/log/BIBID-$1.log
echo "TIMER|"`date +%T`"|START" >> $LOG
echo "TIMER|"`date +%T`"|dispatchWRLC.sh" >> $LOG
echo "Parameters: $thisbibid $idtype $request " >> $LOG
# the following syntax counts characters in the bibid
if [ ${#thisbibid} -ne 0 ]
	then
	{
	# --------------------------------------------
	# SAVE THE ORIGINAL BIB BY DEFAULT
	# --------------------------------------------
	#
	echo "$1|default" > /tmp/$1BBX-0.out
	bash /var/www/cgi-bin/utils/reformatsql.sh $thisbibid 'BD'
	#
	# ---------------------------------------------
	# GET THE STANDARD NUMS FOR THIS BIB RECORD
	# ---------------------------------------------
	#
	bash /var/www/cgi-bin/queries/2getlccn.sh $thisbibid 
	bash /var/www/cgi-bin/queries/3getisbn.sh $thisbibid
	bash /var/www/cgi-bin/queries/4getoclc.sh $thisbibid
	bash /var/www/cgi-bin/queries/5getissn.sh $thisbibid
	chmod 777 /tmp/$1*out
	bash /var/www/cgi-bin/utils/cleanup.sh $thisbibid
 	bash /var/www/cgi-bin/utils/logcounts.sh $thisbibid
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
		bash /var/www/cgi-bin/queries/6searchlccn.sh $thisbibid 'BL'
		}
	fi
	# 
	isbnfile=/tmp/$1BI.out
	BIcount=`wc -l $isbnfile | cut -f1 -d' '`
	if [ $BIcount != 0 ]
   		then
   		{
		bash /var/www/cgi-bin/queries/7searchisbn.sh $thisbibid 'BI'
		}
	fi
	# 
	oclcfile=/tmp/$1BO.out
	BOcount=`wc -l $oclcfile | cut -f1 -d' '`
	if [ $BOcount != 0 ]
   		then
   		{
		bash /var/www/cgi-bin/queries/8searchoclc.sh $thisbibid 'BO'
		}
	fi
	# 
	issnfile=/tmp/$1BS.out
	BScount=`wc -l $issnfile | cut -f1 -d' '`
	if [ $BScount != 0 ]
   		then
   		{
		bash /var/www/cgi-bin/queries/9searchissn.sh $thisbibid 'BS'
		}
	fi
	# -----------------------------------------------
	# COMBINE RESULTS OF SEARCHES INTO BIBS TO SEARCH
	# -----------------------------------------------
	#
	bash /var/www/cgi-bin/utils/makebiblist.sh $thisbibid
	#
	# -----------------------------------------------
	# GET THE WRLC ITEMS FOR ALL OF THE SELECTED BIBS
	# -----------------------------------------------
	#
	biblist=`cat /tmp/$1QRYSET.out`
	bash /var/www/cgi-bin/queries/10searchitems.sh $thisbibid $biblist
	#
	# ---------------------------------------
	# TRIM SPACES from SQL OUTPUT; 
	# TRANSLATE CERTAIN WRLC LOCS TO "IS_SCF"
	# ---------------------------------------
	#
	bash /var/www/cgi-bin/utils/reformatitemsql.sh $thisbibid
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
