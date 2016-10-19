#!/bin/bash
#
# FILENAME: validatebarcodes.sh
# FILEPATH: {docroot}/cgi-bin/utils/
# PARAMS  : full path name of file with barcodes
# OUTPUT  : returns error message string if any
# PURPOSE : validate the file has correctly formatted barcodes
#
#
inputfile=$1
max=`wc -l $1 | cut -f1 -d' '`;
errorcount=0
for (( i=1; i<=$max; i++ ))
do
	LINEVAL=`awk NR==$i $inputfile`;
	LASTDIGIT=`echo ${LINEVAL:13:13}`
	if [[  "$LASTDIGIT" < "0" ]]; then
	((errorcount++))
	fi
done
if [[ "$errorcount" == "0" ]]; then
	echo '0';
else
	echo 'Found '$errorcount' error(s) in the inputfile '$inputfile
fi
