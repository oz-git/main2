#!/usr/bin/perl
use strict;
use POSIX qw(strftime);
use DBI;
use DBD::Pg;
use DateTime;
our ($session, %data);
my $dbh=DBI->connect( "DBI:Pg:dbname=freeswitch;host=1.1.1.1;port=5432", "login", "pass", {AutoCommit=>1});
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
#$data{query}="select def_costs.region_nm, def_costs.gw_nm, def_costs.provider_nm from def_provider, def_costs 
#	where
#	def=\'".$data{DstDEF}."\'
#	and start_num <=\'".$data{DstNum}."\' and end_num >=\'".$data{DstNum}."\'
#	and def_provider.region_nm=def_costs.region_nm
#	and def_provider.provider_nm=def_costs.provider_nm
#	order by def_costs.cost ASC
#	limit 1";
#$data{sth}=$dbh->prepare($data{query});
#$data{sth}->execute();
#($data{region}, $data{gw}, $data{provider})=$data{sth}->fetchrow_array();
$data{query}="\(select def_costs.gw_nm,def_costs.cost,def_provider.provider_nm,def_provider.region_nm from def_provider, def_costs
        where
        def=\'".$data{DstDEF}."\'
        and start_num <=\'".$data{DstNum}."\' and end_num >=\'".$data{DstNum}."\'
        and def_provider.tariff_zone=def_costs.tariff_zone
        and def_provider.provider_nm=def_costs.provider_nm
	and def_costs.enabled='1'
        union
        select def_costs.gw_nm,def_costs.cost,def_provider.provider_nm,def_provider.region_nm from def_provider, def_costs
        where
        def=\'".$data{DstDEF}."\'
        and start_num <=\'".$data{DstNum}."\' and end_num >=\'".$data{DstNum}."\'
        and def_provider.tariff_zone=def_costs.tariff_zone
        and def_costs.provider_nm='Others_providers'
	and def_costs.enabled='1'
        \)
        order by 2 ASC
        limit 1";
$data{query_b_cost}="\(select def_costs.cost from def_provider, def_costs
        where
        def=\'".$data{DstDEF}."\'
        and start_num <=\'".$data{DstNum}."\' and end_num >=\'".$data{DstNum}."\'
        and def_provider.tariff_zone=def_costs.tariff_zone
        and def_provider.provider_nm=def_costs.provider_nm
	and def_costs.gw_nm=\'beeline\'
        union
        select def_costs.cost from def_provider, def_costs
        where
        def=\'".$data{DstDEF}."\'
        and start_num <=\'".$data{DstNum}."\' and end_num >=\'".$data{DstNum}."\'
        and def_provider.tariff_zone=def_costs.tariff_zone
        and def_costs.provider_nm='Others_providers'
	and def_costs.gw_nm=\'beeline\'
        \)
	order by 1 ASC
        limit 1";

$data{sth}=$dbh->prepare($data{query});
$data{sth}->execute();
($data{gw},$data{cost},$data{provider},$data{region})=$data{sth}->fetchrow_array();
$data{sth_b_cost}=$dbh->prepare($data{query_b_cost});
$data{sth_b_cost}->execute();
$data{backup_cost}=$data{sth_b_cost}->fetchrow_array();
$data{cost}=substr($data{cost},1,4);
$data{backup_cost}=substr($data{backup_cost},1,4);

if( $data{region}=~/^Москва/)
        {
        $data{region_type}="MSK_REGION";
        }
else
        {
        $data{region_type}="OTHER_REGION";
        }
SETV("region_type","$data{region_type}");
$data{gw_default}="sofia\/gateway\/msk_tex_ro_voip\/777$VARS{destination_number}";

if ($data{gw} eq "mts")
	{
	$data{dialstring}="\{sip_renegotiate_codec_on_reinvite=true,sip_cid_type=rpid\}\[origination_caller_id_name=4957557821,origination_caller_id_number=4957557821,leg_timeout=6,enable_heartbeat_events=60,nibble_rate=".$data{cost}.",nibble_account=100\]sofia\/gateway\/mts/$VARS{destination_number}|\[enable_heartbeat_events=60,nibble_rate=".$data{backup_cost}.",nibble_account=100\]sofia\/gateway\/msk_tex_ro_voip\/777$VARS{destination_number}";
	#$data{dialstring}="\{sip_renegotiate_codec_on_reinvite=true,sip_cid_type=rpid,origination_caller_id_name=4957557821,origination_caller_id_number=4957557821\}sofia\/gateway\/mts/$VARS{destination_number}";
	SETV("dialstring","$data{dialstring}");
	SETV("effective_callee_id_number","$VARS{destination_number}");
	}
if ($data{gw} eq "beeline")
	{
	#$data{dialstring}="\{sip_renegotiate_codec_on_reinvite=true,sip_cid_type=rpid,origination_caller_id_name=4957557821,origination_caller_id_number=4957557821\}\[leg_timeout=45\]sofia\/gateway\/mts/$VARS{destination_number}";
	$data{dialstring}="\[enable_heartbeat_events=60,nibble_rate=".$data{cost}.",nibble_account=100\]sofia\/gateway\/msk_tex_ro_voip\/777$VARS{destination_number}";
	SETV("dialstring","$data{dialstring}");
	SETV("effective_callee_id_number","$VARS{destination_number}");
	}
