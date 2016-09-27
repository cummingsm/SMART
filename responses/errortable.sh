#!/bin/bash
# FILENAME: errortable.sh
# FILEPATH: {docroot}/cgi-bin/responses/
# PARAMS  : error message, search type
# OUTPUT  : HTML table with the error message
#           will be saved in /tmp/ having name format $1BLX-$i.out
# PURPOSE : Gives users form validation error feedback
#
echo  "<TABLE ><TR><TD>";
echo   $1;
echo  "</TD></TR>";
# tips
if [[ "$2" == "BAR" ]]; then
	echo "<TR><TD><BR>Here is an example of a Barcode: 32882014229523 </TD></TR>";
	echo "<TR><TD><BR>Barcode is the <i>default</i> search type. If you meant to search by BIBID try again and be sure to select BIBID </TD></TR>";
fi
#if [[ "$2" == "ISBN" ]]; then
	#echo "<TR><TD><BR>Here is an example of an ISBN: 9780393239928 </TD></TR>";
#fi
#if [[ "$2" == "ISSN" ]]; then
	#echo "<TR><TD><BR>Here is an example of an ISSN: 0003-8520 </TD></TR>";
#fi
#if [[ "$2" == "OCLC" ]]; then
	#echo "<TR><TD><BR>Here is an example of an OCLC Number: 04831599 </TD></TR>";
#fi
#if [[ "$2" == "LCCN" ]]; then
	#echo "<TR><TD><BR>Here is an example of an LCCN: 23009631 </TD></TR>";
#fi
echo  "<TR><TD> &nbsp; </TD></TR>";
echo  "<TR><TD> &lt; &lt; <A HREF='../wrlc/smart.html'>Try Again</a>";
echo  "</TD></TR></TABLE>";

