#!/usr/bin/perl -w
# FILE: wrlcinventory.cgi
# DATE: Aug 11 2016 
# AUTH: CUMMINGS GW Library
# DESC: Accept request, route to validate input, then pass off to processing
# REQ: 
# TODO: chron to clear old log files from /tmp and /var/www/wrlc/ 
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
# create a job number using epoch time format. e.g, 1472590559
$timestart=`date`;
$jobnumber=`date -d "$timestart" +%s`;
#
$jobfile='/var/www/wrlc/upload/'.$formdata{bulkfile};
#print ' jobfile  :'.$jobfile.' jobnumber:'.$jobnumber;
#
# -------------------------------------------
# BEGIN RESPONSE
# -------------------------------------------
#
print `bash responses/pageheader.sh`;
print "<TR><TD>".$jobnumber."</TD></TR>";
#

# -------------------------------------------
# VALIDATE INPUT LIST USING A SHELL SCRIPT
# -------------------------------------------
# Expected values bulkfile: name of file to process
#
#$ErrorMessage=`bash utils/checkinput.sh $formdata{id_type} '$formdata{searchvalue}'`;
#if ( length($ErrorMessage) > 10 ) {
	# -------------------------------------------------------
	# Before Processing Input / Request Errors were detected 
	# in the uploaded file. Terminate the response.
	# -------------------------------------------------------
#	print `bash responses/errorpage.sh '$ErrorMessage' $formdata{id_type}`;
#} else {
	# -----------------------------------------------------------------
	# 		Perform Voyager SQL queries for each record
	# -----------------------------------------------------------------
    	#}
	# end of cgi script
#}
print "</TABLE></BODY></HTML>";