if ($data{gw} eq "megafon")
	{
	$data{dialstring}="\{sip_renegotiate_codec_on_reinvite=true,sip_cid_type=rpid,origination_caller_id_name=79261157142,origination_caller_id_number=79261157142\}\[leg_timeout=6,enable_heartbeat_events=60,nibble_rate=".$data{cost}.",nibble_account=100\]sofia/gateway/megafon/$VARS{destination_number}|\[enable_heartbeat_events=60,nibble_rate=".$data{backup_cost}.",nibble_account=100\]sofia\/gateway\/msk_tex_ro_voip\/777$VARS{destination_number}";
	SETV("effective_callee_id_number","$VARS{destination_number}");
	#temp for megafon route
	#if (($today>=1)&&($today<=5)&&($hour>=9)&&($hour<16))
        #                {
        #                fprint("MEGAFON TEST WORK TIME USE GW MEGAFON");
        #                $data{dialstring}="\{sip_renegotiate_codec_on_reinvite=true,sip_cid_type=rpid,origination_caller_id_name=79261157142,origination_caller_id_number=79261157142\}\[leg_timeout=6\]sofia/gateway/megafon/$VARS{destination_number}";
        #                }
        #        else
        #                {
        #                fprint("NOT MEGAFON TEST WORK TIME USE GW BEELINE");
        #                $data{dialstring}="sofia\/gateway\/msk_tex_ro_voip\/$VARS{destination_number}";
        #                }
	#$data{dialstring}="\{sip_renegotiate_codec_on_reinvite=true,sip_cid_type=rpid,origination_caller_id_name=4957557821,origination_caller_id_number=4957557821\}\[leg_timeout=6,enable_heartbeat_events=60,nibble_rate=".$data{cost}.",nibble_account=100\]sofia\/gateway\/mts/$VARS{destination_number}|\[enable_heartbeat_events=60,nibble_rate=".$data{backup_cost}.",nibble_account=100\]sofia\/gateway\/msk_tex_ro_voip\/$VARS{destination_number}";
	SETV("dialstring","$data{dialstring}");
	}
if (!$data{gw}) 
	{
	$data{gw}="mts";
	fprint("DEFAULT GW MTS while ROUTE NOT FOUND IN LCR TABLE");
	$data{dialstring}="\{sip_renegotiate_codec_on_reinvite=true,sip_cid_type=rpid,origination_caller_id_name=4957557821,origination_caller_id_number=4957557821\}\[leg_timeout=6,enable_heartbeat_events=60,nibble_rate=".$data{cost}.",nibble_account=100\]sofia\/gateway\/mts/$VARS{destination_number}|\[enable_heartbeat_events=60,nibble_rate=".$data{backup_cost}.",nibble_account=100\]sofia\/gateway\/msk_tex_ro_voip\/777$VARS{destination_number}";
	#$data{dialstring}="\{sip_renegotiate_codec_on_reinvite=true,sip_cid_type=rpid,origination_caller_id_name=4957557821,origination_caller_id_number=4957557821\}\[leg_timeout=6\]sofia\/gateway\/mts/$VARS{destination_number}";
	#fprint("DEFAULT GW BEELINE while ROUTE NOT FOUND IN LCR TABLE");
	#$data{dialstring}="sofia\/gateway\/msk_tex_ro_voip\/$VARS{destination_number}";
	$data{route_not_found_sql}="insert into def_route_not_found (def,num) values (\'".$data{DstDEF}."\',\'".$data{DstNum}."\')";
	$dbh->do($data{route_not_found_sql});
	SETV("dialstring","$data{dialstring}");
	SETV("effective_callee_id_number","$VARS{destination_number}");
	}
 SETV("region","$data{region}");
 SETV("route_gw","$data{gw}");
 SETV("access_level","1");
 SETV("effective_callee_id_name","$VARS{destination_number}");
#fprint("PERL SCRIPT ROUTEDEF RUN $data{dialstring}");
fprint("PERL SCRIPT MOBILEROUTE RUN foung DST: $VARS{destination_number} GW: $data{gw}  COST: $data{cost} PROV: $data{provider} REGION: $data{region} R_ACCESS: $data{region_type} BACKUP_COST: $data{backup_cost}");
 #fprint("PERL: GET BRIDGE");
 #fprint("PERL: GW: $data{gw} R_ACCESS: $data{region_type}  REGION: $data{region}  PROV: $data{provider} $VARS{destination_number} dialstring: $data{dialstring}");

$session->execute("bridge","$data{dialstring}");
# $session->execute("bridge","$data{gw_default}");
#fprint("PERL SCRIPT RUN QUERY $data{query}");
#fprint($VARS{caller_id_number});
#fprint("PERL SCRIPT RUN foung gateway: $data{gw}");
#fprint("PERL: GW: $data{gw}  string: $data{dialstring}");
$data{sth}->finish();
if( $data{sth_b_cost} ) { $data{sth_b_cost}->finish(); }
#$data{route_not_found_sql_sth}->finish();
$dbh->disconnect;
1;
