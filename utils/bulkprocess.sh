#!/bin/bash
#
# FILENAME: bulkprocess.sh
# FILEPATH: {docroot}/cgi-bin/utils/
# PARAMS  : JOBID (equivalent to file name)
# OUTPUT  : The result will be the data for all the barcodes in the upload file.
# PURPOSE : Generate the data for a set of barcodes contained in a file the user uploaded.
#
# TODO: update cron job
#
# echo "TIMER|"`date +%T`"|FINISH" >> $LOG
JOBID=$1;
JOBFILE=/var/www/wrlc/process/$JOBID
JOBLOG=/var/www/wrlc/log/JOB-$JOBID.log
#
# -------------------------------
# Get the job information line
# -------------------------------
# the last line of the barcode list file has information in the form:
# JOBINFO|barbglist.txt|michaelc@gwu.edu|147145012
#
INFOLINE=`grep '|' $JOBFILE`;
USERFILE=`echo $INFOLINE | cut -f2 -d'|'`;
EMAILTO=`echo $INFOLINE | cut -f3 -d'|'`;
#
# ------------------------------
# Keep only barcodes in the file
# ------------------------------
grep -v '|' $JOBFILE > savefile
mv savefile $JOBFILE
echo $INFOLINE
echo $USERFILE
echo $EMAILTO
#
# ------------------------------
# Read $JOBFILE get each barcode 
# ------------------------------
max=`wc -l $JOBFILE | cut -f1 -d' '`;
for (( i=1; i<=$max; i++ ))
	do
		# Specify column 1-14 because there may be a newline character which would interfere with the query
		BARCODE=`awk NR==$i $JOBFILE | cut -c1-14`;
		# Replace leading or trailing blank spaces
		BIBID=`bash /var/www/cgi-bin/queries/1getbibforbarcode.sh $BARCODE | awk NR==4 | cut -f1 -d'|' | sed 's/ //g'`;
		echo $BARCODE'|'$BIBID >> $JOBLOG;
		#
		bash /var/www/cgi-bin/queries/bulkdispatchWRLC.sh $BIBID BAR $BARCODE
		bash /var/www/cgi-bin/utils/filtertitles.sh $BIBID
		bash /var/www/cgi-bin/utils/dedupStatus.sh $BIBID
		bash /var/www/cgi-bin/queries/dispatchGM.sh $BIBID BAR $BARCODE
		bash /var/www/cgi-bin/utils/bulkcruncher.sh $BIBID $BARCODE
		rm /tmp/$BIBID*
		# add this report data to the combined report 
		grep -v PUBPLACE /var/www/wrlc/report/$BIBID-REPORT.txt >> /var/www/wrlc/report/JOB-$JOBID.txt
	done
#
# ---------------------------------
# INSERT COLUMNS HEADER before data
# ---------------------------------
grep PUBPLACE /var/www/wrlc/report/$BIBID-REPORT.txt > /var/www/wrlc/report/heading.txt
cat /var/www/wrlc/report/JOB-$JOBID.txt >> /var/www/wrlc/report/heading.txt
mv /var/www/wrlc/report/heading.txt /var/www/wrlc/report/JOB-$JOBID.txt
#
#-------------------------------
# Post-processing email
#-------------------------------
#
#
echo "Subject: SMART report results for "$JOBID  > mail.txt
echo "From: SMART" >> mail.txt
echo "This is an automated response to a request to process a file of barcodes. Do not reply." >> mail.txt
echo "The barcodes in the file you uploaded, "$USERFILE "have been processed." >> mail.txt
echo "The report data file is now available for download from the following address." >> mail.txt
echo "http://gwreports.wrlc.org/wrlc/report/JOB-"$JOBID".txt" >> mail.txt
echo " " >> mail.txt
recordcount=`grep -c -v PUBPLACE /var/www/wrlc/report/JOB-$JOBID.txt`;
filesize=`wc -c /var/www/wrlc/report/JOB-$JOBID.txt | cut -f1 -d' '`;
echo "The report data includes "$recordcount" items. The file size is "$filesize" bytes." >> mail.txt
echo "Summary log" >> mail.txt
cat $JOBLOG >> mail.txt
echo >> mail.txt
echo "Thank you." >> mail.txt
echo "To report a problem, visit http://gwreports.wrlc.org/wrlc/smart.html and click the Feeback link." >> mail.txt
mail -s $JOBID $EMAILTO < mail.txt
