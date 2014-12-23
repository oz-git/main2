#!/usr/bin/perl
use JSON::XS;
use Data::Dumper;
use CGI ':standart';
#use CGI::FastTemplate;
use CGI::Carp qw(fatalsToBrowser);
use Text::Iconv;
use DBI;
use DBD::Pg;
my $converter = Text::Iconv->new("WINDOWS-1251", "UTF-8");
my $dbh=DBI->connect( "DBI:Pg:dbname=freeswitch;host=1.1.1.1;port=5432", "login", "pass", {AutoCommit=>1});
my ($vars, $keys, %data);
my $json_xs = JSON::XS->new();
my $qw=CGI->new();
#open FILE, "json.txt" or die $!;
#open OUTFILE, ">>cdr.tst.txt" or die $!;
#my @names = $qw->param;
#print OUTFILE Dumper(@names);
#$user_fio = $converter1->convert($user_fio);
my $cdr = $qw->param('POSTDATA');
#while (<FILE>) 
#	{ 
	#print "$_\n\n\n\n";
	#my $a = Dumper( $json_xs->decode($_) ); 
	#print Dumper( $json_xs->decode($_) );
	my $hs = $json_xs->decode($cdr);
		#foreach $vars ( keys %{$hs} )
		#	{
			$data{direction}=${$hs}{'channel_data'}{'direction'};
			$data{call_uuid}=${$hs}{'variables'}{'call_uuid'};
			$data{accountcode}=${$hs}{'variables'}{'accountcode'};
			$data{gw}=${$hs}{'variables'}{'sip_gateway_name'};
			$data{sip_from_display}=${$hs}{'variables'}{'sip_from_display'};
			#if(${$hs}{'variables'}{'sip_from_display'}) { $data{sip_from_display}=$converter->convert(${$hs}{'variables'}{'sip_from_display'}); }
			$data{sip_to_user}=${$hs}{'variables'}{'sip_to_user'};
			$data{endpoint_disposition}=${$hs}{'variables'}{'endpoint_disposition'};	
			$data{hangup_cause}=${$hs}{'variables'}{'hangup_cause'};
			$data{hangup_cause_q850}=${$hs}{'variables'}{'hangup_cause_q850'};
			$data{sip_contact_host}=${$hs}{'variables'}{'sip_contact_host'};
			$data{ani}=${$hs}{'callflow'}{'caller_profile'}{'ani'};
			$data{originator_caller_profiles}=${$hs}{'callflow'}{'caller_profile'}{'originator'}{'originator_caller_profiles'};
			$data{network_addr}=${$data{originator_caller_profiles}->[0]}{'network_addr'};
			$data{sip_network_ip}=${$hs}{'variables'}{'sip_network_ip'};
			$data{caller_id_name}=${$data{originator_caller_profiles}->[0]}{'caller_id_name'};
			#if($data{caller_id_name}) { $data{caller_id_name}=$converter->convert($data{caller_id_name}); }
			$data{start_stamp}=${$hs}{'variables'}{'start_stamp'};
			if( !$data{start_stamp} ) { $data{stamps}=" NULL, "; }
			else { $data{stamps}=" '$data{start_stamp}', ";}

			$data{bridge_stamp}=${$hs}{'variables'}{'bridge_stamp'};
			if( !$data{bridge_stamp} ) { $data{stamps}=$data{stamps}."NULL, "; }
			else { $data{stamps}=$data{stamps}."'$data{bridge_stamp}', ";}

			$data{answer_stamp}=${$hs}{'variables'}{'answer_stamp'};
			if( !$data{answer_stamp} ) { $data{stamps}=$data{stamps}."NULL, ";  }
			else { $data{stamps}=$data{stamps}."'$data{answer_stamp}', ";}

			$data{end_stamp}=${$hs}{'variables'}{'end_stamp'};
			if( !$data{end_stamp} ) { $data{stamps}=$data{stamps}."NULL "; }
			else { $data{stamps}=$data{stamps}."'$data{end_stamp}' ";}
			$data{billsec}=${$hs}{'variables'}{'billsec'};
			$data{flow_billsec}=${$hs}{'variables'}{'flow_billsec'};
			$data{digits_dialed}=${$hs}{'variables'}{'digits_dialed'};
			$data{sip_hangup_phrase}=${$hs}{'variables'}{'sip_hangup_phrase'};
			$data{sip_hangup_disposition}=${$hs}{'variables'}{'sip_hangup_disposition'};
			$data{switch_r_sdp}=${$hs}{'variables'}{'switch_r_sdp'};
			$data{remote_media_ip}=${$hs}{'variables'}{'remote_media_ip'};
			$data{write_codec}=${$hs}{'variables'}{'write_codec'};
			$data{sip_use_codec_name}=${$hs}{'variables'}{'sip_use_codec_name'};
			$data{read_codec}=${$hs}{'variables'}{'read_codec'};
			$data{nibble_total_billed}=${$hs}{'variables'}{'nibble_total_billed'};
			if ( !$data{nibble_total_billed} )  { $data{nibble_total_billed}="0.0" }
			$data{nibble_rate}=${$hs}{'variables'}{'nibble_rate'};
			if ( !$data{nibble_rate} )  { $data{nibble_rate}="0.0"; }
			$data{rdnis}=${$hs}{'callflow'}{'caller_profile'}{'rdnis'};
			if ( !$data{rdnis} )  { $data{rdnis}="0"; }
