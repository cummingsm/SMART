# SMART

Shared Materials Audit Report Tool (SMART) is a canned web report which generates an inventory of items at the WRLC Shared Collections
Facility. The report facilitates grouping and counting by volume. The application prompts the user for either a bibid or barcode. 
The response is a web page, and a pipe-delimited data file which the user may download for use with Excel, Access, etc.

The report will query WRLC Voyager, and screen scrape George Mason's Voyager if necessary. An algorithm is applied to 
the call number and item enumeration which generates a 'Volume' designation. That volume designation is then used to group and sort
the results by volume. This report includes suppressed and unsuppressed bib and holding records.

The application is hosted on the gwreports server. Extensive details are provided in the Help page at 
http://gwreports.wrlc.org/wrlc/help.html


# Configuration
Files in the repository under the directory 'htmlpages' should be placed in the apache document root/wrlc directory. 
The files with the .cgi suffix go in the cgi-bin directory, and the rest go in their respective directories under cgi-bin 
-- for example cgi-bin/queries/

The SQL queries must be edited. Replace <PASSWORD> and <HOST> with the appropriate values.

