#!/bin/bash
#
# FILENAME: pageheader.sh
# FILEPATH: {docroot}/cgi-bin/responses/
# PARAMS  : none
# OUTPUT  : start of HTML page, navigation links
# PURPOSE : Displays navigation links on result page
#
echo "
<HTML><HEAD>
<TITLE>SMART (Shared Materials Audit Reporting Tool)</TITLE></HEAD>
<table bgcolor="#FFFFFF" cellpadding="4" cellspacing="1" border="0" width='90%'>
<tr><td><H3>SMART</H3></td></tr>
</table>
<TABLE BGCOLOR='#FFFFFF' CELLPADDING='1' CELLSPACING='1' BORDER='0' WIDTH='90%'>";
# navigation
        echo "<tr><td>Check an item results";
        echo "| <A HREF='../wrlc/smart.html'>New search</a>";
        echo "| <a href='../wrlc/about.html'>About</a>  | <a href='../wrlc/help.html'>Help</a>";
	echo "| <a href='https://goo.gl/forms/yFqrPaeZ1TPP5sWH2'>Feedback</a></td>";
	echo "<TD WIDTH='40%'> &nbsp; </TD></TR>";
	echo "<TR><TD colspan='2'> &nbsp; </TD></TR></TABLE>";


