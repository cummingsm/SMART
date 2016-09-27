#!/bin/bash
#
# FILENAME: logger.sh
# FILEPATH: {docroot}/cgi-bin/utils/
# PARAMS  : path to a log file, a string of text
# OUTPUT  : the specified log file will have the string of text appended
# PURPOSE : Log progress. Alternative to executing an echo command
#
# $1 is the logfile
# $2 is the text
# 
echo $2  >> $1
