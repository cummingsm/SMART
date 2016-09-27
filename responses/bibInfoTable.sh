#!/bin/bash
#
# FILENAME: bibInfoTable.sh
# FILEPATH: {docroot}/cgi-bin/responses/
# PARAMS  : bibid, searchvalue, searchtype
# OUTPUT  : HTML table with bibliographic information, count by title
# PURPOSE : Identifies the work, shows how many bibs for there are by library
#
# Parameters
#  $1 = bibid
#  $2 = searchvalue
#  $3 = searchtype
LOG=/var/www/wrlc/log/BIBID-$1.log
echo "TIMER|"`date +%T`"|bibInfoTable" >> $LOG
#
# -------------------------
# BIBLIOGRAPHIC INFORMATION
# -------------------------
#
# use the bib info from the bib that was requested
#grep $1 /var/www/wrlc/report/$1-REPORT.txt > /tmp/$1-reportlines.out
#ROW=`tail -1 /tmp/$1-reportlines.out`
ROW=`tail -1 /var/www/wrlc/report/$1-REPORT.txt`;
CHECKTITLE=`echo $ROW   | cut -f22 -d'|'`
if [[ "$CHECKTITLE" == "" ]]; then
	ROW=`head -2 /var/www/wrlc/report/$1-REPORT.txt | tail -1`;
fi
# get fields from that line
TITLE=`echo $ROW 	| cut -f22 -d'|'`
AUTHOR=`echo $ROW 	| cut -f23 -d'|'`
PUBLISHER=`echo $ROW 	| cut -f25 -d'|'`
PUBPLACE=`echo $ROW 	| cut -f26 -d'|'`
PUBDATE=`echo $ROW 	| cut -f27 -d'|'`
SERIES=`echo $ROW 	| cut -f28 -d'|'`
EDITION=`echo $ROW 	| cut -f24 -d'|'`
ISBN=`echo $ROW 	| cut -f12 -d'|'`
ISSN=`echo $ROW 	| cut -f13 -d'|'`
LCCN=`echo $ROW 	| cut -f14 -d'|'`
OCLC=`echo $ROW 	| cut -f15 -d'|'`
THISBIB=`echo $ROW 	| cut -f2  -d'|'`
BIBSUPP=`echo $ROW 	| cut -f11  -d'|'`
#
# print the bib info section of the response
#
echo "<TABLE BGCOLOR='#EAEAEA' CELLPADDING='2' CELLSPACING='1' WIDTH='90%' BORDER='0'>"
echo "<TR BGCOLOR='#EAEAEA'><TD COLSPAN='4'>Bibliographic Information (using "$THISBIB;
if [ "$BIBSUPP" == "Y" ]; then
	echo "<FONT COLOR='RED'>Suppressed Bib</FONT>";
fi
echo ") </TD><TR>";
echo "<TR bgcolor='#FFFFFF'>";
	echo "<TD> Title: </TD><TD>" $TITLE;
	echo "</TD><TD>ISBN: </TD><TD>"$ISBN" &nbsp; </TD></TR>";
if [ "$AUTHOR" != "" ]; then
	echo "<tr bgcolor='#FFFFFF'><td> Author: </td><td>"$AUTHOR"</td>";
	echo "<TD colspan='2'> &nbsp; </TD></TR>";
fi
echo "<TR bgcolor='#FFFFFF'>";
echo 	"<TD> Publisher: </TD><TD>" $PUBLISHER $EDITION $PUBPLACE $PUBDATE $EDITION  "</td>";
echo 	"<TD>ISSN: </TD><TD>"$ISSN" &nbsp; </TD></TR>";
echo "<TR bgcolor='#FFFFFF'>";
echo 	"<TD> OCLC:</TD><TD>"$OCLC" &nbsp; </TD><TD>LCCN:</TD><TD>"$LCCN" &nbsp; </TD></TR>";
if [ "$SERIES" != "" ]; then
	echo "<TR bgcolor='#FFFFFF'><TD>Series: </TD><TD>"$SERIES"</TD>";
	echo "<TD colspan='2'> &nbsp; </TD></TR>";
