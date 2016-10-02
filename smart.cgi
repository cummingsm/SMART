#!/usr/bin/perl -w
#
# FILENAME: smart.cgi
# FILEPATH: {docroot}/cgi-bin
# PARAMS  : Search value, search type (BIB or BAR), outut option (Full or Brief)
# OUTPUT  : Web page, log file in {docroot}/wrlc/log/, and data file in {docroot}/wrlc/report/
# PURPOSE : Identify consortium volumes at the WRLC Shared Collection Facility.
#	    Process request for either a barcode or bibid.
#
use CGI;
$CGI::POST_MAX=1024*100; # MAX 100k POSTS
$CGI::DISABLE_UPLOADS=1; # no uploads
#
# This line sets the method that this script was accessed (GET or POST)
my $method = $ENV{'REQUEST_METHOD'};

# The following if else structure will use the appropriate 
# processing for grabbing the form data
if ($method eq "GET") { 
    $rawdata = $ENV{'QUERY_STRING'}; 
} else { 
   # if not "GET" then it will default "POST"
   read(STDIN, $rawdata, $ENV{'CONTENT_LENGTH'}); 
} 

# Split the data pairs into sections
my @value_pairs = split (/&/,$rawdata); 
my %formdata = (); 

# Cycle through each pair to grab the values of the fields
foreach $pair (@value_pairs) { 
    ($field, $value) = split (/=/,$pair); 
    $value =~ tr/+/ /; 
    $value =~ s/%([\dA-Fa-f][\dA-Fa-f])/pack ("C", hex ($1))/eg;
    $formdata{$field} = $value; 
    # store the field data in the results hash 
} 

# next line sets the MIME type for the output 
print "Content-type: text/html\n\n"; 

#
# DEBUG: cycle through the results and print each field/value 
# foreach $field (sort keys(%formdata)) { 
#   print "$field has value $formdata{$field}\n";
# }

# print "type: ".$formdata{id_type}." value: ".$formdata{searchvalue};
#
# -------------------------------------------
# BEGIN RESPONSE
# -------------------------------------------
#
print `bash responses/pageheader.sh`;
#
#
# -------------------------------------------
# VALIDATE INPUT USING A SHELL SCRIPT
# -------------------------------------------
# Expected values for id_type: BAR, BIB, OCKC, LCCN, ISBN, ISSN
# Expected format of all ids:  numeric or '0000-0000' NOT '0000 0000'
#
$ErrorMessage=`bash utils/checkinput.sh $formdata{id_type} '$formdata{searchvalue}'`;
if ( length($ErrorMessage) > 10 ) {
	# -------------------------------------------------------
	# ERROR RESPONSE - FORM VALIDATION PROBLEM
	# -------------------------------------------------------
	print `bash responses/errortable.sh '$ErrorMessage' $formdata{id_type}`;
	print `bash responses/pagefooter.sh`;
} else {
	# -----------------------------------------------------------------
	# GET THE BIB FOR THE BARCODE OR CONFIRM THE BIBID		
	# -----------------------------------------------------------------
	if ( $formdata{id_type} eq "BAR" ) {
			$BIBID=`bash queries/1getbibforbarcode.sh $formdata{searchvalue} | awk NR==4 | cut -f1 -d'|'`;
		  } elsif ( $formdata{id_type} eq "ISBN" ) {
		  	$BIBID=`bash queries/1getbibforisbn.sh $formdata{searchvalue} | awk NR==4 | cut -f1 -d'|'`;
		  } elsif ( $formdata{id_type} eq "ISSN" ) {
		  	$BIBID=`bash queries/1getbibforissn.sh $formdata{searchvalue} | awk NR==4 | cut -f1 -d'|'`;
		  } elsif ( $formdata{id_type} eq "LCCN" ) {
		  	$BIBID=`bash queries/1getbibforlccn.sh $formdata{searchvalue} | awk NR==4 | cut -f1 -d'|'`;
		  } elsif ( $formdata{id_type} eq "OCLC" ) {
		  	$BIBID=`bash queries/1getbibforoclc.sh $formdata{searchvalue} | awk NR==4 | cut -f1 -d'|'`;
		  } else {
			$BIBID=`bash queries/1confirmbib.sh $formdata{searchvalue} | awk NR==4 | cut -f1 -d'|'`;
	}
	# Remove any leading or trailing space chracters from BIBID. 
	# Assign BIBID to be used for further processing, start a log using just the BIBID. This log name
	# is used in the shell scripts that are being called from here.
	$BIBID =~ s/^\s+|\s+$//g;
	# 
	# 
	if ( $BIBID eq "" ) {
		# ---------------------------------------
		# ERROR RESPONSE - NO VOYAGER BIBID
		# ---------------------------------------
		$LOG="/var/www/wrlc/log/BIBID-".$formdata{searchvalue}.".log";
		`bash utils/logger.sh $LOG "No bibid found for the requested $formdata{id_type}"`;	
		print `bash responses/nomatchfound.sh $formdata{id_type} '$formdata{searchvalue}'`;
		print `bash responses/pagefooter.sh`;
		# 
	}
	else {
		# -----------------------------------------
		# CLEAR PREVIOUS LOG AND REPORT FILES
		# -----------------------------------------
		#
		`rm /var/www/wrlc/report/$BIBID-REPORT.txt`;
		`rm /var/www/wrlc/log/BIBID-$BIBID.log`;
		#
		#
		# ---------------------------------------
		# GET WRLC DATA
		# ---------------------------------------
		#
		`bash queries/dispatchWRLC.sh $BIBID $formdata{id_type} $formdata{searchvalue} `;
		`bash utils/filtertitles.sh $BIBID`;
		`bash utils/dedupStatus.sh $BIBID`;
		#
		# ----------------------------------------
		# GET GEO MASONS SCF ITEM DATA (if any)
		# ----------------------------------------
		#
		`bash queries/dispatchGM.sh $BIBID $formdata{id_type} $formdata{searchvalue} `;
		#
		# ---------------------------------------
		# APPLY VOLUME ALGORITHM AND GET COUNTS
		# ---------------------------------------
		#
		`bash utils/cruncher.sh $BIBID`;
		#
		# -------------------------------------
		# GENERATE THE WEB REPORT
		# -------------------------------------
		# 
		print `bash responses/bibInfoTable.sh $BIBID $formdata{searchvalue} $formdata{id_type}`;
		print `bash responses/itemInfoTable.sh $BIBID $formdata{searchvalue} $formdata{id_type} $formdata{report_type}`;
		print `bash responses/loglink.sh  $formdata{id_type} $formdata{searchvalue} $BIBID`;
		print `bash responses/datalink.sh $BIBID $formdata{id_type} $formdata{searchvalue}`;
		print `bash responses/pagefooter.sh $BIBID`;
		#
		# -------------------------------------
		# CLEANUP TEMPORARY FILES
		# -------------------------------------
		`rm /tmp/*$BIBID*`;
    	}
	# end of cgi script
}

