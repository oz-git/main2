#!/usr/bin/perl
use Data::Dumper;
use CGI ':standart';
##use CGI::FastTemplate;
use CGI::Carp qw(fatalsToBrowser);
#use Text::Iconv;
use DBI;
use DBD::Pg;
#my $converter = Text::Iconv->new("WINDOWS-1251", "UTF-8");
my $dbh=DBI->connect( "DBI:Pg:dbname=freeswitch;host=1.1.1.1;port=5432", "login", "pass", {AutoCommit=>1});
#my ($vars, $keys, %data);
my (%data,$arg);
my $qw=CGI->new();
#open OUTFILE, ">>queue.tst.txt" or die $!;
my @names = $qw->param;

 foreach $arg (@names)

    {
		$data{$arg}=$qw->param($arg);
#           print OUTFILE "$arg  $data{$arg}\n";
    } 
	if ($data{CCAction} eq "members-count")
	{
	$data{query}="INSERT INTO cclog (eventdatelocal,ccqueue,cccount,ccaction,ccevent) VALUES ('$data{EventDateLocal}','$data{CCQueue}','$data{CCCount}','$data{CCAction}','$data{event}')";
	#print OUTFILE "$data{query}\n";
	$dbh->do($data{query});	
	}
	if ($data{CCAction} eq "agent-state-change")
	{
	$data{query}="INSERT INTO cclog (eventdatelocal,ccagent,ccagentstate,ccaction,ccevent) VALUES ('$data{EventDateLocal}','$data{CCAgent}','$data{CCAgentState}','$data{CCAction}','$data{CCAction}')";
	#print OUTFILE "$data{query}\n";
	$dbh->do($data{query});
	}
	if ($data{CCAction} eq "agent-status-change")
	{
	$data{query}="INSERT INTO cclog (eventdatelocal,ccagent,ccagentstatus,ccaction,ccevent) VALUES ('$data{EventDateLocal}','$data{CCAgent}','$data{CCAgentStatus}','$data{CCAction}','$data{event}')";
	$dbh->do($data{query});
	#print OUTFILE "$data{query}\n";
	}
	if ($data{CCAction} eq "member-queue-start")
	{
	$data{query}="INSERT INTO cclog (coreuuid,ccmembersessionuuid,ccmemberuuid,ccmembercidnumber,ccqueue,callerdestinationnumber,eventdatelocal,ccaction,ccevent) VALUES ('$data{CoreUUID}','$data{CCMemberSessionUUID}','$data{CCMemberUUID}','$data{CCMemberCIDNumber}','$data{CCQueue}','$data{CallerDestinationNumber}','$data{EventDateLocal}','$data{CCAction}','$data{event}')";
	#print OUTFILE "$data{query}\n";
	$dbh->do($data{query});
	}
	if ($data{CCAction} eq "agent-offering")
	{
	$data{query}="INSERT INTO cclog (coreuuid,ccmembersessionuuid,ccmemberuuid,ccmembercidnumber,ccqueue,ccagent,eventdatelocal,ccaction,ccevent) VALUES ('$data{CoreUUID}','$data{CCMemberSessionUUID}','$data{CCMemberUUID}','$data{CCMemberCIDNumber}','$data{CCQueue}','$data{CCAgent}','$data{EventDateLocal}','$data{CCAction}','$data{event}')";
	#print OUTFILE "$data{query}\n";
        $dbh->do($data{query});
	}
	if ($data{CCAction} eq "bridge-agent-start")
	{
	$data{query}="INSERT INTO cclog (coreuuid,ccmembersessionuuid,ccmemberuuid,ccmembercidnumber,ccqueue,ccagent,ccmemberjoinedtime,ccagentcalledtime,ccagentansweredtime,eventdatelocal,ccaction,ccevent) VALUES ('$data{CoreUUID}','$data{CCMemberSessionUUID}','$data{CCMemberUUID}','$data{CCMemberCIDNumber}','$data{CCQueue}','$data{CCAgent}','$data{CCMemberJoinedTime}','$data{CCAgentCalledTime}','$data{CCAgentAnsweredTime}','$data{EventDateLocal}','$data{CCAction}','$data{event}')";
	#print OUTFILE "$data{query}\n";
	$dbh->do($data{query});
	}
	if ( $data{CCAction} eq "member-queue-end" )
	{
		if ( $data{CCCause} eq "Terminated"  )
		{
		$data{query}="INSERT INTO cclog (coreuuid,ccmembersessionuuid,ccmemberuuid,ccmembercidnumber,ccqueue,ccagent,ccmemberjoinedtime,ccagentcalledtime,ccagentansweredtime,ccmemberleavingtime,eventdatelocal,ccaction,transferdst,ccevent,cchangupcause) VALUES ('$data{CoreUUID}','$data{CCMemberSessionUUID}','$data{CCMemberUUID}','$data{CCMemberCIDNumber}','$data{CCQueue}','$data{CCAgent}','$data{CCMemberJoinedTime}','$data{CCAgentCalledTime}','$data{CCAgentAnsweredTime}','$data{CCMemberLeavingTime}','$data{EventDateLocal}','$data{CCAction}','$data{TransferDst}','$data{event}','$data{CCHangupCause}')";
		#print OUTFILE "$data{query}\n";
        	$dbh->do($data{query});
		}
		if ( $data{CCCause} eq "Cancel"  )
		{
		$data{query}="INSERT INTO cclog (coreuuid,ccmembersessionuuid,ccmemberuuid,ccmembercidnumber,ccqueue,ccmemberjoinedtime,ccmemberleavingtime,eventdatelocal,ccaction,ccevent) VALUES ('$data{CoreUUID}','$data{CCMemberSessionUUID}','$data{CCMemberUUID}','$data{CCMemberCIDNumber}','$data{CCQueue}','$data{CCMemberJoinedTime}','$data{CCMemberLeavingTime}','$data{EventDateLocal}','$data{CCAction}','$data{event}')";
		#print OUTFILE "$data{query}\n";
                $dbh->do($data{query});
		}
	
	
	}
	if ( $data{CCAction} eq "bridge-agent-end" )
	{
	$data{query}="INSERT INTO cclog (coreuuid,ccmembersessionuuid,ccmemberuuid,ccmembercidnumber,ccqueue,ccagent,ccmemberjoinedtime,ccagentcalledtime,ccagentansweredtime,ccbridgeterminatedtime,cchangupcause,variableendpointdisposition,ccaction,ccevent,eventdatelocal) VALUES ('$data{CoreUUID}','$data{CCMemberSessionUUID}','$data{CCMemberUUID}','$data{CCMemberCIDNumber}','$data{CCQueue}','$data{CCAgent}','$data{CCMemberJoinedTime}','$data{CCAgentCalledTime}','$data{CCAgentAnsweredTime}','$data{CCBridgeTerminatedTime}','$data{CCHangupCause}','$data{VariableEndpointDisposition}','$data{CCAction}','$data{event}','$data{EventDateLocal}')";
	#print OUTFILE "$data{query}\n";
	$dbh->do($data{query});
	}
	if ( $data{CCAction} eq "bridge-agent-fail" )
	{
	$data{query}="INSERT INTO cclog (coreuuid,ccmembersessionuuid,ccmemberuuid,ccmembercidnumber,ccqueue,ccagent,eventdatelocal,ccagentcalledtime,ccagentabortedtime,ccaction,ccevent) VALUES ('$data{CoreUUID}','$data{CCMemberSessionUUID}','$data{CCMemberUUID}','$data{CCMemberCIDNumber}','$data{CCQueue}','$data{CCAgent}','$data{EventDateLocal}','$data{CCAgentCalledTime}','$data{CCAgentAbortedTime}','$data{CCAction}','$data{event}')";
	#print OUTFILE "$data{query}\n";
	$dbh->do($data{query});
	}	
$dbh -> disconnect;
#print OUTFILE "\n\n\n";
#close OUTFILE;
print "\n\n";