fi
echo "</TABLE>"
# ---------------------------------------------------
# COUNT BY LIBRARY
# ---------------------------------------------------
# Get count by library. There are 23 in Voyager
# Some of these might not be necessary. 
#
# nine main univeristy libraries
DATA=/var/www/wrlc/report/$1-REPORT.txt
#
AULIB=`cat $DATA | grep  'AU|' | grep -cv IS_SCF `;
AUSCF=`cat $DATA | grep  'AU|' | grep -c IS_SCF `;
#
CULIB=`cat $DATA | grep  'CU|' | grep -cv IS_SCF `
CUSCF=`cat $DATA | grep  'CU|' | grep -c IS_SCF `;
#
DCLIB=`cat $DATA | grep  'DC|' | grep -cv IS_SCF `
DCSCF=`cat $DATA | grep  'DC|' | grep -c IS_SCF `;
#
GALIB=`cat $DATA | grep  'GA|' | grep -cv IS_SCF `
GASCF=`cat $DATA | grep  'GA|' | grep -c IS_SCF `;
#
GMLIB=`cat $DATA | grep  'GM|' | grep -cv IS_SCF `
GMSCF=`cat $DATA | grep  'GM|' | grep -c IS_SCF `;
#
GTLIB=`cat $DATA | grep  'GT|' | grep -cv IS_SCF `
GTSCF=`cat $DATA | grep  'GT|' | grep -c IS_SCF `;
#
GWLIB=`cat $DATA | grep  'GW|' | grep -cv IS_SCF `
GWSCF=`cat $DATA | grep  'GW|' | grep -c IS_SCF `
#
HULIB=`cat $DATA | grep  'HU|' | grep -cv IS_SCF `
HUSCF=`cat $DATA | grep  'HU|' | grep -c IS_SCF `;
#
MULIB=`cat $DATA | grep  'MU|' | grep -cv IS_SCF `
MUSCF=`cat $DATA | grep  'MU|' | grep -c IS_SCF `;
#
# five law libraries
# Note when countng AL exclude JOURNAL ;-)
ALLIB=`cat $DATA | grep  'AL|' | grep -v 'JOURNAL' | grep -cv IS_SCF `
ALSCF=`cat $DATA | grep  'AL|' | grep -v 'JOURNAL' | grep -c IS_SCF `;
#
HLLIB=`cat $DATA | grep  'HL|' | grep -cv IS_SCF `
HLSCF=`cat $DATA | grep  'HL|' | grep -c IS_SCF `;
#
JBLIB=`cat $DATA | grep  'JB|' | grep -cv IS_SCF `
JBSCF=`cat $DATA | grep  'JB|' | grep -c IS_SCF `;
#
GTLLIB=`cat $DATA | grep 'GTL|' | grep -cv IS_SCF `
GTLSCF=`cat $DATA | grep 'GTL|' | grep -c IS_SCF `;
#
# Note when counting LL exclude CALL ;-)
LLLIB=`cat $DATA | grep  'LL|' | grep -v CALL | grep -cv IS_SCF `
LLSCF=`cat $DATA | grep  'LL|' | grep -v CALL | grep -c IS_SCF `;
#
# two medical libraries
HILIB=`cat $DATA | grep  'HI|' | grep -cv IS_SCF `
HISCF=`cat $DATA | grep  'HI|' | grep -c IS_SCF `;
#
HSLIB=`cat $DATA | grep  'HS|' | grep -cv IS_SCF `
HSSCF=`cat $DATA | grep  'HS|' | grep -c IS_SCF `;
#
# Six other entries in the Voyager library table
# WR, TR, DA, LI, E-Resources, E-GovDoc
WRLIB=`cat $DATA | grep  'WR|' | grep -cv IS_SCF `
WRSCF=`cat $DATA | grep  'WR|' | grep -c IS_SCF `;
#
TRLIB=`cat $DATA | grep  'TR|' | grep -cv IS_SCF `
TRSCF=`cat $DATA | grep  'TR|' | grep -c IS_SCF `;
#
LILIB=`cat $DATA | grep  'LI|' | grep -cv IS_SCF `
LISCF=`cat $DATA | grep  'LI|' | grep -c IS_SCF `;
#
DALIB=`cat $DATA | grep  'DA|' | grep -cv IS_SCF `
DASCF=`cat $DATA | grep  'DA|' | grep -c IS_SCF `;
#
ERLIB=`cat $DATA | grep  -i 'E-RESOURCES|' | grep -v au | grep -cv IS_SCF `
ERSCF=`cat $DATA | grep  -i 'E-RESOURCES|' | grep -v au | grep -c IS_SCF `;
#
GDLIB=`cat $DATA | grep  -i 'E-GOVDOC|' | grep -cv IS_SCF `
GDSCF=`cat $DATA | grep  -i 'E-GOVDOC|' | grep -c IS_SCF `;
#
# sum to get subtotal amounts
SUBTOTALMAINLIB=`expr $AULIB + $CULIB + $DCLIB + $GALIB + $GMLIB + $GTLIB + $GWLIB + $HULIB + $MULIB `;
SUBTOTALMAINSCF=`expr $AUSCF + $CUSCF + $DCSCF + $GASCF + $GMSCF + $GTSCF + $GWSCF + $HUSCF + $MUSCF `;
#
SUBTOTALLAWLIB=`expr $ALLIB + $JBLIB + $GTLLIB + $HLLIB + $LLLIB `;
SUBTOTALLAWSCF=`expr $ALSCF + $JBSCF + $GTLSCF + $HLSCF + $LLSCF `;
#
SUBTOTALMEDLIB=`expr $HILIB + $HSLIB `;
SUBTOTALMEDSCF=`expr $HISCF + $HSSCF `;
#
SUBTOTALOTHLIB=`expr $WRLIB + $TRLIB + $LILIB + $DALIB + $ERLIB + $GDLIB `;
SUBTOTALOTHSCF=`expr $WRSCF + $TRSCF + $LISCF + $DASCF + $ERSCF + $GDSCF `;
#
# sum to get total amounts
TOTALLIB=`expr $SUBTOTALMAINLIB + $SUBTOTALLAWLIB + $SUBTOTALMEDLIB + $SUBTOTALOTHLIB `;
TOTALSCF=`expr $SUBTOTALMAINSCF + $SUBTOTALLAWSCF + $SUBTOTALMEDSCF + $SUBTOTALOTHSCF `;
#
#
# ---------------------------------------
# TABLE OF COUNTS BY LIBRARY
# ---------------------------------------
#
echo "<BR><TABLE BGCOLOR='#EAEAEA' CELLPADDING='2' CELLSPACING='1' BORDER='0' WIDTH='90%'>" ;
echo "<TR BGCOLOR='#EAEAEA'><TD COLSPAN='4'>Summary Counts by Library</TD></TR>" ;
echo "<TR BGCOLOR='#FFFFFF'><TD COLSPAN='2'> LIBRARY </TD><TD ALIGN='RIGHT'>IN LIBRARY</TD>";
echo "<TD ALIGN='RIGHT'>AT WRLC SCF</TD></TR>" ;
#
# the nine main libraries in alphabetical order
if [[ "$AULIB" != 0 || "$AUSCF" != 0 ]]; then
	echo "<TR BGCOLOR='#FFFFFF'><TD>American</TD><TD> AU </TD><TD ALIGN='RIGHT'>" $AULIB "</TD><TD ALIGN='RIGHT'> "$AUSCF "</TD></TR>" ;
