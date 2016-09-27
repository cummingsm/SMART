#!/bin/bash
# FILENAME: reformatitemsql.sh
# FILEPATH: {docroot}/cgi-bin/utils/
# PARAMS  : bibid
# OUTPUT  : edited version of /var/www/wrlc/report/$1-REPORT.txt
# PURPOSE : Remove spaces before and after pipe delimiter
#	    Use list in this script to search and replace values in
#	    the original report file. This process identifies the
#	    WRLC Shared Collection Facility (SCF) locations.
#
#
LOG=/var/www/wrlc/log/BIBID-$1.log
#
# Keep only the lines with pipes, except the line under the header
# which is just a bunch of dashes
cat /tmp/$1-ITEMS.out | grep '|' | grep -v "|-----"  > /tmp/$1-ITEMSCLEAN.out
#
# get rid of multiple contiguous space characters 
sed -i -e 's/  //g' /tmp/$1-ITEMSCLEAN.out
# get rid of spaces preceding or following pipes
sed -i -e 's/| /|/g' /tmp/$1-ITEMSCLEAN.out
sed -i -e 's/ |/|/g' /tmp/$1-ITEMSCLEAN.out
# 
# All the voyager location ids that have WRLC Shared Collections Facility
# in the locaton display name are below. 
# 
# Here we translate the wrlc location ids in strings containing "IS_SCF"
# This will nicely facilitate reporting because we can match the pattern.
#
sed -i -e 's/#681/_IS_SCF(681) wrlc stnc/g' /tmp/$1-ITEMSCLEAN.out
sed -i -e 's/#682/_IS_SCF(682) wrlc stor/g' /tmp/$1-ITEMSCLEAN.out
sed -i -e 's/#683/_IS_SCF(683) wrlc stru/g' /tmp/$1-ITEMSCLEAN.out
sed -i -e 's/#810/_IS_SCF(810) wrlc himm/g' /tmp/$1-ITEMSCLEAN.out
sed -i -e 's/#840/_IS_SCF(840) wrlc alper/g' /tmp/$1-ITEMSCLEAN.out
sed -i -e 's/#841/_IS_SCF(841) wrlc almon/g' /tmp/$1-ITEMSCLEAN.out
sed -i -e 's/#894/_IS_SCF(894) wrlc hida/g' /tmp/$1-ITEMSCLEAN.out
sed -i -e 's/#1009/_IS_SCF(1009) wrlc shrp/g' /tmp/$1-ITEMSCLEAN.out
sed -i -e 's/#1012/_IS_SCF(1012) wrlc disp/g' /tmp/$1-ITEMSCLEAN.out
sed -i -e 's/#1024/_IS_SCF(1024) gt per/g' /tmp/$1-ITEMSCLEAN.out
sed -i -e 's/#1025/_IS_SCF(1025) gt mono/g' /tmp/$1-ITEMSCLEAN.out
sed -i -e 's/#1036/_IS_SCF(1036) wrlc gtnc/g' /tmp/$1-ITEMSCLEAN.out
sed -i -e 's/#1047/_IS_SCF(1047) wrlc gtmo/g' /tmp/$1-ITEMSCLEAN.out
sed -i -e 's/#1052/_IS_SCF(1052) gt med/g' /tmp/$1-ITEMSCLEAN.out
sed -i -e 's/#1056/_IS_SCF(1056) gt thesis/g' /tmp/$1-ITEMSCLEAN.out
sed -i -e 's/#1211/_IS_SCF(1211) gt spec/g' /tmp/$1-ITEMSCLEAN.out
sed -i -e 's/#1212/_IS_SCF(1212) wrlc gtspe/g' /tmp/$1-ITEMSCLEAN.out
sed -i -e 's/#1228/_IS_SCF(1228) gt kib/g' /tmp/$1-ITEMSCLEAN.out
sed -i -e 's/#1476/_IS_SCF(1476) gt woodc/g' /tmp/$1-ITEMSCLEAN.out
sed -i -e 's/#1478/_IS_SCF(1478) gt wood/g' /tmp/$1-ITEMSCLEAN.out
sed -i -e 's/#1508/_IS_SCF(1508) gt medc/g' /tmp/$1-ITEMSCLEAN.out
sed -i -e 's/#1518/_IS_SCF(1518) wrlc micro/g' /tmp/$1-ITEMSCLEAN.out
sed -i -e 's/#1535/_IS_SCF(1535) wrlc gtkip/g' /tmp/$1-ITEMSCLEAN.out
sed -i -e 's/#1536/_IS_SCF(1536) gt kibp/g' /tmp/$1-ITEMSCLEAN.out
sed -i -e 's/#1552/_IS_SCF(1552) da pernc/g' /tmp/$1-ITEMSCLEAN.out
sed -i -e 's/#1553/_IS_SCF(1553) wrlc danc/g' /tmp/$1-ITEMSCLEAN.out
sed -i -e 's/#1793/_IS_SCF(1793) wrlcstnret/g' /tmp/$1-ITEMSCLEAN.out
sed -i -e 's/#1794/_IS_SCF(1794) wrlcstoret/g' /tmp/$1-ITEMSCLEAN.out
sed -i -e 's/#1795/_IS_SCF(1795) wrlcstrret/g' /tmp/$1-ITEMSCLEAN.out
sed -i -e 's/#1797/_IS_SCF(1797) gtmonoret/g' /tmp/$1-ITEMSCLEAN.out
sed -i -e 's/#1943/_IS_SCF(1943) huwrlc/g' /tmp/$1-ITEMSCLEAN.out
sed -i -e 's/#1944/_IS_SCF(1944) huwrlcret/g' /tmp/$1-ITEMSCLEAN.out
sed -i -e 's/#1945/_IS_SCF(1945) huwrlcdup/g' /tmp/$1-ITEMSCLEAN.out
sed -i -e 's/#1960/_IS_SCF(1960) huwrlcper/g' /tmp/$1-ITEMSCLEAN.out
sed -i -e 's/#1961/_IS_SCF(1961) huwrlcmicr/g' /tmp/$1-ITEMSCLEAN.out
#
#
# Append to log 
echo `wc -l /tmp/$1-ITEMSCLEAN.out` >> $LOG
echo 'finished cleaning up item results' >> $LOG
#
# Save in the report directory 
cp /tmp/$1-ITEMSCLEAN.out /var/www/wrlc/report/$1-REPORT.txt
echo 'report file is in /var/www/wrlc/report/' >> $LOG

