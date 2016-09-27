#!/bin/bash
#
# FILENAME: notmatchfound.sh
# FILEPATH: {docroot}/cgi-bin/responses/
# PARAMS  : bibid, search value
# OUTPUT  : HTML table with no match message 
# PURPOSE : Displays feedback to the the user that no match was found for their request
#
##
# nothing matched response
echo " <TABLE CELLSPACING='1' CELLPADDING='2' BORDER='0' WIDTH='90%' BGCOLOR='CORNSILK'>";
echo "<TR> <TD><br><p>&nbsp; Nothing matched the information you requested.</p> <p> &nbsp; ID Type: <strong>";
	   echo $1;
	   echo "</strong> &nbsp; Value: <strong>";
	   echo $2;
	   echo "</strong><br><br></td>";
echo "</TR>";
echo  "<TR><TD>";
echo "<p> &lt; &lt; <A HREF='../wrlc/smart.html'>Go back</a>";
echo "</TD></TR></TABLE>";

