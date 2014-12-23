#!/usr/bin/env python
 
import string
import datetime
import time
import requests
import os
import os.path
import psutil
from ESL import *

#cclogpid = open("/var/run/cclog.pid", "w")
#cclogpid.write("Python is a great language.\nYeah its great!!\n");
#cclogpid.close()


def cclog(): 
	con = ESLconnection("127.0.0.1","8021","ClueCon")
	if con.connected:
    		con.events("plain", "all");
    	while(con.connected()):
        	e = con.recvEvent()
        	if e:   
            		name = e.getHeader("Event-Name")
            	if name == 'CUSTOM':
                	subclass = e.getHeader("Event-Subclass")
			ccaction = e.getHeader("CC-Action")
		 
               		if subclass == 'callcenter::info':
				event = 'NULL'
				if ccaction == 'bridge-agent-start':
					#print 'EVENT AGENT CALLER'
					#print '-----CONNECT-----'
                                        #print 'AGENT_ANSWERCALL bridge-agent-start ->>'+name+'|'+subclass
					#print 'CC-Member-Joined-Time  ', datetime.datetime.fromtimestamp(float(e.getHeader("CC-Member-Joined-Time")))
					#print 'CC-Agent-Called-Time  ', datetime.datetime.fromtimestamp(float(e.getHeader("CC-Agent-Called-Time")))
					#print 'CC-Agent-Answered-Time  ', datetime.datetime.fromtimestamp(float(e.getHeader("CC-Agent-Answered-Time")))
					#print 'CC-Queue  '+e.getHeader("CC-Queue")
					#print 'CC-Agent  '+e.getHeader("CC-Agent")
					#print 'CC-Member-UUID  '+e.getHeader("CC-Member-UUID")
					#print 'CC-Member-Session-UUID  '+e.getHeader("CC-Member-Session-UUID")+'\n'
					CCMemberJoinedTime = datetime.datetime.fromtimestamp(float(e.getHeader("CC-Member-Joined-Time")))
					CCAgentCalledTime = datetime.datetime.fromtimestamp(float(e.getHeader("CC-Agent-Called-Time")))
					CCAgentAnsweredTime = datetime.datetime.fromtimestamp(float(e.getHeader("CC-Agent-Answered-Time")))
					CCQueue = e.getHeader("CC-Queue")
					CCAction = e.getHeader("CC-Action")
					CCAgent = e.getHeader("CC-Agent")
					CoreUUID = e.getHeader("Core-UUID")
					EventDateLocal = e.getHeader("Event-Date-Local")
					if e.getHeader("CC-Member-CID-Number"):
                                                #print 'CC-Member-CID-Number  '+e.getHeader("CC-Member-CID-Number")
						CCMemberCIDNumber = e.getHeader("CC-Member-CID-Number")
                                        else:
                                                #print 'CC-Member-CID-Number  UNDEFINED'
						CCMemberCIDNumber = 'UNDEFINED'
					CCMemberUUID = e.getHeader("CC-Member-UUID")
					CCMemberSessionUUID = e.getHeader("CC-Member-Session-UUID")
					payload = {'event_type':'agent_caller', 'event':'CONNECT', 'CCAction':CCAction, 'CoreUUID':CoreUUID, 'CCMemberJoinedTime':CCMemberJoinedTime, \
					'CCAgentCalledTime':CCAgentCalledTime, 'CCAgentAnsweredTime':CCAgentAnsweredTime, 'CCQueue':CCQueue, 'CCAgent':CCAgent, \
					'CCMemberCIDNumber':CCMemberCIDNumber, 'CCMemberCIDNumber':CCMemberCIDNumber, \
					'CCMemberUUID':CCMemberUUID, 'CCMemberSessionUUID':CCMemberSessionUUID, 'EventDateLocal':EventDateLocal}
					r = requests.post("http://fs0.cpcr.ru/callcenter/queue.pl", timeout=1, data=payload)
					#print e.serialize()
				elif ccaction == 'members-count':
					#print 'EVENT QUEUE'
					#print 'QUEUE COUNT ->>'+name+'|'+subclass
					#print 'CC-Queue  '+e.getHeader("CC-Queue")
					#print 'CC-Count  '+e.getHeader("CC-Count")
					#print 'CC-Selection  '+e.getHeader("CC-Selection")+'\n'
					EventDateLocal = e.getHeader("Event-Date-Local")
					CCQueue = e.getHeader("CC-Queue")
					CCCount = e.getHeader("CC-Count")
					CCAction = e.getHeader("CC-Action")
					CCSelection = e.getHeader("CC-Selection")
					payload = {'event_type':'queue', 'event':'QUEUE_MEMBERS_COUNT', 'CCAction':CCAction, 'EventDateLocal':EventDateLocal, 'CCQueue':CCQueue, 'CCCount':CCCount, 'CCSelection':CCSelection }
					r = requests.post("http://fs0.cpcr.ru/callcenter/queue.pl", timeout=1, data=payload)
				elif ccaction == 'member-queue-start':
					#print 'EVENT CALLER'
					#print '-----ENTERQUEUE-----'
					#print 'CALLER_ENTERQUEUE ->>'+name+'|'+subclass
                                        #print 'member-queue-start  '+e.getHeader("Event-Date-Local")
                                        #print 'CC-Queue  '+e.getHeader("CC-Queue")
					if e.getHeader("CC-Member-CID-Number"):
						#print 'CC-Member-CID-Number  '+e.getHeader("CC-Member-CID-Number")
						CCMemberCIDNumber = e.getHeader("CC-Member-CID-Number")
					else:
						#print 'CC-Member-CID-Number  UNDEFINED'
						CCMemberCIDNumber = 'UNDEFINED'
					#print 'CC-Member-UUID  '+e.getHeader("CC-Member-UUID")
					#print 'CC-Member-Session-UUID  '+e.getHeader("CC-Member-Session-UUID")+'\n'
					EventDateLocal = e.getHeader("Event-Date-Local")
					CoreUUID = e.getHeader("Core-UUID")
					CallerDestinationNumber = e.getHeader("Caller-Destination-Number")
					CCQueue = e.getHeader("CC-Queue")
					CCAction = e.getHeader("CC-Action")
					CCMemberUUID = e.getHeader("CC-Member-UUID")
                                        CCMemberSessionUUID = e.getHeader("CC-Member-Session-UUID")
					payload = {'event_type':'caller', 'event':'ENTERQUEUE', 'CoreUUID':CoreUUID, 'EventDateLocal':EventDateLocal, 'CCQueue':CCQueue, 'CCAction':CCAction, \
					'CCMemberUUID':CCMemberUUID, 'CCMemberSessionUUID':CCMemberSessionUUID, 'CCMemberCIDNumber':CCMemberCIDNumber, 'CallerDestinationNumber':CallerDestinationNumber}
					r = requests.post("http://fs0.cpcr.ru/callcenter/queue.pl", timeout=1, data=payload)
					#print e.serialize()+'  CALLER_ENTERQUEUE\n'
				elif ccaction == 'agent-offering':
					#print 'EVENT AGENT CALLER'
					#print 'RING_AGENT agent-offering ->>'+name+'|'+subclass
					#print 'Event-Date-Local  '+e.getHeader("Event-Date-Local")
					#print 'CC-Queue  '+e.getHeader("CC-Queue")
					#print 'CC-Agent  '+e.getHeader("CC-Agent")
					if e.getHeader("CC-Member-CID-Number"):
                                                #print 'CC-Member-CID-Number  '+e.getHeader("CC-Member-CID-Number")
						CCMemberCIDNumber = e.getHeader("CC-Member-CID-Number")
                                        else:
                                                #print 'CC-Member-CID-Number  UNDEFINED'
						CCMemberCIDNumber = 'UNDEFINED'
                                        #print 'CC-Member-UUID  '+e.getHeader("CC-Member-UUID")
                                        #print 'CC-Member-Session-UUID  '+e.getHeader("CC-Member-Session-UUID")+'\n'
					CoreUUID = e.getHeader("Core-UUID")
					EventDateLocal = e.getHeader("Event-Date-Local")
					CCQueue = e.getHeader("CC-Queue")
					CCAgent = e.getHeader("CC-Agent")
					CCAction = e.getHeader("CC-Action")
					CCMemberUUID = e.getHeader("CC-Member-UUID")
                                        CCMemberSessionUUID = e.getHeader("CC-Member-Session-UUID")
					payload = {'event_type':'agent_caller', 'event':'RING_AGENT', 'CoreUUID':CoreUUID, 'EventDateLocal':EventDateLocal, 'CCAction':CCAction, 'CCQueue':CCQueue, \
					'CCAgent':CCAgent, 'CCMemberCIDNumber':CCMemberCIDNumber, 'CCMemberUUID':CCMemberUUID, 'CCMemberSessionUUID':CCMemberSessionUUID}
					r = requests.post("http://fs0.cpcr.ru/callcenter/queue.pl", timeout=1, data=payload)
					#print e.serialize()	
				elif ccaction == 'member-queue-end':
					if e.getHeader("CC-Cause") == 'Terminated':
						#print 'EVENT AGENT CALLER'
                                        	#print 'member-queue-end  ->>'+name+'|'+subclass
						TransferDst = 'NULL'
						if e.getHeader("variable_sip_hangup_phrase") == 'OK':
							#print '--------COMPLETEAGENT---------'
							event = 'COMPLETEAGENT'
						if e.getHeader("variable_sip_term_status") == '200':
							#print '--------COMPLETECALLER--------'
							event = 'COMPLETECALLER'
						if e.getHeader("variable_att_xfer_destination_number"):
							#print '-----TRANSFER-----'
							#print '-- TRANSFER TO '+e.getHeader("variable_att_xfer_destination_number")+' ---'
							event = 'TRANSFER'
							TransferDst = e.getHeader("variable_att_xfer_destination_number")
						if e.getHeader("Caller-RDNIS"):
							event = 'TRANSFER'
							TransferDst = e.getHeader("Caller-Destination-Number")
						if e.getHeader("variable_last_bridge_hangup_cause") == 'ATTENDED_TRANSFER':
							event = 'TRANSFER'
							TransferDst = e.getHeader("variable_last_sent_callee_id_number")
						#if e.getHeader("variable_transfer_history"):
						#	event = 'TRANSFER'
						#	TransferDst = e.getHeader("Other-Leg-Destination-Number")
						#if 	
						#print 'Event-Date-Local  '+e.getHeader("Event-Date-Local")
						#print 'CC-Member-Joined-Time  ', datetime.datetime.fromtimestamp(float(e.getHeader("CC-Member-Joined-Time")))
						#print 'CC-Agent-Called-Time  ', datetime.datetime.fromtimestamp(float(e.getHeader("CC-Agent-Called-Time")))
						#print 'CC-Agent-Answered-Time  ', datetime.datetime.fromtimestamp(float(e.getHeader("CC-Agent-Answered-Time")))
						#print 'CC-Member-Leaving-Time  ', datetime.datetime.fromtimestamp(float(e.getHeader("CC-Member-Leaving-Time")))
						#print 'CC-Action  '+e.getHeader("CC-Action")
                                                #print 'CC-Queue  '+e.getHeader("CC-Queue")
                                                #print 'CC-Agent  '+e.getHeader("CC-Agent"):/
                                                #print 'CC-Cause  '+e.getHeader("CC-Cause")
						#print 'CC-Hangup-Cause  '+e.getHeader("CC-Hangup-Cause")  
                                                #print 'variable_current_application_data  '+e.getHeader("variable_current_application_data")
                                                #print 'variable_current_application  '+e.getHeader("variable_current_application")
						if e.getHeader("CC-Member-CID-Number"):
                                                	#print 'CC-Member-CID-Number  '+e.getHeader("CC-Member-CID-Number")
							CCMemberCIDNumber = e.getHeader("CC-Member-CID-Number")
                                        	else:
                                                	#print 'CC-Member-CID-Number  UNDEFINED'
							CCMemberCIDNumber = 'UNDEFINED'
                                        	#print 'CC-Member-UUID  '+e.getHeader("CC-Member-UUID")
                                        	#print 'CC-Member-Session-UUID  '+e.getHeader("CC-Member-Session-UUID")+'\n'
						CoreUUID = e.getHeader("Core-UUID")
						EventDateLocal = e.getHeader("Event-Date-Local")
						CCMemberJoinedTime = datetime.datetime.fromtimestamp(float(e.getHeader("CC-Member-Joined-Time")))
						CCAgentCalledTime = datetime.datetime.fromtimestamp(float(e.getHeader("CC-Agent-Called-Time")))
						CCAgentAnsweredTime = datetime.datetime.fromtimestamp(float(e.getHeader("CC-Agent-Answered-Time")))
						CCMemberLeavingTime = datetime.datetime.fromtimestamp(float(e.getHeader("CC-Member-Leaving-Time")))
						CCAction = e.getHeader("CC-Action")
						CCQueue = e.getHeader("CC-Queue")
						CCAgent = e.getHeader("CC-Agent")
						CCCause = e.getHeader("CC-Cause")
						CCHangupCause = e.getHeader("CC-Hangup-Cause")
						VariableLastBridgeHangupCause = e.getHeader("variable_last_bridge_hangup_cause")
						CCMemberUUID = e.getHeader("CC-Member-UUID")
                                        	CCMemberSessionUUID = e.getHeader("CC-Member-Session-UUID")
						payload = {'event_type':'agent_caller', 'event':event, 'CoreUUID':CoreUUID, 'EventDateLocal':EventDateLocal, 'CCMemberJoinedTime':CCMemberJoinedTime, \
						'CCAgentCalledTime':CCAgentCalledTime, 'CCAgentAnsweredTime':CCAgentAnsweredTime, 'CCMemberLeavingTime':CCMemberLeavingTime, \
						'CCAction':CCAction, 'CCQueue':CCQueue, 'CCAgent':CCAgent, 'CCMemberUUID':CCMemberUUID, 'CCMemberSessionUUID':CCMemberSessionUUID, \
						'CCMemberCIDNumber':CCMemberCIDNumber, 'TransferDst':TransferDst, 'CCHangupCause':CCHangupCause, 'VariableLastBridgeHangupCause':VariableLastBridgeHangupCause, 'CCCause':CCCause}
						r = requests.post("http://fs0.cpcr.ru/callcenter/queue.pl", timeout=1, data=payload)
						#print e.serialize()
					if e.getHeader("CC-Cause") == 'Cancel':
						print 'EVENT CALLER'
						event = e.getHeader("CC-Cancel-Reason")
						if e.getHeader("CC-Cancel-Reason") == 'NO_AGENT_TIMEOUT':
                                                	#print '-----EXITEMPTY-----'
							event = 'EXITEMPTY'
						if e.getHeader("CC-Cancel-Reason") == 'TIMEOUT':
							#print '-----EXITWITHTIMEOUT-----'
							event = 'EXITWITHTIMEOUT'
						if e.getHeader("CC-Cancel-Reason") == 'BREAK_OUT':
							#print '-----HANGUPCALLER-----'
							event = 'HANGUPCALLER'
							#print e.serialize()
                                                #print 'member-queue-end'
						#print 'CC-Member-Joined-Time  ', datetime.datetime.fromtimestamp(float(e.getHeader("CC-Member-Joined-Time")))
                                                #print 'CC-Member-Leaving-Time  ', datetime.datetime.fromtimestamp(float(e.getHeader("CC-Member-Leaving-Time")))
                                                #print 'CC-Queue  '+e.getHeader("CC-Queue")
                                                #print 'CC-Cancel-Reason  '+e.getHeader("CC-Cancel-Reason")
                                                if e.getHeader("CC-Member-CID-Number"):
                                                       	#print 'CC-Member-CID-Number  '+e.getHeader("CC-Member-CID-Number")+'\n'
							CCMemberCIDNumber = e.getHeader("CC-Member-CID-Number")
                                                else:
                                                       	#print 'CC-Member-CID-Number  UNDEFINED'
							CCMemberCIDNumber = 'UNDEFINED'
                                                #print 'CC-Member-UUID  '+e.getHeader("CC-Member-UUID")
                                                #print 'CC-Member-Session-UUID  '+e.getHeader("CC-Member-Session-UUID")+'\n'
						print 'CCCause '+e.getHeader("CC-Cause")
						print event+'\n'
						CoreUUID = e.getHeader("Core-UUID")	
						CCCause = e.getHeader("CC-Cause")
						CCMemberJoinedTime = datetime.datetime.fromtimestamp(float(e.getHeader("CC-Member-Joined-Time")))
						CCMemberLeavingTime = datetime.datetime.fromtimestamp(float(e.getHeader("CC-Member-Leaving-Time")))
						CCQueue = e.getHeader("CC-Queue")
						CCAction = e.getHeader("CC-Action")
						EventDateLocal = e.getHeader("Event-Date-Local")
						CCCancelReason = e.getHeader("CC-Cancel-Reason")
						CCMemberUUID = e.getHeader("CC-Member-UUID")
                                                CCMemberSessionUUID = e.getHeader("CC-Member-Session-UUID")
						payload = {'event_type':'caller', 'event':event, 'CoreUUID':CoreUUID, 'CCMemberJoinedTime':CCMemberJoinedTime, 'CCMemberLeavingTime':CCMemberLeavingTime, \
						'CCQueue':CCQueue, 'CCAction':CCAction, 'CCCancelReason':CCCancelReason, 'CCMemberUUID':CCMemberUUID, 'CCMemberSessionUUID':CCMemberSessionUUID, \
						'CCMemberCIDNumber':CCMemberCIDNumber, 'EventDateLocal':EventDateLocal, 'CCCause':CCCause}
						r = requests.post("http://fs0.cpcr.ru/callcenter/queue.pl", timeout=1, data=payload)
                                                	#print e.serialize()
                                elif ccaction == 'bridge-agent-end':
					#print 'EVENT AGENT CALLER'
                                        #print 'bridge-agent-end ->>'+name+'|'+subclass
					#print 'CC-Member-Joined-Time  ', datetime.datetime.fromtimestamp(float(e.getHeader("CC-Member-Joined-Time")))
                                        #print 'CC-Agent-Called-Time  ', datetime.datetime.fromtimestamp(float(e.getHeader("CC-Agent-Called-Time")))
                                        #print 'CC-Agent-Answered-Time  ', datetime.datetime.fromtimestamp(float(e.getHeader("CC-Agent-Answered-Time")))
                                        #print 'CC-Bridge-Terminated-Time  ', datetime.datetime.fromtimestamp(float(e.getHeader("CC-Bridge-Terminated-Time")))
					#print 'CC-Queue  '+e.getHeader("CC-Queue")
                                        #print 'CC-Agent  '+e.getHeader("CC-Agent")
                                        #print 'CC-Hangup-Cause  '+e.getHeader("CC-Hangup-Cause")
					if e.getHeader("variable_sip_hangup_phrase") == 'OK':
                                                        #print '--------COMPLETEAGENT---------'
                                        	event = 'COMPLETECALLER'
                                        if e.getHeader("variable_sip_term_status") == '200':
                                                        #print '--------COMPLETECALLER--------'
                                        	event = 'COMPLETEAGENT'
					TransferDst = 'NULL'
					if e.getHeader("variable_att_xfer_destination_number"):
                                                        #print '-----TRANSFER-----'
                                                        #print '-- TRANSFER TO '+e.getHeader("variable_att_xfer_destination_number")+' ---'
                                        	event = 'TRANSFER'
                                        	TransferDst = e.getHeader("variable_att_xfer_destination_number")
                                        if e.getHeader("Caller-RDNIS"):
                                        	event = 'TRANSFER'
                                        	TransferDst = e.getHeader("Caller-Destination-Number")
					if e.getHeader("variable_endpoint_disposition") == 'BLIND_TRANSFER':
						event = 'TRANSFER'
						#TransferDst = e.getHeader("Caller-Destination-Number")
					if e.getHeader("variable_endpoint_disposition") == 'ATTENDED_TRANSFER':
						event = 'TRANSFER'
					if e.getHeader("variable_transfer_to"):
						event = 'TRANSFER'
						#TransferDst = e.getHeader("Caller-Destination-Number")
					if e.getHeader("CC-Member-CID-Number"):
                                                #print 'CC-Member-CID-Number  '+e.getHeader("CC-Member-CID-Number")
                                                CCMemberCIDNumber = e.getHeader("CC-Member-CID-Number")
                                        else:
                                        	#print 'CC-Member-CID-Number  UNDEFINED'
						CCMemberCIDNumber = 'UNDEFINED'
                                        #print 'CC-Member-UUID  '+e.getHeader("CC-Member-UUID")
                                        #print 'CC-Member-Session-UUID  '+e.getHeader("CC-Member-Session-UUID")+'\n'
					EventDateLocal = e.getHeader("Event-Date-Local")
					CoreUUID = e.getHeader("Core-UUID")
					CCMemberJoinedTime = datetime.datetime.fromtimestamp(float(e.getHeader("CC-Member-Joined-Time")))
					CCAgentCalledTime = datetime.datetime.fromtimestamp(float(e.getHeader("CC-Agent-Called-Time")))
					CCAgentAnsweredTime = datetime.datetime.fromtimestamp(float(e.getHeader("CC-Agent-Answered-Time")))
					CCBridgeTerminatedTime = datetime.datetime.fromtimestamp(float(e.getHeader("CC-Bridge-Terminated-Time")))
					CCQueue = e.getHeader("CC-Queue")
					CCAgent = e.getHeader("CC-Agent")
					CCAction = e.getHeader("CC-Action")
					VariableEndpointDisposition = e.getHeader("variable_endpoint_disposition")
					CCHangupCause = e.getHeader("CC-Hangup-Cause")
					CCMemberUUID = e.getHeader("CC-Member-UUID")
					CCMemberSessionUUID = e.getHeader("CC-Member-Session-UUID")
					payload = {'event_type':'agent_caller', 'event':event, 'CCAction':CCAction, 'CoreUUID':CoreUUID, 'CCMemberJoinedTime':CCMemberJoinedTime, 'CCAgentCalledTime':CCAgentCalledTime, 'VariableEndpointDisposition':VariableEndpointDisposition, \
					'CCAgentAnsweredTime':CCAgentAnsweredTime, 'CCBridgeTerminatedTime':CCBridgeTerminatedTime, 'CCQueue':CCQueue, 'CCAgent':CCAgent, 'CCHangupCause':CCHangupCause, \
					'CCMemberCIDNumber':CCMemberCIDNumber, 'CCMemberUUID':CCMemberUUID, 'CCMemberSessionUUID':CCMemberSessionUUID, 'TransferDst':TransferDst, 'EventDateLocal':EventDateLocal}
					r = requests.post("http://fs0.cpcr.ru/callcenter/queue.pl", timeout=1, data=payload)
					#print e.serialize()
				elif ccaction == 'agent-status-change':
					#print 'EVENT AGENT'
					#print 'agent-status-change ->>'+name+'|'+subclass
					#print 'CC-Agent  '+e.getHeader("CC-Agent")
					#print 'CC-Agent-Status  '+e.getHeader("CC-Agent-Status")+'\n'
					#print e.serialize()
					if e.getHeader("CC-Agent-Status") == 'Available':
						event = 'ADDMEMBER'
					elif e.getHeader("CC-Agent-Status") == 'Logged Out':
						event = 'REMOVEMEMBER'
					else:
						event = 'NOTDEFINED'
					EventDateLocal = e.getHeader("Event-Date-Local")
					CCAction = e.getHeader("CC-Action")
					CCAgent = e.getHeader("CC-Agent")
					CCAgentStatus = e.getHeader("CC-Agent-Status")
					payload = {'event_type':'agent', 'CCAction':CCAction, 'event':event, 'EventDateLocal':EventDateLocal, 'CCAgent':CCAgent, 'CCAgentStatus':CCAgentStatus}
					r = requests.post("http://fs0.cpcr.ru/callcenter/queue.pl", timeout=1, data=payload)
				elif ccaction == 'agent-state-change':
					#print 'EVENT AGENT'
					#print 'CC-Action  '+e.getHeader("CC-Action")	
					#print 'Event-Date-Local  '+e.getHeader("Event-Date-Local")
					#print 'CC-Agent  '+e.getHeader("CC-Agent")
					#print 'CC-Agent-State  '+e.getHeader("CC-Agent-State")+'\n'
					EventDateLocal = e.getHeader("Event-Date-Local")
					CCAction = e.getHeader("CC-Action")
					CCAgent = e.getHeader("CC-Agent")
					CCAgentState = e.getHeader("CC-Agent-State")
					payload = {'event_type':'agent', 'CCAction':CCAction, 'EventDateLocal':EventDateLocal, 'CCAgent':CCAgent, 'CCAgentState':CCAgentState}
					r = requests.post("http://fs0.cpcr.ru/callcenter/queue.pl", timeout=1, data=payload)
					#print e.serialize()
				elif ccaction == 'bridge-agent-fail':
					#print 'EVENT AGENT CALLER'
					event = 'NULL'	
					if e.getHeader("CC-Hangup-Cause") == 'NO_ANSWER':
						#print '-----RINGNOANSWER------'
						event = 'RINGNOANSWER'
					if e.getHeader("CC-Hangup-Cause") == 'ORIGINATOR_CANCEL':
						#print '-----HANGUPCALLER------'	
						event = 'HANGUPCALLER'				
					if e.getHeader("CC-Hangup-Cause") == 'USER_BUSY':
						#print '-----USER_BUSY------'
						event = 'USER_BUSY'
					#if e.getHeader("CC-Hangup-Cause") == 'MANDATORY_IE_MISSING':
						#print e.serialize()
					#print 'CC-Action  '+e.getHeader("CC-Action")
					#print 'Event-Date-Local  '+e.getHeader("Event-Date-Local")
					#print 'CC-Agent-Called-Time  ', datetime.datetime.fromtimestamp(float(e.getHeader("CC-Agent-Called-Time")))
					#print 'CC-Agent-Aborted-Time  ', datetime.datetime.fromtimestamp(float(e.getHeader("CC-Agent-Aborted-Time")))
					#print 'CC-Hangup-Cause  '+e.getHeader("CC-Hangup-Cause")
					#print 'CC-Queue  '+e.getHeader("CC-Queue")
					#print 'CC-Agent  '+e.getHeader("CC-Agent")
					if e.getHeader("CC-Member-CID-Number"):
                                        	#print 'CC-Member-CID-Number  '+e.getHeader("CC-Member-CID-Number")
						CCMemberCIDNumber = e.getHeader("CC-Member-CID-Number")
                                        else:
                                        	#print 'CC-Member-CID-Number  UNDEFINED'
						CCMemberCIDNumber = 'UNDEFINED'
					#print 'CC-Member-UUID  '+e.getHeader("CC-Member-UUID")
                                        #print 'CC-Member-Session-UUID  '+e.getHeader("CC-Member-Session-UUID")+'\n'
					CoreUUID = e.getHeader("Core-UUID")
					CCAction = e.getHeader("CC-Action")
					EventDateLocal = e.getHeader("Event-Date-Local")
					CCAgentCalledTime = datetime.datetime.fromtimestamp(float(e.getHeader("CC-Agent-Called-Time")))
					CCAgentAbortedTime = datetime.datetime.fromtimestamp(float(e.getHeader("CC-Agent-Aborted-Time")))
					CCHangupCause = e.getHeader("CC-Hangup-Cause")
					CCQueue = e.getHeader("CC-Queue")
                                        CCAgent = e.getHeader("CC-Agent")
					CCMemberUUID = e.getHeader("CC-Member-UUID")
                                        CCMemberSessionUUID = e.getHeader("CC-Member-Session-UUID")
					payload = {'event_type':'agent_caller', 'event':event, 'CoreUUID':CoreUUID, 'CCAction':CCAction, 'EventDateLocal':EventDateLocal, 'CCAgentCalledTime':CCAgentCalledTime, \
					'CCAgentAbortedTime':CCAgentAbortedTime, 'CCHangupCause':CCHangupCause, 'CCQueue':CCQueue, 'CCAgent':CCAgent, 'CCMemberCIDNumber':CCMemberCIDNumber, 'CCMemberUUID':CCMemberUUID, \
					'CCMemberSessionUUID':CCMemberSessionUUID}
					r = requests.post("http://fs0.cpcr.ru/callcenter/queue.pl", timeout=1, data=payload)
					#print e.serialize()
				else:
					 print 'BBBBBBBBBBB->>'+name+'|'+subclass
					 print e.serialize()+'BBBBBBBBBBB\n'

if os.path.isfile("/var/run/cclog.pid"):
	cclogcurpid = open("/var/run/cclog.pid", "r")
	curpid = cclogcurpid.read()
	if psutil.pid_exists(int(curpid)):
    		print "cclog already running with pid", curpid
		os._exit(0)
	else:
    		print "Found old pid, Starting new process"
pid=os.fork()
if pid!=0:
	cclogpid = open("/var/run/cclog.pid", "w")
	#cclogpid.write(pid);
	print >>cclogpid, pid
	#print >>cclogpid, '\n'
	#cclogpid.write("\n");
	#print pid
	cclogpid.close()
	print 'cclog started process pid = ', pid, '\n'
	#sys.exit(0)
	os._exit(0)
cclog()



