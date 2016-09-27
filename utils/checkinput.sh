#!/bin/bash
#
# FILENAME: checkinput.sh
# FILEPATH: {docroot}/cgi-bin/utils/
# PARAMS  : id type and search value
# OUTPUT  : returns error message string if any
# PURPOSE : validate form input
#
# $1=the id type, eg BAR, ISBN, ISSN, OCLC, BIB
# $2=the search value, eg 2342-1242
# -------------------------------------------
ErrorMessage='';
# Search value is required
if [ "$2" == "" ]; then
	ErrorMessage='Kind of trigger happy are you? Type something in the search field to tell me what we should be searching.<br>';
fi 
# No spaces are allowed 
if [[ $2 == *" "* ]]; then
   	ErrorMessage=$ErrorMessage'<br>Hey there pardner, no spaces are allowed. You might have copied and pasted a trailing space character into the search field.';
fi 
# No alphabetical characters are allowed except in ISBN or ISSN
[[ "$2" = *[^0-9]* ]]
if [[ $? == 0 ]]; then
	if [[ "$1" != "ISBN" ]]; then
	  # that would have been alright 
	  if [[ "$1" != "ISSN" ]]; then
                # that would have ok too
		# so if neither of those
   		ErrorMessage=$ErrorMessage'<br>Dag nabbit you put something other than numbers in there.';
	  fi
	fi
fi
# An id_type is required (BAR, ISBN, ISSN, LCCN, OCLC, BIB are expected)
if [ "$1" == "" ]; then
   	ErrorMessage=$ErrorMessasge'<br>Whoa nellie. The id type is missing.<br>';
fi
# The barcode for id type BAR must contain 14 characters
if [[ "$1" == "BAR" && ${#2} != 14 ]]; then
   	ErrorMessage=$ErrorMessage'<br>You may have to reload. Barcodes need to be 14 characters greenhorn.';
fi
# The value of ISBN for id type IBSN must contain 10 or 13 characters
if [[ "$1" == "ISBN" && ${#2} != 10 ]]; then
	if [[ ${#2} != 13 ]]; then
   		ErrorMessage=$ErrorMessage'<br>You are off target. What part of ISBN 10 or 13 digits did you not understand?';
	fi
fi
## The value of ISSN for id type ISSN must contain 9 characters. Don't worry about format 0000-0000 for now.
if [[ "$1" == "ISSN" && ${#2} != 9 ]]; then
   	ErrorMessage=$ErrorMessage'<br>Those dern ISSN values need to be 9 characters my friend.';
fi
#
# return result
echo $ErrorMessage;
