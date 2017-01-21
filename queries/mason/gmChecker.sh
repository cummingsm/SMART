#!/bin/bash
# FILENAME: gmChecker.sh
# FILEPATH: {docroot}/cgi-bin/queries/mason/
# PARAMS  : bibid 
# OUTPUT  : The BIBID(s) that are GM records are saved in /tmp/$1GMLINES.txt
#           the rest are saved in /tmp/$1NOTGMLINES.txt
# PURPOSE : Calls gmRetriever.sh which will find and append items to the 
#	    rest of the data in /var/www/wrlc/$1-REPORT.txt
#
# $1 is the prefix to the REPORT. It is the same as the bibid used
# in the processing up to this point
# 
LOG=/var/www/wrlc/log/BIBID-$1.log;
echo 'report file before testing for GM' >> $LOG
echo 'received title' >> $LOG
echo $2 >> $LOG
GMcount=`grep -c 'GM|' /var/www/wrlc/report/$1-REPORT.txt`;
if [[ "$GMcount" != "0" ]]; then
	# ------------------------------------------------------------------
	# Split orginal report into two files: GM and non-GM holdings
	# ------------------------------------------------------------------
	echo 'found '$GMcount' GM holding(s) in report' >> $LOG
	grep 'GM|' /var/www/wrlc/report/$1-REPORT.txt   > /tmp/$1GMLINES.txt
	#
	grep -v 'GM|' /var/www/wrlc/report/$1-REPORT.txt > /tmp/$1NOTGMLINES.txt
	#
	# test for special case where there are ONLY GM 
	linecount=`wc -l /tmp/$1NOTGMLINES.txt | cut -f1 -d' '`
	# echo $linecount
	if [[ "$linecount" == "1" ]]; then
		head -1 /tmp/$1GMLINES.txt > /tmp/$1detailVZ.out;
		echo 'GM ONLY! saved original line' 	>> $LOG;
	fi
	#
	# ---------------------------------------------
	# Get some fields from each line of GM holdings
	# ---------------------------------------------
	lines=`wc -l /tmp/$1GMLINES.txt | cut -f1 -d' '`;
	# echo 'lines is set to '$lines
	#
	for (( i=1; i<=$lines; i++ ))
	do
		awk NR==$i /tmp/$1GMLINES.txt > /tmp/$i.out;
		thisvBib=`cat /tmp/$i.out   | cut -f2  -d'|'`;
		thisvMfhd=`cat /tmp/$i.out  | cut -f3  -d'|'`;
		thisLine=`cat /tmp/$i.out`;
		# echo 'this is the line right now';
		# echo $thisLine;
		#
		# -------------------------------------------------
		# Scrape GM Catalog 
		# -------------------------------------------------
		#
		echo 'calling gmRetriever.sh'$1 $thisvBib $thisvMfhd $2 >> $LOG;
		# $1 is the WRLC bib passed to the gmChecker script
		# $thisvBib will be the same unless we are processing
		#  more than one line in GMLINES
		#
		bash /var/www/cgi-bin/queries/mason/gmRetriever.sh  $1 $thisvBib $thisvMfhd $2
		#
		# ---------------------------------------
		# Append scraped results to file containg header
		# and the non-GM results.
		# 
		# --------------------------------------- 
		#
		cat /tmp/$1*VZ.out >> /tmp/$1NOTGMLINES.txt
		#rm /tmp/$1*VZ.out
	done
	rm /tmp/*VZ.out
	mv /tmp/$1NOTGMLINES.txt /var/www/wrlc/report/$1-REPORT.txt
else
	# ---------------------------------------
	# There are no GM holdings, so do nothing
	# ---------------------------------------
	echo "No GM holdings in Voyager output" >> $LOG;
fi