fi
if [[ "$CULIB" != 0 || "$CUSCF" != 0 ]]; then
	echo "<TR BGCOLOR='#FFFFFF'><TD>Catholic</TD><TD> CU </TD><TD ALIGN='RIGHT'>" $CULIB "</TD><TD ALIGN='RIGHT'> "$CUSCF "</TD></TR>" ;
fi
if [[ "$DCLIB" != 0 || "$DCSCF" != 0 ]]; then
	echo "<TR BGCOLOR='#FFFFFF'><TD>District of Columbia</TD><TD> DC </TD><TD ALIGN='RIGHT'>" $DCLIB "</TD><TD ALIGN='RIGHT'> "$DCSCF "</TD></TR>" ;
fi
if [[ "$GALIB" != 0 || "$GASCF" != 0 ]]; then
	echo "<TR BGCOLOR='#FFFFFF'><TD>Gallaudet</TD><TD> GA </TD><TD ALIGN='RIGHT'>" $GALIB "</TD><TD ALIGN='RIGHT'> "$GASCF "</TD></TR>" ;
fi
if [[ "$GMLIB" != 0 || "$GMSCF" != 0 ]]; then
	echo "<TR BGCOLOR='#FFFFFF'><TD>George Mason</TD><TD> GM </TD><TD ALIGN='RIGHT'>" $GMLIB "</TD><TD ALIGN='RIGHT'> "$GMSCF "</TD></TR>" ;
