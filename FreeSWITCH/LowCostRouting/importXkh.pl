#!/usr/bin/perl
use strict;
use POSIX qw(strftime);
use DBI;
use DBD::Pg;
use DateTime;
our ($session, %data);
my $dbh=DBI->connect( "DBI:Pg:dbname=freeswitch;host=1.1.1.1;port=5432", "login", "pass", {AutoCommit=>1} );

print "Delete old data from table def_provider_new...\n";
$dbh->do("DELETE FROM def_provider_new");
print "Done\n";

$dbh->do(" SET CLIENT_ENCODING = 'WIN1251' ");

print "Insert into def_provider_new\n";
$data{sql}="\COPY def_provider_new (def,start_num,end_num,quantity,provider_nm,region_nm) FROM '/home/lcr/Kody_DEF-9kh.csv' DELIMITER '\;' CSV HEADER";
print "$data{sql}\n";
$dbh->do($data{sql});
print "Done\n";

print "Delete old data from table abc_provider_new...\n";
$dbh->do("DELETE FROM abc_provider_new");
print "Done\n";

print "Insert into abc_provider_new 3kh\n";
$data{sql}="\COPY abc_provider_new (def,start_num,end_num,quantity,provider_nm,region_nm) FROM '/home/lcr/Kody_ABC-3kh.csv' DELIMITER '\;' CSV HEADER";
print "$data{sql}\n";
$dbh->do($data{sql});
print "Done\n";

print "Insert into abc_provider_new 4kh\n";
$data{sql}="\COPY abc_provider_new (def,start_num,end_num,quantity,provider_nm,region_nm) FROM '/home/lcr/Kody_ABC-4kh.csv' DELIMITER '\;' CSV HEADER";
print "$data{sql}\n";
$dbh->do($data{sql});
print "Done\n";

print "Insert into abc_provider_new 8kh\n";
$data{sql}="\COPY abc_provider_new (def,start_num,end_num,quantity,provider_nm,region_nm) FROM '/home/lcr/Kody_ABC-8kh.csv' DELIMITER '\;' CSV HEADER";
print "$data{sql}\n";
$dbh->do($data{sql});
print "Done\n";

$dbh->disconnect();
