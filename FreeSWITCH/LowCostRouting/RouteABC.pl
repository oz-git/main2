#!/usr/bin/perl
use strict;
use POSIX qw(strftime);
use DBI;
use DBD::Pg;
use DateTime;
our ($session, %data);
my $dbh=DBI->connect( "DBI:Pg:dbname=freeswitch;host=your_host;port=5432", "yuur_login", "your_pass", {AutoCommit=>1});
my $today_dt = DateTime->now(time_zone=>'Europe/Moscow');
my $today = $today_dt->day_of_week;
my $hour = $today_dt->hour;
sub fprint($)
	{
	my ($msg) = @_;
	freeswitch::consoleLog("INFO",$msg . "\n");
	}
my %VARS;
my %CLEAN_VARS;
	sub GETV #takes one or more variables names to import in
	{
		my @arr = @_;
		foreach my $var (@arr)
		{
			$VARS{$var} = $session->getVariable($var);
			$CLEAN_VARS{$var} = $VARS{$var};
			$CLEAN_VARS{$var}="" if (! defined $CLEAN_VARS{$var});
		}
	}
	sub SETV($$) #Generally not called directly, but will set the variable to the value requested right away.
	{
		my ($var,$value) = @_;
		$session->setVariable($var,$value);
		$VARS{$var} = $value;
		$CLEAN_VARS{$var} = $value;
	}
GETV(qw/destination_number caller_id_name caller_id_number/);
$data{DstDEF}=substr($VARS{destination_number},1,3);
$data{DstNum}=substr($VARS{destination_number},4,10);
$data{query}="\(select abc_costs.gw_nm,abc_costs.cost,abc_provider.provider_nm,abc_provider.region_nm,abc_provider.tariff_zone from abc_provider, abc_costs 
	where
	def=\'".$data{DstDEF}."\'
	and start_num <=\'".$data{DstNum}."\' and end_num >=\'".$data{DstNum}."\'
	and abc_provider.tariff_zone=abc_costs.tariff_zone
        and abc_provider.provider_nm=abc_costs.provider_nm
	and abc_costs.enabled='1'
	union
	select abc_costs.gw_nm,abc_costs.cost,abc_provider.provider_nm,abc_provider.region_nm,abc_provider.tariff_zone from abc_provider, abc_costs
	where
	def=\'".$data{DstDEF}."\'
        and start_num <=\'".$data{DstNum}."\' and end_num >=\'".$data{DstNum}."\'
	and abc_provider.tariff_zone=abc_costs.tariff_zone
        and abc_costs.provider_nm='Others_providers'
	and abc_costs.enabled='1'
	\)
	order by 2 ASC
	limit 1";
$data{sth}=$dbh->prepare($data{query});
$data{sth}->execute();
($data{gw},$data{cost},$data{provider},$data{region},$data{tariff_zone})=$data{sth}->fetchrow_array();

	if($data{gw} eq "beeline" ) {  $data{b_gw}="mts"; }
	else { $data{b_gw}="beeline"; }
$data{query_b_cost}="\(select abc_costs.cost from abc_provider, abc_costs
        where
        def=\'".$data{DstDEF}."\'
        and start_num <=\'".$data{DstNum}."\' and end_num >=\'".$data{DstNum}."\'
        and abc_provider.tariff_zone=abc_costs.tariff_zone
        and abc_provider.provider_nm=abc_costs.provider_nm
        and abc_costs.gw_nm=\'".$data{b_gw}."\'
        union
        select abc_costs.cost from abc_provider, abc_costs
        where
        def=\'".$data{DstDEF}."\'
        and start_num <=\'".$data{DstNum}."\' and end_num >=\'".$data{DstNum}."\'
        and abc_provider.tariff_zone=abc_costs.tariff_zone
        and abc_costs.provider_nm='Others_providers'
        and abc_costs.gw_nm=\'".$data{b_gw}."\'
        \)
        order by 1 ASC
        limit 1";
#fprint("PERL SCRIPT RUN QUERY $data{query_b_cost}");
$data{sth_b_cost}=$dbh->prepare($data{query_b_cost});
$data{sth_b_cost}->execute();
$data{backup_cost}=$data{sth_b_cost}->fetchrow_array();
$data{cost}=substr($data{cost},1,4);
$data{backup_cost}=substr($data{backup_cost},1,4);
if ($data{gw} eq "mts")
	{
	$data{dialstring}="\{sip_renegotiate_codec_on_reinvite=true,sip_cid_type=rpid,sip_execute_on_image=\'t38_gateway self nocng\'\}\[origination_caller_id_name=4957557821,origination_caller_id_number=4957557821,leg_timeout=6,enable_heartbeat_events=60,nibble_rate=".$data{cost}.",nibble_account=100,accountcode=mts_out4957557821\]sofia\/gateway\/mts/$VARS{destination_number}|\[sip_cid_type=rpid,sip_from_uri=4959811010@ip_addr,origination_caller_id_name=4959811010,origination_caller_id_number=4959811010,enable_heartbeat_events=60,nibble_rate=".$data{backup_cost}.",nibble_account=100,accountcode=beeline_out4959811010\]sofia\/gateway\/beeline_spsr\/$VARS{destination_number}";
	SETV("dialstring","$data{dialstring}");
	SETV("effective_callee_id_number","$VARS{destination_number}");
	}