$data{enc}="SET CLIENT_ENCODING TO 'UTF8'\;";
$dbh->do($data{enc});

$data{query}="INSERT INTO cdr (call_uuid, direction, accountcode, gw, sip_from_display, sip_to_user, endpoint_disposition, hangup_cause, hangup_cause_q850, sip_contact_host, ani, network_addr, sip_network_ip, caller_id_name, start_stamp, bridge_stamp, answer_stamp, end_stamp, billsec, flow_billsec, digits_dialed, sip_hangup_phrase, sip_hangup_disposition, remote_media_ip, sdp, write_codec, read_codec, sip_use_codec_name, bill_amount, nibble_rate, rdnis ) VALUES ('$data{call_uuid}', '$data{direction}', '$data{accountcode}', '$data{gw}', '$data{sip_from_display}', '$data{sip_to_user}', '$data{endpoint_disposition}', '$data{hangup_cause}', '$data{hangup_cause_q850}', '$data{sip_contact_host}', '$data{ani}', '$data{network_addr}', '$data{sip_network_ip}', '$data{caller_id_name}',".$data{stamps}.", '$data{billsec}', '$data{flow_billsec}', '$data{digits_dialed}', '$data{sip_hangup_phrase}', '$data{sip_hangup_disposition}', '$data{remote_media_ip}', '$data{switch_r_sdp}', '$data{write_codec}', '$data{read_codec}', '$data{sip_use_codec_name}', '$data{nibble_total_billed}', '$data{nibble_rate}', '$data{rdnis}')";
#	print OUTFILE "$data{query}\n\n";
$dbh->do($data{query});
$dbh -> disconnect;
print "\n\n";

#	print OUTFILE "BEGIN CDR\ncall_uuid $data{call_uuid}\ndirection $data{direction}\naccountcode $data{accountcode}\ngw $data{gw}\nsip_from_display $data{sip_from_display}\nsip_to_user $data{sip_to_user}\nendpoint_disposition $data{endpoint_disposition}\nhangup_cause $data{hangup_cause}\nhangup_cause_q850 $data{hangup_cause_q850}\nsip_contact_host $data{sip_contact_host}\nani $data{ani}\nnetwork_addr $data{network_addr}\nsip_network_ip $data{sip_network_ip}\ncaller_id_name $data{caller_id_name}\nstart_stamp $data{start_stamp}\nbridge_stamp $data{bridge_stamp}\nanswer_stamp $data{answer_stamp}\nend_stamp $data{end_stamp}\nbillsec $data{billsec}\nflow_billsec $data{flow_billsec}\ndigits_dialed $data{digits_dialed}\nsip_hangup_phrase $data{sip_hangup_phrase}\nsip_hangup_disposition $data{sip_hangup_disposition}\nremote_media_ip $data{remote_media_ip}\n*******R SDP*******\n$data{switch_r_sdp}\n********\nwrite_codec $data{write_codec}\nread_codec $data{read_codec}\nsip_use_codec_name $data{sip_use_codec_name}\nEND CDR\n\n\n";
	#print Dumper($data{network_addr});
	#print ${$data{network_addr}}{'network_addr'};
#print Dumper( $json_xs->decode($json_data) );