fi
if [[ "$GTLIB" != 0 || "$GTSCF" != 0 ]]; then
	echo "<TR BGCOLOR='#FFFFFF'><TD>Georgetown</TD><TD> GT </TD><TD ALIGN='RIGHT'>" $GTLIB "</TD><TD ALIGN='RIGHT'> "$GTSCF "</TD></TR>" ;
fi
if [[ "$GWLIB" != 0 || "$GWSCF" != 0 ]]; then
	echo "<TR BGCOLOR='#FFFFFF'><TD>George Washington</TD><TD> GW </TD><TD ALIGN='RIGHT'>" $GWLIB "</TD><TD ALIGN='RIGHT'> "$GWSCF "</TD></TR>" ;
fi
if [[ "$HULIB" != 0 || "$HUSCF" != 0 ]]; then
	echo "<TR BGCOLOR='#FFFFFF'><TD>Howard</TD><TD> HU </TD><TD ALIGN='RIGHT'>" $HULIB "</TD><TD ALIGN='RIGHT'> "$HUSCF "</TD></TR>" ;
fi
if [[ "$MULIB" != 0 || "$MUSCF" != 0 ]]; then
	echo "<TR BGCOLOR='#FFFFFF'><TD>Marymount</TD><TD> MU </TD><TD ALIGN='RIGHT'>" $MULIB "</TD><TD ALIGN='RIGHT'> "$MUSCF "</TD></TR>" ;
fi
echo "<TR BGCOLOR='#FFFFFF'><TD> &nbsp; </TD><TD> &nbsp; </TD><TD ALIGN='RIGHT'> &nbsp; </TD><TD ALIGN='RIGHT'> &nbsp; </TD></TR>" ;
#
# five law libraries
#
if [[ "$ALLIB" != 0 || "$ALSCF" != 0 ]]; then
	echo "<TR BGCOLOR='#FFFFFF'><TD>AU Law</TD><TD> AL </TD><TD ALIGN='RIGHT'>" $ALLIB "</TD><TD ALIGN='RIGHT'> "$ALSCF "</TD></TR>" ;
fi
if [[ "$GTLLIB" != 0 || "$GTLSCF" != 0 ]]; then
	echo "<TR BGCOLOR='#FFFFFF'><TD>GT Law</TD><TD> GTL </TD><TD ALIGN='RIGHT'>" $GTLLIB "</TD><TD ALIGN='RIGHT'> "$GTLSCF "</TD></TR>" ;
fi
if [[ "$JBLIB" != 0 || "$JBSCF" != 0 ]]; then
	echo "<TR BGCOLOR='#FFFFFF'><TD>GW Burns Law</TD><TD> JB </TD><TD ALIGN='RIGHT'>" $JBLIB "</TD><TD ALIGN='RIGHT'> "$JBSCF "</TD></TR>" ;
fi
if [[ "$HLLIB" != 0 || "$HLSCF" != 0 ]]; then
	echo "<TR BGCOLOR='#FFFFFF'><TD>HU Law</TD><TD> HL </TD><TD ALIGN='RIGHT'>" $HLLIB "</TD><TD ALIGN='RIGHT'> "$HLSCF "</TD></TR>" ;
fi
if [[ "$LLLIB" != 0 || "$LLSCF" != 0 ]]; then
	echo "<TR BGCOLOR='#FFFFFF'><TD>CU Law</TD><TD> LL </TD><TD ALIGN='RIGHT'>" $LLLIB "</TD><TD ALIGN='RIGHT'> "$LLSCF "</TD></TR>" ;
fi
# two medical libraries
if [[ "$HILIB" != 0 || "$HISCF" != 0 ]]; then
	echo "<TR BGCOLOR='#FFFFFF'><TD>GW Himmelfarb</TD><TD> HI</TD><TD ALIGN='RIGHT'>" $HILIB "</TD><TD ALIGN='RIGHT'> "$HISCF "</TD></TR>" ;