if ($data{gw} eq "beeline")
	{
	$data{dialstring}="\{sip_execute_on_image='t38_gateway self nocng'\}\[sip_cid_type=rpid,sip_from_uri=4959811010@ip_addr,origination_caller_id_name=4959811010,origination_caller_id_number=4959811010,enable_heartbeat_events=60,nibble_rate=".$data{cost}.",nibble_account=100,accountcode=beeline_out4959811010\]sofia\/gateway\/beeline_spsr\/$VARS{destination_number}|\[sip_cid_type=rpid,origination_caller_id_name=4957557821,origination_caller_id_number=4957557821,leg_timeout=6,enable_heartbeat_events=60,nibble_rate=".$data{backup_cost}.",nibble_account=100,accountcode=mts_out4957557821\]sofia\/gateway\/mts/$VARS{destination_number}";	
	SETV("dialstring","$data{dialstring}");
	SETV("effective_callee_id_number","$VARS{destination_number}");
	SETV("t38_passthru","true");
	}
if ($data{gw} eq "megafon")
	{
	$data{dialstring}="\{sip_renegotiate_codec_on_reinvite=true,sip_cid_type=rpid,sip_execute_on_image=\'t38_gateway self nocng\'\}\[origination_caller_id_name=79261157142,origination_caller_id_number=79261157142,leg_timeout=8,enable_heartbeat_events=60,nibble_rate=".$data{cost}.",nibble_account=100,accountcode=megafon_out9261157142\]sofia/gateway/megafon/$VARS{destination_number}|\[sip_cid_type=rpid,sip_from_uri=4959811010@192.168.29.1,origination_caller_id_name=4959811010,origination_caller_id_number=4959811010,enable_heartbeat_events=60,nibble_rate=".$data{backup_cost}.",nibble_account=100,accountcode=beeline_out4959811010\]sofia\/gateway\/beeline_spsr\/$VARS{destination_number}";
	$session->execute("start_dtmf_generate");
	SETV("pass_rfc2833","true");
	SETV("dialstring","$data{dialstring}");
	SETV("effective_callee_id_number","$VARS{destination_number}");
	}
if (!$data{gw}) 
	{
	$data{gw}="mts";
	$data{dialstring}="\[sip_renegotiate_codec_on_reinvite=true,sip_cid_type=rpid,origination_caller_id_name=4957557821,origination_caller_id_number=4957557821,leg_timeout=6,enable_heartbeat_events=60,nibble_rate=".$data{cost}.",nibble_account=100,accountcode=mts_out4957557821\]sofia\/gateway\/mts/$VARS{destination_number}|\[sip_cid_type=rpid,sip_from_uri=4959811010@ip_addr,origination_caller_id_name=4959811010,origination_caller_id_number=4959811010,enable_heartbeat_events=60,nibble_rate=".$data{backup_cost}.",nibble_account=100,accountcode=beeline_out4959811010\]sofia\/gateway\/beeline_spsr\/$VARS{destination_number}";
	$data{route_not_found_sql}="insert into abc_route_not_found (def,num) values (\'".$data{DstDEF}."\',\'".$data{DstNum}."\')";
        $dbh->do($data{route_not_found_sql});
	SETV("dialstring","$data{dialstring}");
	SETV("effective_callee_id_number","$VARS{destination_number}");
	}

SETV("route_gw","$data{gw}");
SETV("access_level","1");
SETV("effective_callee_id_name","$VARS{destination_number}");
SETV("tariff_zone","$data{tariff_zone}");
#fprint("PERL SCRIPT RUN QUERY $data{query}");
#fprint($VARS{caller_id_number});
#fprint("PERL: GW: $data{gw}  string: $data{dialstring}");
#fprint("PERL SCRIPT RUN foung DST: $VARS{destination_number} T_ZONE: $data{tariff_zone} GW: $data{gw}  COST: $data{cost} PROV: $data{provider} REGION: $data{region} BACKUP_GW: $data{b_gw} BACKUP_COST: $data{backup_cost} ");
$session->execute("bridge","$data{dialstring}");
#fprint("PERL: GW: $data{gw}  string: $data{dialstring}");
$data{sth}->finish();
$dbh->disconnect;
1;
