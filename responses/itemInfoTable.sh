#!/bin/bash
#
# FILENAME: itemInfoTable.sh
# FILEPATH: {docroot}/cgi-bin/responses/
# PARAMS  : bibid, search value, id type, report type
# OUTPUT  : HTML table containing all the item details
# PURPOSE : Displays the data in a web page. The data is in /var/www/report/$1-REPORT.txt
#
#
#  $1 = bibid
#  $2 = searchvalue
#  $3 = search type BIB or BAR
#  $4 = report type FULL or BRIEF
#
LOG=/var/www/wrlc/log/BIBID-$1.log
echo "TIMER|"`date +%T`"|itemInfoTable" >> $LOG
# use the bib info from the bib that was requested
TOTALSCF=`grep -c IS_SCF /var/www/wrlc/report/$1-REPORT.txt`;
#
if [[ "$TOTALSCF" == "0" ]]; then
	echo "<BR>No items found at WRLC Shared Collection Facility (SCF)</FONT><BR>";
fi
	echo "<BR>";
	echo "<TABLE CELLPADDING='1' BGCOLOR='#CCCCCC' CELLSPACING='1' BORDER='0' WIDTH='90%'>";
	echo "<TR BGCOLOR='#82E0AA'><TD COLSPAN='12'> Detailed Counts by Item </TD></TR>";
	echo "<TR BGCOLOR='#FFFFFF'>";
	echo "<TD> INST </TD>";
	echo "<TD> WHERE</TD>";
	echo "<TD> CALLNO </TD>";
	echo "<TD> ENUM / VOL </TD>";
	echo "<TD> CHRON </TD>";
	echo "<TD> BARCODE </TD>";
	echo "<TD> STATUS</TD>";
	# item counters
	echo "<TD ALIGN='RIGHT'> VLIB </TD>";
	echo "<TD ALIGN='RIGHT'> VSCF </TD>";
	# title counters
	echo "<TD ALIGN='RIGHT'> TLIB </TD>";
	echo "<TD ALIGN='RIGHT'> TSCF </TD>";
	echo "</TR>";
	# -----------------------------------------------------------
	#
	# The fields are in the order they are output by the query
	# that gets item details, 10searchitems.sh
	#
	#
	groupHeader="";
	previousBarcode="";
	max=`wc -l /var/www/wrlc/report/$1-REPORT.txt | cut -f1 -d' '`;
	for (( i=2; i<=$max; i++ ))
	do
	awk NR==$i /var/www/wrlc/report/$1-REPORT.txt > /tmp/$1-itemdetail;
	#
	# As previously noted, the fields are in order according to query output 10searchitems.sh
	#
	ilibrary=`cat /tmp/$1-itemdetail | cut -f1  -d'|'`;
	ibib=`cat /tmp/$1-itemdetail     | cut -f2  -d'|'`;
	holdid=`cat /tmp/$1-itemdetail   | cut -f3  -d'|'`;
	itemid=`cat /tmp/$1-itemdetail   | cut -f4  -d'|'`;
	ibarcode=`cat /tmp/$1-itemdetail | cut -f5  -d'|'`;
	ilocid=`cat /tmp/$1-itemdetail   | cut -f6  -d'|'`;
	iperm=`cat /tmp/$1-itemdetail    | cut -f7  -d'|'`;
	itemp=`cat /tmp/$1-itemdetail    | cut -f8  -d'|'`;
	hloc=`cat /tmp/$1-itemdetail     | cut -f9  -d'|'`;
	istatus=`cat /tmp/$1-itemdetail  | cut -f10 -d'|'`;
	# 11-15 are bib sutff we dont neet
	bibsupp=`cat /tmp/$1-itemdetail  | cut -f11 -d'|'`;
	hsuppress=`cat /tmp/$1-itemdetail| cut -f16 -d'|'`;
	#idspcall=`cat /tmp/$1-itemdetail| cut -f17 -d'|'`;
	icall=`cat /tmp/$1-itemdetail    | cut -f18 -d'|'`;
	ienum=`cat /tmp/$1-itemdetail    | cut -f19 -d'|'`;
	ichron=`cat /tmp/$1-itemdetail   | cut -f20 -d'|'`;
	imessage=`cat /tmp/$1-itemdetail | cut -f21 -d'|'`;
	ititle=`cat /tmp/$1-itemdetail   | cut -f22 -d'|'`; 
	# 23-28 bib more bibinfo
	sortgroup=`cat /tmp/$1-itemdetail| cut -f29 -d'|'`;
	#
	ntitlescf=`cat /tmp/$1-itemdetail| cut -f30 -d'|'`;
	ntitlelib=`cat /tmp/$1-itemdetail| cut -f31 -d'|'`;
	nvolscf=`cat /tmp/$1-itemdetail| cut -f32 -d'|'`;
	nvollib=`cat /tmp/$1-itemdetail| cut -f33 -d'|'`;
	# 
	SCFfound=`grep 'IS_SCF' /tmp/$1-itemdetail`;
	#
	# conditional print settings
	if [[ "$istatus" == "Lost--System Applied" ]] || [[ "$istatus" == "Lost--Library Applied" ]]; then
		mystatus="<TD COLSPAN='5' BGCOLOR='RED'><FONT COLOR='#FFFFFF'>"$istatus" &nbsp; </FONT></TD>"; 
	elif [[ "$istatus" == "Damaged" ]]; then
		mystatus="<TD COLSPAN='5' BGCOLOR='RED'><FONT COLOR='#FFFFFF'>"$istatus" &nbsp; </FONT></TD>"; 
	elif [[ "$istatus" == "Missing" ]]; then
		mystatus="<TD COLSPAN='5' BGCOLOR='RED'><FONT COLOR='#FFFFFF'>"$istatus" &nbsp; </FONT></TD>"; 
	elif [[ "$istatus" == "Withdrawn" ]]; then
		mystatus="<TD COLSPAN='5' BGCOLOR='RED'><FONT COLOR='#FFFFFF'>"$istatus" &nbsp; </FONT></TD>"; 
	else
		mystatus="<TD COLSPAN='5'>"$istatus" &nbsp; </TD>"; 
	fi
	trimLibrary=`echo $ilibrary | sed "s/(standard input)://"`; 
	if [[ "$SCFfound" != "" ]]; 	then thisLOC="SCF"; 
					else thisLOC="LIB"; fi
	if [[ "$hloc" == "" ]]; 	then trimHhold='na'; 
					else trimHold=`echo $hloc | sed "s/HOLD_LOC_IS_//"`; fi
	if [[ "$itemid" == "" ]]; 	then trimItemid='na'; 
					else trimItemid=$itemid; fi
	summaryBG="#F1F1F1"; 
	if [[ "$nvolscf" != "0" ]]; 	then summaryBG="#82E0AA"; fi
	if [[ "$nvolscf" > "2" ]]; 	then summaryBG="#F9AF9F"; fi
        # example of nvolscf > 2 is item 2262427					

	# -----------------------------------------
	# sortgroup header row - 11 columns
	# -----------------------------------------
	if [[ "$groupHeader" != "$sortgroup" ]]; then
		# print the group header
		echo "<TR BGCOLOR='#F1F1F1'><TD COLSPAN='7' ALIGN='RIGHT'>";		
	 	echo "Volume:  '"$sortgroup"' &nbsp; </TD>";
		echo "<TD ALIGN='RIGHT'>"$nvollib"</TD>";
		echo "<TD ALIGN='RIGHT' BGCOLOR='"$summaryBG"'>"$nvolscf"</TD>";
		echo "<TD ALIGN='RIGHT'>"$ntitlelib" </TD>";
		echo "<TD ALIGN='RIGHT' >"$ntitlescf" </TD>";
		echo "</TR>";
		# update the flag
		groupHeader=$sortgroup;
	fi
	# -----------------------------------------
	# first row per item - 11 columns
	# -----------------------------------------
	echo "<TR BGCOLOR='#E5FEEE'>";
	echo "<TD>" $trimLibrary "</TD>";
	if [[ "$thisLOC" == "SCF" ]]; then 
		echo "<TD BGCOLOR='#82E0AA'>" $thisLOC "</TD>";
		else
		echo "<TD>" $thisLOC "</TD>";
	fi
	echo "<TD>" $icall " &nbsp; </TD>";
	if [[ "$imessage" != "#MESSAGE#" ]]; then
		echo "<TD><FONT COLOR='RED'>" $imessage "</FONT></TD>";
	else	
		echo "<TD>" $ienum " &nbsp; </TD>";
	fi
	echo "<TD>" $ichron " &nbsp; </TD>";
	echo "<TD>"$ibarcode" &nbsp; </TD>";
	echo $mystatus;
	echo "</TR>";
	#
	#
	# depending on report_type ($3 = FULL
	#
	if [[ "$4" == "FULL" ]]; then
	# ---------------------------------------
	# second row - 11 columns
	# --------------------------------------- 
	#						
	echo "<TR BGCOLOR='#FFFFFF'>";
	echo "<TD> &nbsp; </TD>";
	echo "<TD> &nbsp; </TD>";
	echo "<TD ALIGN='RIGHT'><FONT COLOR='#CCCCCC'>ITEM:"$itemid"</FONT></TD>";
	echo "<td><FONT COLOR='#CCCCCC'>Sort group: "$sortgroup"</FONT></TD>";
	if [ "$iperm" == "ITEM_PERM_LOC#" ]; then 
		echo "<TD colspan='3'><FONT COLOR='#CCCCCC'> Perm: na </FONT></TD>";
          else
	 	trimPerm=`echo $iperm | sed "s/ITEM_PERM_LOC_IS_//"`;
		echo "<TD colspan='3'><FONT COLOR='#CCCCCC'>Perm:"$trimPerm" ("$ilocid")</FONT></TD>";
	fi
	if [ "$itemp" == "ITEM_TEMP_LOC#"  ]; then 
		echo "<TD colspan='4'><FONT COLOR='#CCCCCC'> Temp:na </FONT></TD></TR>";
          else
		if [ "$itemp" == "ITEM_TEMP_LOC#0"  ]; then 
			echo "<TD colspan='4'><FONT COLOR='#CCCCCC'> Temp:na </FONT></TD></TR>";
		else	
	 		trimTemp=`echo $itemp | sed "s/ITEM_TEMP_LOC_IS_//"`;
			echo "<TD colspan='4'><FONT COLOR='#CCCCCC'>Temp:"$trimTemp"</FONT></TD></TR>";
		fi
	fi
	# -----------------------------
	# third row - 11 columns
	# -----------------------------
	echo "<TR BGCOLOR='#FFFFFF'>";	
	echo "<TD> &nbsp; </TD>";
	echo "<TD> &nbsp; </TD>";
	echo "<TD ALIGN='RIGHT'><FONT COLOR='#CCCCCC'>MFHD:" $holdid  "</FONT></TD>";
	echo "<TD ><FONT COLOR='#CCCCCC'>MFHD SUPPRESS:"$hsuppress"</FONT></TD>";
	echo "<TD COLSPAN='3' ><FONT COLOR='#CCCCCC'>"$trimHold"</FONT></TD>";
	echo "<TD COLSPAN='4' ALIGN='RIGHT' ><FONT COLOR='#CCCCCC'>";
	if [[ "$bibsupp" == "Y" ]]; then
		echo "<FONT COLOR='RED'>BIB SUPP:"$bibsupp" &nbsp; | &nbsp; ID: " $ibib  "</FONT></TD>";
	else
		echo "BIB SUPP:"$bibsupp" &nbsp; | &nbsp; ID: " $ibib  "</FONT></TD>";
	fi
	echo "</TR>";
	#						
	# -----------------------------
	# fourth row - 11 columns
	# -----------------------------
	if [[ "$imessage" != "#MESSAGE#" ]]; then
		echo "<TR BGCOLOR='#FFFFFF'>";	
		echo "<TD> &nbsp; </TD>";
		echo "<TD> &nbsp; </TD>";
		echo "<TD ALIGN='RIGHT'><FONT COLOR='#CCCCCC'>Message:</FONT></TD>";
		echo "<TD COLSPAN='8'><FONT COLOR='RED'><I>"$imessage"</I></FONT></TD>";
		echo "</TR>";
	fi
	# end of optional rows
	fi
	# end of do loop for each item line
	done
	echo "</TABLE><BR>" ;
#

