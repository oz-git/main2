#!/usr/bin/perl
use strict;
use POSIX qw(strftime);
use DBI;
use DBD::Pg;
use DateTime;
our ($session, %data);
my $dbh=DBI->connect( "DBI:Pg:dbname=freeswitch;host=your_host;port=5432", "your_login", "your_pass", {AutoCommit=>1} );

$dbh->do("delete from abc_route_not_found where id not in (select min(id) from abc_route_not_found group by def,num )");

$data{sql}="select def,num from abc_route_not_found";

$data{sth}=$dbh->prepare($data{sql});
$data{sth}->execute();
while ( ($data{def}, $data{num})=$data{sth}->fetchrow_array() )
	{
	#print "$data{def}   $data{num}\n";
	$data{sql_r}="select def,start_num,end_num,quantity,provider_nm,region_nm from abc_provider_new
		     	where 
			def=\'".$data{def}."\'
			and start_num <=\'".$data{num}."\' and end_num >=\'".$data{num}."\'
			";
	#print "$data{sql_r}\n";
	$data{sth_r}=$dbh->prepare($data{sql_r});
	$data{sth_r}->execute();
	$data{rows}=$data{sth_r}->rows;
	#print "rows $data{rows}\n";
	if ( $data{rows} > 0 )
		{
		( $data{def_r}, $data{start_num}, $data{end_num}, $data{quantity}, $data{provider_nm}, $data{region_nm} )=$data{sth_r}->fetchrow_array();
		$data{region_nm} =~ s/^\t//g;
		$data{sql_check_duble}="select def,start_num,end_num,quantity,provider_nm,region_nm from abc_provider
                   			where def=\'".$data{def}."\' and start_num <=\'".$data{num}."\' and end_num >=\'".$data{num}."\'";
                $data{sth_check_duble}=$dbh->prepare($data{sql_check_duble});
                $data{sth_check_duble}->execute();
                $data{rows_check_duble}=$data{sth_check_duble}->rows;
                if ( $data{rows_check_duble} > 0 )
			{
                        print "ALREADY IN TABLE NUMBER $data{def}-$data{num} $data{start_num}, $data{end_num} $data{provider_nm}, $data{region_nm}, $data{tariff_zone}\n";
                        $dbh->do("delete from abc_route_not_found where def='$data{def}' and num='$data{num}'");
			}
                else
                        {
			#$data{sql_tz}="select * from abc_provider where region_nm = \'$data{region_nm}\' limit 1";
			$data{sql_tz}="select tariff_zone from abc_tariff_zones where region_nm like  \'\%data{region_nm}\' limit 1";
			$data{sth_tz}=$dbh->prepare($data{sql_tz});
			$data{sth_tz}->execute();
			$data{tariff_zone}=$data{sth_tz}->fetchrow_array();
			if ( !$data{tariff_zone} )  { $data{tariff_zone}='999'; }
			if ( $data{region_nm} eq "Москва" ) { $data{tariff_zone}='0'; }
			print "ADDED NUMBER $data{def}-$data{num} IN $data{def_r}, $data{start_num}, $data{end_num}, $data{quantity}, $data{provider_nm}, $data{region_nm}, $data{tariff_zone}\n";
			$dbh->do("insert into abc_provider (def,start_num,end_num,quantity,provider_nm,region_nm,tariff_zone) values (\'$data{def_r}\',\'$data{start_num}\',\'$data{end_num}\',\'$data{quantity}\',\'$data{provider_nm}\',\'$data{region_nm}\',\'$data{tariff_zone}\')");
			$dbh->do("delete from abc_route_not_found where def='$data{def}' and num='$data{num}'");
			}
		}
	else 
		{
		print "NUMBER $data{def}-$data{num} not found\n";
		$dbh->do("delete from abc_route_not_found where def='$data{def}' and num='$data{num}'");
		}
	}
if($data{sth_tz}) { $data{sth_tz}->finish(); }
if($data{sth_r}) { $data{sth_r}->finish(); }
if($data{sth}) { $data{sth}->finish(); }
if($data{sth_check_duble}) { $data{sth_check_duble}->finish(); }
$dbh->disconnect();
print "Update 348kh done...\n";
