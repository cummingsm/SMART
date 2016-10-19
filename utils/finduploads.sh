#!/bin/bash
#
# FILENAME: finduploads.sh
# FILEPATH: {docroot}/cgi-bin/utils/
# PARAMS  : none
#	    This script will be called by a cron job
# OUTPUT  : If this script finds a file awaiting processing in the upload directory
#	    it moves the file to the process directory and call the bulkprocessing script.
#	    Initializes a JOB LOG.
# PURPOSE : Find pending files, trigger bulkprocessing.
#
# There could be none, one, or possibly more than one file in the upload directory.
# The file name is based on a timestamp. Sorting would make the 
# oldest file with the lowest filename first in the uploads.txt file
#
ls /var/www/wrlc/upload | sort > /tmp/uploads.txt
max=`wc -l /tmp/uploads.txt | cut -f1 -d' '`;
if [[ $max > 0 ]]; then
	JOB=`awk NR==1 /tmp/uploads.txt`; 
	JOBLOG=/var/www/wrlc/log/JOB-$JOB.log
	# Move the list of barcodes into the process directory
	# and then call the script that performs the bulk processing.
	mv /var/www/wrlc/upload/$JOB /var/www/wrlc/process/$JOB
	echo "TIMER|"`date +%T`"|START bulk process"   >> $JOBLOG
	bash /var/www/cgi-bin/utils/bulkprocess.sh $JOB;
fi
