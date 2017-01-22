#!/bin/bash
# FILENAME: gmRetriever.sh
# FILEPATH: {docroot}/cgi-bin/queries/mason/
# PARAMS  : bibid 
# OUTPUT  : Appends either the original GM lines from the Voyager query
#           or the set of GM items at the SCF found by scraping the GM catalog.
# PURPOSE : collect GM items at SCF

#
# 
# $1 = WRLC Bibid used for reporting.	
# $2 = WRLC Bibid for the GM record in WRLC Voyager 
# $3 = WRLC Mfhd 
# $4 = title
# 
LOG=/var/www/wrlc/log/BIBID-$1.log
echo 'starting gmRetriever.sh' >> $LOG
# ------------------------------------
# Parameters sent from gmChecker.sh
# ------------------------------------
vBib=$1;
gBib=$2;
vMfhd=$3;
vTitle=`echo $@ | cut -f4-20 -d" " | sed "s/'//g"`;
# vBib is the Voyager BIBID that is being used for the report.
# gBib is the same as vBIB for the FIRST time this script is called.
# 
# If there was more than one GM bib in the original results,
# then gBib is different in subsequent calls to this script.
#
# gBib is only used when passing an id to the query, qry_getGMBIB.sh
#
# All other writing will refer back to the Voyager BIBID used for
# the report, VBib
#
# ===========================
# functions 
# ===========================
function writeVolume()
{
# -------------------------------------------------
# $1 is the volume detail sent to this function
# -------------------------------------------------
#
echo 'writeVolume() here is the global title' $vTitle >> $LOG
echo 'writeVolume() saving a GM volume ' >> $LOG
echo 'vBib and vMfhd are' $vBib  $vMfhd  >> $LOG
volumefile=/tmp/$vBib'-'$vMfhd'VZ.out'
echo 'GM|'$gBib'|'$vMfhd'||||||GMBIB '$gmbib'_IS_SCF||||||||||'$1'||#MESSAGE#|'$vTitle'|||||||NORMAL_VOL|#TITLEWRLC|#TITLEHOME|#VOLWRLC|#VOLHOME' >> $volumefile
}
#
function writeNotes()
{
# -------------------------------------------------
# $1 is a note found on GM catalog
# -------------------------------------------------
echo 'vBib and vMfhd are' $vBib  $vMfhd >> $LOG
notesfile=/tmp/$vBib'-'$vMfhd'VZ.out'
echo 'GM|'$gBib'|'$vMfhd'||||ITEM_PERM_LOC#|ITEM_TEMP_LOC#|GMBIB '$gmbib'_IS_SCF||||||||||||SEE NOTE IN GM CATALOG Pwebrecon.cgi?BBID='$gmbib'|'$vTitle'|||||||NORMAL_VOL|#TITLEWRLC|#TITLEHOME|#VOLWRLC|#VOLHOME' >> $notesfile
}
#
#
function writeOriginal()
{
#
# ------------------------------------------------
# If no volumes or notes, save original line
# ------------------------------------------------
echo 'writeOriginal() here is the global title ' $vTitle >> $LOG
destfile=/tmp/$vBib'-'$vMfhd'VZ.out'
echo 'vBib is '$vBib >> $LOG
echo 'vMfhd is '$bMfhd >> $LOG
grep $vMfhd /var/www/wrlc/report/$vBib-REPORT.txt >> $destfile
}
#
#
# ============================================
# PROCESSING STARTS HERE
# ============================================
SCF_FLAG="";
echo "Processing WRLC BIB $2 MFHD $3 " >> $LOG
echo "TITLE: "$vTitle >> $LOG
#
#
# -------------------------------------------
# Query Voyager to get the George Mason BIBID
# then strip trailing spaces
# -------------------------------------------
echo 'calling getGMBib.sh ' >> $LOG
bash /var/www/cgi-bin/queries/mason/getGMBib.sh $2;
newbib=`grep '|' /tmp/$2gmbib.out | cut -f2 -d'|'`;
gmbib=`echo $newbib | sed "s/ //g"`
rm /tmp/$2gmbib.out
#
#
# ------------------------------------------- 
# Screen scrape George Mason for SCF volumes
# -------------------------------------------
if [[ "$gmbib" != "" ]]; then
        echo "Found George Mason Bibid "$gmbib >> $LOG;
        VOLUMES=`curl -s http://magik.gmu.edu/cgi-bin/Pwebrecon.cgi?BBID=$gmbib | grep 'Charged - Due on Indefinite'` > /dev/null
        #
        if [[ "$VOLUMES" != "" ]]; then
                # delete previous file
		echo 'found VOLUMES' >> $LOG;
		SCF_FLAG="YES";
                #
                # remove the HTML markup:   "/",  "TD>" and "TR>"
                # keeping "<" as a field separator for the next step
                #
                noFS=`echo $VOLUMES | sed 's/\///g'`;
                noBR=`echo $noFS | sed 's/BR>//g'`;
                noTD=`echo $noBR | sed 's/TD>//g'`;
                noTX=`echo $noTD | sed 's/Charged - Due on Indefinite//g'`;
		# two &lt; symbols is a problem. Change em to n.a.<
                noBB=`echo $noTX | sed 's/<</n.a.</g'`;
                VFIX=`echo $noBB | sed 's/TR>//g'`;
                #
                # declare the string as an array and then iterate through it
                # courtesy stackoverflow.com
                #
                set -- "$VFIX";
                IFS="<"; declare -a VINFO=($*);
                VINFOlength=${#VINFO[@]};
                for (( i=1; i<${VINFOlength}+1; i++ ));
                do
                        if [[ "${VINFO[$i-1]}" != "" ]]; then
                                # pass this to a function that writes the line
                                writeVolume ${VINFO[$i-1]};
                        fi
		done
        else
                echo "No volumes found with charged due indefinite" >> $LOG;
        fi
        # --------------------------------------------------
        # Search for messages ( when there are no volumes )
        # --------------------------------------------------
	if [[ ${VINFOlength} < 1 ]]; then
        	messg=`curl -s http://magik.gmu.edu/cgi-bin/Pwebrecon.cgi?BBID=$gmbib | grep 'WRLC Center'`;
        	if [[ "$messg" != "" ]]; then
			SCF_FLAG="YES";
                	stepa=`echo $messg | sed 's/>//g'`;
                	stepb=`echo $stepa | sed 's/<//g'`;
                	stepc=`echo $stepb | sed 's/TD//g'`;
                	stepd=`echo $stepc | sed 's/\\///g'`;
                	finalmsg=`echo $stepd | sed 's/TR//g'`;
                	# pass this message string to a function that writes the line
			echo 'Found WRLC Center note / message'; >> $LOG
                	writeNotes "$finalmsg";
        	else
                	echo "No messages found" >> $LOG;
	        fi
	fi
	if [[ "$SCF_FLAG" != "YES" ]]; then
		echo "SCF_FLAG does not say YES. No SCF Holding found" >> $LOG
		writeOriginal;
	fi
	#
else
	echo "no GMbib found for the WRLCbib" >> $LOG
	writeOriginal;
fi
#
# test cases
# WRLC bibid 2016212 = GM bibid 544871 several volumes at SCF
#   GM page lists multiple locations. 
#   The first is 'Fenwick Periodicals - Print Collection' and
#   the note says '(1970-1978) held at WRLC Center;avail. deliv., (lib. use only)' and
#   the library has summary says 'v.190-v.207 (1970-1978)'
#   Then there is location for every volume, followed by a status line for every volume
#   which has the phrase 'Charged - Due on Indefinite'   
# WRLC bibid 1915792 = GM bibid 442965 monograph at SCF but there is no volume data
#   GM page says status is 'Charged - Due on Indefinite'
#   GM location is 'Temporarily Shelved at WRLC Shared Collections Facility'
#   GM page has no message.
