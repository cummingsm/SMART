#!/usr/bin/perl -wT

use strict;
use CGI;
use CGI::Carp qw ( fatalsToBrowser );
use File::Basename;

#$CGI::POST_MAX = 1024 * 5000;
$CGI::POST_MAX = 1024 * 2;
my $safe_filename_characters = "a-zA-Z0-9_.-";
my $upload_dir = "/var/www/wrlc/upload";

my $query = new CGI;
my $filename = $query->param("somerecords");

if ( !$filename )
{
print $query->header ( );
print "The file was NOT uploaded. The file may be too large or the filename is unacceptable.";
print "The maximum file size is 2K, and file names may only include letters, numbers, ";
print "a dash, and a period.";
exit;
}

my ( $name, $path, $extension ) = fileparse ( $filename, '..*' );
$filename = $name . $extension;
$filename =~ tr/ /_/;
$filename =~ s/[^$safe_filename_characters]//g;

if ( $filename =~ /^([$safe_filename_characters]+)$/ )
{
$filename = $1;
}
else
{
die "Filename contains invalid characters";
}

my $upload_filehandle = $query->upload("somerecords");

open ( UPLOADFILE, ">$upload_dir/$filename" ) or die "$!";
binmode UPLOADFILE;

while ( <$upload_filehandle> )
{
print UPLOADFILE;
}

close UPLOADFILE;


my $info=$filename;

print $query->header ( );
print <<END_HTML;

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "DTD/xhtml1-strict.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>GWU Voyager inventory service</title>
</head>
<body>
<form action="http://gwreports.wrlc.org/cgi-bin/bulksteptwo.cgi" method="post">
<table bgcolor="#FFFFFF" cellpadding="4" cellspacing="1" border="0">
<tr><td>
<a href='../wrlc/starthere.html'>Check an item</a> | Bulk Process | <a href='../wrlc/about.html'>About</a>  | <a href='../wrlc/help.html'>Help</a> </td></tr>
<tr><td>
<p>Upload a list of barcodes for processing. 
<p><strong>Step 2</strong></p>
<input type='hidden' name='bulkfile' value='$info'>
</td></tr>
<tr><td>
    <table border='0'>
    <tr>
         <td> <img src='assets/ok.jpg' height='50'/></td>
         <td> The file <strong> $info </strong> has been successfully uploaded!<br>
              Click the SUBMIT button below to continue processing... </td>
    </tr>
    </table>
</td></tr>
<tr bgcolor="CORNSILK"><td >
<input type="submit" value="SUBMIT">
</td></tr>
</table>
</form>
</body>
</html> 

END_HTML