fi
if [[ "$HSLIB" != 0 || "$HSSCF" != 0 ]]; then
	echo "<TR BGCOLOR='#FFFFFF'><TD>HU Science </TD><TD> HS </TD><TD ALIGN='RIGHT'>" $HSLIB "</TD><TD ALIGN='RIGHT'> "$HSSCF "</TD></TR>" ;
fi
# six other things entities
if [[ "$WRLIB" != 0 || "$WRSCF" != 0 ]]; then
	echo "<TR BGCOLOR='#FFFFFF'><TD>W R L C </TD><TD> WR </TD><TD ALIGN='RIGHT'>" $WRLIB "</TD><TD ALIGN='RIGHT'> "$WRSCF "</TD></TR>" ;
fi
if [[ "$TRLIB" != 0 || "$TRSCF" != 0 ]]; then
	echo "<TR BGCOLOR='#FFFFFF'><TD>Trinity</TD><TD> TR </TD><TD ALIGN='RIGHT'>" $TRLIB "</TD><TD ALIGN='RIGHT'> "$TRSCF "</TD></TR>" ;
fi
if [[ "$LILIB" != 0 || "$LISCF" != 0 ]]; then
	echo "<TR BGCOLOR='#FFFFFF'><TD>CU Lima</TD><TD> LI </TD><TD ALIGN='RIGHT'>" $LILIB "</TD><TD ALIGN='RIGHT'> "$LISCF "</TD></TR>" ;
fi
if [[ "$DALIB" != 0 || "$DASCF" != 0 ]]; then
	echo "<TR BGCOLOR='#FFFFFF'><TD>GT Dahlgren</TD><TD> DA </TD><TD ALIGN='RIGHT'>" $DALIB "</TD><TD ALIGN='RIGHT'> "$DASCF "</TD></TR>" ;
fi
if [[ "$ERLIB" != 0 || "$ERSCF" != 0 ]]; then
	echo "<TR BGCOLOR='#FFFFFF'><TD>E-Resources</TD><TD> &nbsp; </TD><TD ALIGN='RIGHT'>" $ERLIB "</TD><TD ALIGN='RIGHT'> "$ERSCF "</TD></TR>" ;
fi
if [[ "$GDLIB" != 0 || "$GDSCF" != 0 ]]; then
	echo "<TR BGCOLOR='#FFFFFF'><TD>E-GovDoc</TD><TD> &nbsp; </TD><TD ALIGN='RIGHT'>" $GDLIB "</TD><TD ALIGN='RIGHT'> "$GDSCF "</TD></TR>" ;
fi
echo "<TR BGCOLOR='#FFFFFF'><TD> &nbsp; </TD><TD> &nbsp; </TD><TD ALIGN='RIGHT'> &nbsp; </TD><TD ALIGN='RIGHT'> &nbsp; </TD></TR>" ;
#
# subtotals for debugging only 
#
#echo "<TR BGCOLOR='#FFFFFF'><TD>Total main</TD><TD> ALL </TD><TD ALIGN='RIGHT'>" $SUBTOTALMAINLIB "</TD><TD ALIGN='RIGHT'> "$SUBTOTALMAINSCF "</TD></TR>" ;
#echo "<TR BGCOLOR='#FFFFFF'><TD>Total law</TD><TD> ALL </TD><TD ALIGN='RIGHT'>" $SUBTOTALLAWLIB "</TD><TD ALIGN='RIGHT'> "$SUBTOTALLAWSCF "</TD></TR>" ;
#echo "<TR BGCOLOR='#FFFFFF'><TD>Total med</TD><TD> ALL </TD><TD ALIGN='RIGHT'>" $SUBTOTALMEDLIB "</TD><TD ALIGN='RIGHT'> "$SUBTOTALMEDSCF "</TD></TR>" ;
#echo "<TR BGCOLOR='#FFFFFF'><TD>Total oth</TD><TD> ALL </TD><TD ALIGN='RIGHT'>" $SUBTOTALOTHLIB "</TD><TD ALIGN='RIGHT'> "$SUBTOTALOTHSCF "</TD></TR>" ;
#
echo "<TR BGCOLOR='#FFFFFF'><TD>Total</TD><TD> ALL </TD><TD ALIGN='RIGHT'>" $TOTALLIB "</TD><TD ALIGN='RIGHT'> "$TOTALSCF "</TD></TR></TABLE>" ;
#
#

