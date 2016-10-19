#!/bin/bash
#
# FILENAME: bulkcruncher.sh
# FILEPATH: {docroot}/cgi-bin/utils/
# PARAMS  : $1 is the bibid, $2 is the barcode
# OUTPUT  : Revised /var/www/wrlc/report/$1-REPORT.txt
# PURPOSE : Apply an algorithm to determine the volume sort group, 
#	    count the number 'volumes' at SCF or LIB, edit original report file 
#	    by adding the counts, and sort the report by volume.
# INFO	  : See the help file (/var/www/wrlc/help.html) for information about
#	    how the algorithm converts call number and item enumeration into
#	    'volume'
#
# -----------------------------------------
# Customize the field names in the header.
# -----------------------------------------
# Use this string as the field headers. The sequence must be the same as the order of fields in queries/10searchitems.sh
# All the fields after SERIES were output as placeholder text in the sql. They values are slightly different.
# Here they are label them better for clarity if/when a user downloads the data file.
echo "LIB|BIBID|MFHDID|ITEMID|BARCODE|ITEM_PERM|ITEM_PERM_ID|ITEM_TEMP_ID|MFHD_LOC_ID|ITEM_STATUS_DESC|BSUP|ISBN|ISSN|LCCN|OCLC|MSUP|NORM_CALL|DISP_CALL|ENUM|CHRON|#MESSAGE#|TITLE|AUTHOR|EDITION|PUBLISHER|PUBPLACE|PUBDATE|SERIES|NORMAL_VOL|#TITLEWRLC|#TITLEHOME|#VOLWRLC|#VOLHOME|#REQUEST" > /tmp/$1sortreport.out;
# 
#
# remove previous working file
rm /tmp/$1-normalized.out 
#
# ---------------------------------------------
# get each enumeration field, convert the value
# ---------------------------------------------
linecount=`wc -l /var/www/wrlc/report/$1-REPORT.txt | cut -f1 -d' '`;
# skip line 1 header, start i at 2nd line
for (( i=2; i<=$linecount; i++ ))
do
	awk NR==$i /var/www/wrlc/report/$1-REPORT.txt > /tmp/$1a.out;
	thisrow=`cat /tmp/$1a.out | cut -f19 -d'|'`;
	# thisrow is now the item_enumeration of this row in the report
	if [[ "${#thisrow}" != "0" ]] ; then
		# special handling for HU tray number in enumeration!
		if [[ "${thisrow:0:4}" == "tray" ]]; then
			dotpos=`expr index "$thisrow" .`;
			fullsz=${#thisrow};
			thisrow=${thisrow:$dotpos:$fullsz};
		fi
		# replace characters IN THIS ORDER 
		stepb=`echo $thisrow | sed  's/\\./:/g'` ;
		stepc=`echo $stepb | sed 's/[A-Za-z]//g'`;
		stepd=`echo $stepc | sed 's/-/:/g'`;
		stepe=`echo $stepd | sed 's/(/:/g'`;
		stepf=`echo $stepe | sed 's/)/:/g'`;
		stepg=`echo $stepf | sed 's/\\//:/g'`;
		steph=`echo $stepg | sed 's/\[/:/g'`;
		stepi=`echo $steph | sed 's/\]/:/g'`;
		stepj=`echo $stepi | sed 's/:/NULL/g'`;
		finalresult=`echo $stepj | sed 's/NULL/ /g'`;
		n=`echo $finalresult | cut -f1 -d' '`;
		#
		if [[ "$n" == "" ]]; then n='TEXTENUM'; fi
	else
		# -----------------------------------
                # Get and parse the call number field
		# -----------------------------------
                callno=`cat /tmp/$1a.out | cut -f18 -d'|' `;
                if [[ "${#callno}" != "0" ]]; then
                    	# set a generic value
                	n='00000000';
			#
                        # test the call number for a volume statement indicated by v.
			#
                        if [[ "${callno/v.}" != "$callno" ]]; then
                        	# determine where the volume starts : this is zero-based indexed
				# and set the number, n, to the value that comes after v.
                                volindex=`expr index "$callno" v + 1 `;
                                n=`echo ${callno:$volindex}`;
                        fi;
			# two exceptions related to 'no' and NO'
                        if [[ "${callno/no.}" != "$callno" ]]; then
                                volindex=`expr index "$callno" o + 1 `;
                                n=`echo ${callno:$volindex}`;
                        fi;
                        if [[ "${callno/NO.}" != "$callno" ]]; then
                                volindex=`expr index "$callno" O + 1 `;
                                n=`echo ${callno:$volindex}`;
                        fi;
                        if [[ $callno =~ [0-9] ]];then
				# the call number field contains some numeric digit
				# leave it alone
                        	echo >> /dev/null;	
                        else
				# the call number field only contains non-numeric characters
				# e.g., "Current Periodicals" or "Microfilm"
                                n='TEXTCNUM';
                        fi
                else
                	# the call number is blank. now check if the enumeration is also
                        if [[ "${#thisrow}" > "0" ]]; then
                        	n='NONEENUM';
                        else
				# there is no call number or enumeration
                                n='NONENONE';
                        fi
			# now override NONENONE for GT or GM having barcodes
			thislib=`cat /tmp/$1a.out | cut -f1 -d'|'`;
			thisbar=`cat /tmp/$1a.out | cut -f5 -d'|'`;
			if [[ "$thislib" == "GT" ]]; then
				if [[ "$thisbar" != "" ]]; then
					n='00000000';
				fi
			fi
			if [[ "$thislib" == "GM" ]]; then
				if [[ "$thisbar" != "" ]]; then
					n='00000000';
				fi
			fi
                fi
	fi
	normvol=$n;
	# -----------------------------------------------------
	# left pad the volume
	# this left pads the value, (printf %08d $h didn't work)
	# -----------------------------------------------------
	if [[ "${#n}" == "1" ]]; then normvol='0000000'$n; fi
	if [[ "${#n}" == "2" ]]; then normvol='000000'$n; fi
	if [[ "${#n}" == "3" ]]; then normvol='00000'$n; fi
	if [[ "${#n}" == "4" ]]; then normvol='0000'$n; fi
	if [[ "${#n}" == "5" ]]; then normvol='000'$n; fi
	if [[ "${#n}" == "6" ]]; then normvol='00'$n; fi
	if [[ "${#n}" == "7" ]]; then normvol='0'$n; fi
	if [[ "${#n}" == "8" ]]; then normvol=$n; fi
	# replace content of field 29, NORMAL_VOL
	sed -i -e s/NORMAL_VOL/$normvol/g /tmp/$1a.out;
	#
	# -------------------------------
	# Warning message
	# -------------------------------
	scf=`cat /tmp/$1a.out | grep -c SCF`;
	bar=`cat /tmp/$1a.out | cut -f5 -d'|'`;
	#if [[ "$scf" == "1" ]]; then
		#if [[ "$bar" == "" ]]; then
			#if [[ "$thislib" != "GM" ]]; then
			#sed -i -e s/#MESSAGE#/'WARNING no barcode for off site location'/g /tmp/$1a.out;
			#fi
		#fi
        #fi
cat /tmp/$1a.out >> /tmp/$1-normalized.out;
done
#
# -------------------------------------
# sort the file by the normalzed volume
# -------------------------------------
#
sort -t'|' -V -k29,29 /tmp/$1-normalized.out >> /tmp/$1sortreport.out;
#
# -----------------------------------
# get and store the counters
# -----------------------------------
#
grep -v PUBPLACE /tmp/$1sortreport.out > /tmp/$1sortdata.out;
titlescf=`grep -c  IS_SCF /tmp/$1sortdata.out`;
titlelib=`grep -cv IS_SCF /tmp/$1sortdata.out`;
rm /tmp/$1counted.out 
rm /tmp/$1countedreport.out 
for (( n=1; n<=$linecount; n++ ))
do
	awk NR==$n /tmp/$1sortdata.out > /tmp/$1b.out;
	# retrieve the volume of this line
	vol=`cat /tmp/$1b.out | cut -f29 -d'|'`;
	# save all occurances of the same volume 
	#
	# New test for null volume added in 10-18 version
	if [[ "$vol" != "" ]]; then
		grep $vol /tmp/$1sortdata.out > /tmp/$1vols.out
		volscf=`grep -c IS_SCF /tmp/$1vols.out`;
		vollib=`grep -cv IS_SCF /tmp/$1vols.out`;
	#
		sed -i -e s/#TITLEWRLC/$titlescf/g /tmp/$1b.out
		sed -i -e s/#TITLEHOME/$titlelib/g /tmp/$1b.out
		sed -i -e s/#VOLWRLC/$volscf/g /tmp/$1b.out
		sed -i -e s/#VOLHOME/$vollib/g /tmp/$1b.out
		sed -i -e s/REQVAL/$2/g /tmp/$1b.out
	fi
	cat /tmp/$1b.out >> /tmp/$1counted.out
done
# start a file with field headers
grep PUBPLACE /tmp/$1sortreport.out > /tmp/$1countedreport.out;
# append the data file that now includes the counts
cat /tmp/$1counted.out >> /tmp/$1countedreport.out
# replace the original report
mv /tmp/$1countedreport.out /var/www/wrlc/report/$1-REPORT.txt
#
# end
