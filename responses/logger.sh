#!/bin/bash
#
# FILENAME: logger.sh
# FILEPATH: {docroot}/cgi-bin/responses/
# PARAMS  : logfile, message
# OUTPUT  : saves the message in the logfile
# PURPOSE : log messages
#
#
# logger.sh
# $1 is the logfile
# $2 is the text
# 
echo $2  >> $1
