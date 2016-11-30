#!/usr/bin/perl -w
#
# FILENAME: validatebarcodes.cgi
# FILEPATH: {docroot}/cgi-bin
# PARAMS  : bulkfile name and notify email address
# OUTPUT  : Web page, job file in {docroot}/wrlc/upload/
# PURPOSE : Call shell script to perform basic validation of the user's uploaded file of barcodes.
#           Save job number, email address along with the upload file
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

#
$jobfile='/var/www/wrlc/upload/'.$formdata{bulkfile};
$jobcontact=$formdata{notifyemail};
# create a job number using epoch time format. e.g, 1472590559
$timestart=`date`;
$jobnumber=`date -d "$timestart" +%s`;
$jobnumber =~ s/ //g;
#
# -------------------------------------------
# VALIDATE INPUT LIST USING A SHELL SCRIPT
# -------------------------------------------
#
$validstatus=`bash utils/validatebarcodes.sh $jobfile`;
#
# -------------------------------------------
# RETURN WEB RESPONSE TO USER
# -------------------------------------------
if ( length($validstatus) < 10 ) {
	# header
	print `bash responses/pageheader.sh`;
	# confirmation
	print "<TR><TD><H3>Thank you</H3>";
	print "When processing is complete, an email will be sent to <strong>".$jobcontact." </strong> ";
	print "referencing request number <strong> ".$jobnumber;
	print ".</strong><BR><BR><BR>";
	print "</TD></TR></TABLE>";
	# footer
	print "<TABLE CELLPADDING='2' CELLSPACING='1' WIDTH='90%'><TR BGCOLOR='#EAEAEA'><TD ALIGN='CENTER'> ";
	print "----[ Shared Materials Audit Reporting Tool ]---- </TD><TR></TABLE>";
	print "</BODY></HTML>";
	# -----------------------------------
	# CREATE JOB FILE
	# -----------------------------------
	# start a newline
	  `echo '' >> $jobfile`;
	# write job information
	  `echo 'JOBINFO|$formdata{bulkfile}|$jobcontact|$jobnumber' >> $jobfile`;
	# get non-blank lines containing digits
	`grep [0-9] $jobfile > /var/www/wrlc/upload/$jobnumber`;
	# remove original file
	`rm $jobfile`;
	# chmod on new file
	`chmod 777 /var/www/wrlc/upload/$jobnumber`;
} else {
	`rm $jobfile`;
	print `bash responses/pageheader.sh`;
	print "<TR><TD><FONT COLOR='RED'>".$validstatus."</FONT><BR><BR>";
	print "The file has been removed. Please check your data and re-upload the file.<BR>";
	print "One type of error to look for is a blank line in the list of barcodes, <BR>";
	print "especially at the end of the file. Another problem would be barcodes that are not the correct length.<BR>";
	print "Sorry for the inconvenience.<TD></TR></TABLE></BODY></HTML>";
	print "<TABLE CELLPADDING='2' CELLSPACING='1' WIDTH='90%'><TR BGCOLOR='#EAEAEA'><TD ALIGN='CENTER'> ";
	print "----[ Shared Materials Audit Reporting Tool ]---- </TD><TR></TABLE>";
	print "</BODY></HTML>";
}
