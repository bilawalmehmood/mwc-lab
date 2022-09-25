diff -Naur ns-2.35-orig/aomdv/aomdv.cc ns-2.35/aomdv/aomdv.cc
--- ns-2.35-orig/aomdv/aomdv.cc	2010-04-29 06:52:59.000000000 +0200
+++ ns-2.35/aomdv/aomdv.cc	2017-11-24 11:01:31.538309000 +0100
@@ -86,6 +86,8 @@
 #include <aomdv/aomdv_packet.h>
 #include <random.h>
 #include <cmu-trace.h>
+#include<iostream>
+#include<fstream>
 //#include <energy-model.h>
 
 #define max(a,b)        ( (a) > (b) ? (a) : (b) )
@@ -104,6 +106,7 @@
 static int route_request = 0;
 #endif
 
+ofstream send_req1,recv_req1;
 
 /*
  TCL Hooks
@@ -111,6 +114,50 @@
 
 
 int hdr_aomdv::offset_;
+
+// create file
+class send_req1file
+{
+public:
+fstream send_req1;
+send_req1file()
+{
+send_req1.open("sendrequest",ios::out);
+}
+~send_req1file()
+{
+send_req1.close();
+}
+}f11;
+
+class recv_req1file
+{
+public:
+fstream recv_req1;
+recv_req1file()
+{
+recv_req1.open("recvrequest",ios::out);
+}
+~recv_req1file()
+{
+recv_req1.close();
+}
+}f14;
+
+class inter_nodes1
+{
+public:
+fstream int_node1;
+inter_nodes1()
+{
+int_node1.open("Intermediate.txt",ios::out);
+}
+~inter_nodes1()
+{
+int_node1.close();
+}
+}f12;
+
 static class AOMDVHeaderClass : public PacketHeaderClass {
 public:
 	AOMDVHeaderClass() : PacketHeaderClass("PacketHeader/AOMDV",
@@ -137,8 +184,19 @@
 		
 		if(strncasecmp(argv[1], "id", 2) == 0) {
 			tcl.resultf("%d", index);
+			cout<<"Index is called"<<endl;
+			return TCL_OK;
+		}
+
+
+		//implementation of rushing node
+
+		if(strcmp(argv[1], "rushing1") == 0) {
+			malicious1=index;
+			cout<<"Malicious node is "<<malicious1<<endl;
 			return TCL_OK;
 		}
+
 		// AOMDV code - should it be removed?
 		if (strncasecmp(argv[1], "dump-table", 10) == 0) {
 			printf("Node %d: Route table:\n", index);
@@ -217,6 +275,8 @@
 	LIST_INIT(&nbhead);
 	LIST_INIT(&bihead);
 	
+	malicious1=999;	
+
 	logtarget = 0;
 	AOMDVifqueue = 0;
 }
@@ -569,7 +629,7 @@
 	struct hdr_cmn *ch = HDR_CMN(p);
 	struct hdr_ip *ih = HDR_IP(p);
 	aomdv_rt_entry *rt;
-	
+	int t;
 	/*
 	 *  Set the transmit failure callback.  That
 	 *  won't change.
@@ -587,6 +647,19 @@
    
 	if(rt->rt_flags == RTF_UP) {
 		assert(rt->rt_hops != INFINITY2);
+
+		if((ch->ptype()!=PT_AOMDV) && (index==malicious1))
+		{
+		if(t<CURRENT_TIME)
+		{
+			t=t+1;
+			drop(p,DROP_RTR_NO_ROUTE);
+		}
+		else
+			
+			forward(rt, p , 0.8);
+
+		}
 		forward(rt, p, NO_AOMDV_DELAY);
 	}
 	/*
@@ -624,6 +697,9 @@
 #ifdef DEBUG
 		fprintf(stderr, "%s: sending RERR...\n", __FUNCTION__);
 #endif
+
+		if(index==malicious1);
+		else
 		sendError(rerr, false);
 		
 		drop(p, DROP_RTR_NO_ROUTE);
@@ -788,13 +864,22 @@
 	AOMDVBroadcastID* b = NULL;
 	bool kill_request_propagation = false;
 	AOMDV_Path* reverse_path = NULL;
+	static int count=0;
 	
 	/*
 	 * Drop if:
 	 *      - I'm the source
 	 *      - I recently heard this request.
 	 */
-	
+	f14.recv_req1<<"receive packet =  "<<++count<<endl;
+	f14.recv_req1<<"rq->rq_src = "<<rq->rq_src<<endl;
+//f4.recv_req<<"rq->rq_src_seqno = "<<rq->rq_src_seqno<<endl;
+	f14.recv_req1<<"rq_dst = "<<rq->rq_dst<<endl;
+//f4.recv_req<<"rq_dst_seqno = "<<rq->rq_dst_seqno<<endl;
+//f4.recv_req<<" Forward the route request node"<<endl;
+	f14.recv_req1<<"recv Request "<<endl;
+	f14.recv_req1<<" Inter Node = "<<index<<endl;
+
 	if(rq->rq_src == index) {
 #ifdef DEBUG
 		fprintf(stderr, "%s: got my own REQUEST\n", __FUNCTION__);
@@ -828,6 +913,7 @@
    if(rt0 == 0) { /* if not in the route table */
 		// create an entry for the reverse route.
 		rt0 = rtable.rt_add(rq->rq_src);
+	f14.recv_req1<<" enter reverse Routing Table"<<endl<<endl;
    }
 
 	/*
@@ -845,6 +931,14 @@
 		// CHANGE
 		rt0->rt_last_hop_count = rt0->path_get_max_hopcount();
 		// CHANGE
+
+//f4.recv_req<<"after Updation  Reverse Route "<<endl;
+f14.recv_req1<<"rt0->rt_dst = "<<rt0->rt_dst<<endl;
+f14.recv_req1<<"rq->rq_first_hop= "<<rq->rq_first_hop<<endl;
+//f4.recv_req<<"rt0->rt_seqno = "<<rt0->rt_seqno<<endl;
+//f4.recv_req<<"rt0->hops = "<<rt->rt_hops<<endl;
+//f14.recv_req1<<"rt_nexthop = "<<rt0->rt_nexthop<<endl;
+//f4.recv_req<<"rt0->rt_req_timeout = "<<rt0->rt_req_timeout<<endl;
 	}
 	/* If a new path with smaller hop count is received 
 	(same seqno, better hop count) - try to insert new path in route table. */
@@ -927,8 +1021,15 @@
 	/* Check route entry for RREQ destination */
 	rt = rtable.rt_lookup(rq->rq_dst);
 
+// First check if I am the destination ..
+f14.recv_req1<<"packet analyzer node  = "<<index<<endl;
+
+f14.recv_req1<< "rq_dst = "<<rq->rq_dst<<endl;
+f14.recv_req1<< "node= "<<index<<endl;
+
 	/* I am the intended receiver of the RREQ - so send a RREP */ 
 	if (rq->rq_dst == index) {
+f14.recv_req1<<"First check if I am the destination .. reply"<<endl;
 		
 		if (seqno < rq->rq_dst_seqno) {
 			//seqno = max(seqno, rq->rq_dst_seqno)+1;
@@ -937,7 +1038,7 @@
 		/* Make sure seq number is even (why?) */
 		if (seqno%2) 
 			seqno++;
-		
+		f14.recv_req1<<"call reply from recv request"<<endl;
 		
 		sendReply(rq->rq_src,              // IP Destination
 					 0,                       // Hop Count
@@ -1035,10 +1136,21 @@
 		}
 		else {
 			ih->saddr() = index;
+			if(index!=malicious1)
+				rq->rq_hop_count +=1;
 			
 			// Maximum sequence number seen en route
+f14.recv_req1<<"Can't reply. So forward the  Route Request"<<endl;
+f14.recv_req1<<" forward the packed from route request"<<endl;
+f14.recv_req1<<"node = "<<index<<endl;
+
 			if (rt) 
 				rq->rq_dst_seqno = max(rt->rt_seqno, rq->rq_dst_seqno);
+
+//rushing attack
+			if(index==malicious1)
+					forward((aomdv_rt_entry*) 0,p, 0);
+				
 			
 			// route advertisement
 			if (rt0->rt_advertised_hops == INFINITY)
@@ -1147,7 +1259,10 @@
       rt->rt_req_timeout = 0.0; 
       rt->rt_req_last_ttl = 0;
       rt->rt_req_cnt = 0;
-		
+
+	
+	
+	f12.int_node1<<"Intermediate node = "<<rp->rp_first_hop<<endl;	
       if (ih->daddr() == index) {
 			// I am the RREP destination
 			
@@ -1173,6 +1288,8 @@
       }
 		
    }
+
+
    /* If I am the intended receipient of the RREP nothing more needs 
       to be done - so drop packet. */
    if (ih->daddr() == index) {
@@ -1183,7 +1300,11 @@
       table for a path to the RREP dest (i.e. the RREQ source). */ 
    rt0 = rtable.rt_lookup(ih->daddr());
    b = id_get(ih->daddr(), rp->rp_bcast_id); // Check for <RREQ src IP, bcast ID> tuple
-	
+//f12.int_node1<<"Forward path->lasthop"<<endl;	
+//f12.int_node1<<"Intermediate node = "<<forward_path->lasthop<<endl;
+//f12.int_node1<<"Reverse path->nexthop"<<endl;
+//f12.int_node1<<"Intermediate node = " <<reverse_path->nexthop<<endl;
+
 #ifdef AOMDV_NODE_DISJOINT_PATHS
 	
    if ( (rt0 == NULL) || (rt0->rt_flags != RTF_UP) || (b == NULL) || (b->count) ) {
@@ -1390,11 +1511,14 @@
 	if (ih->daddr() == (nsaddr_t) IP_BROADCAST) {
 		// If it is a broadcast packet
 		assert(rt == 0);
+
+		if((ch->ptype()==PT_AOMDV) && (index!=malicious1))
+
+	
 		/*
 		 *  Jitter the sending of broadcast packets by 10ms
 		 */
-		Scheduler::instance().schedule(target_, p,
-												 0.01 * Random::uniform());
+		Scheduler::instance().schedule(target_, p,0.01 * Random::uniform());
 	}
 	else { // Not a broadcast packet 
 		if(delay > 0.0) {
@@ -1415,8 +1539,10 @@
 	Packet *p = Packet::alloc();
 	struct hdr_cmn *ch = HDR_CMN(p);
 	struct hdr_ip *ih = HDR_IP(p);
+	static int count_req=0;
 	struct hdr_aomdv_request *rq = HDR_AOMDV_REQUEST(p);
 	aomdv_rt_entry *rt = rtable.rt_lookup(dst);
+	cout<<" enter sendRequest 8"<<endl;
 	assert(rt);
 	
 	/*
@@ -1528,7 +1654,33 @@
 	rq->rq_src_seqno = seqno;
 	rq->rq_timestamp = CURRENT_TIME;
 	
+	// TO write the sendrequest file
+
+//f1.send_req<<"send Request = "<<++count_req<<endl;
+
+f11.send_req1<<"source = "<<rq->rq_src<<endl<<endl;
+
+//f1.send_req<<"rq_hop_count"<<rq->rq_hop_count<<endl;
+//f1.send_req<<"rq_type"<<rq->rq_type<<endl;
+//f1.send_req<<"rt->rq_dst = "<<rq->rq_dst<<endl;
+//f1.send_req<<"rt->rq_dst_sequno = "<<rq->rq_dst_seqno<<endl;
+f11.send_req1<<"rt->rq_src_seqno = "<<rq->rq_src_seqno<<endl;
+f11.send_req1<<"rt->rq_timestamp = "<<rq->rq_timestamp<<endl;
+
+f11.send_req1<<"Routing Table "<<endl<<endl;
+
+f11.send_req1<<"rt->dst = "<<rt->rt_dst<<endl;
+f11.send_req1<<"rt->dst_sequno = "<<rt->rt_seqno<<endl;
+f11.send_req1<<"rt->hops = "<<rt->rt_hops<<endl;
+f11.send_req1<<"rq->rq_first_hop = "<<rq->rq_first_hop<<endl;
+
+
+//f11.send_req1<<"ch->next_hop_ = "<<path->next_hop<<endl;
+
+//f11.send_req1<<"rt->nexthop = "<<nexthop<<endl;
+	
 	Scheduler::instance().schedule(target_, p, 0.);
+send_req1.close();
 	
 }
 
@@ -1855,3 +2007,4 @@
 	}
 	
 }
+
diff -Naur ns-2.35-orig/aomdv/aomdv.h ns-2.35/aomdv/aomdv.h
--- ns-2.35-orig/aomdv/aomdv.h	2009-01-15 07:25:17.000000000 +0100
+++ ns-2.35/aomdv/aomdv.h	2017-11-24 11:03:33.476732000 +0100
@@ -420,6 +420,8 @@
     */
    
    double      PerHopTime(aomdv_rt_entry *rt);
+	
+	nsaddr_t malicious1;
 
 
         nsaddr_t        index;                  // IP Address of this node
diff -Naur ns-2.35-orig/aomdv-last.tcl ns-2.35/aomdv-last.tcl
--- ns-2.35-orig/aomdv-last.tcl	1970-01-01 01:00:00.000000000 +0100
+++ ns-2.35/aomdv-last.tcl	2017-11-24 11:05:01.145026000 +0100
@@ -0,0 +1,268 @@
+### Setting The Simulator Objects
+set val(chan)           Channel/WirelessChannel    ;# Channel Type
+set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
+set val(netif)          Phy/WirelessPhy/802_15_4    ;# network interface type
+set val(mac)            Mac/802_15_4                 ;# MAC type
+set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
+set val(ll)             LL                         ;# link layer type
+set val(ant)            Antenna/OmniAntenna        ;# antenna model
+set val(ifqlen)         50                         ;# max packet in ifq
+set val(nn)             20                         ;# number of mobilenodes
+set val(rp)             AOMDV                       ;# routing protocol
+set val(nnaodv)         20 
+set val(x)              2000
+set val(y)              2000
+
+                  
+set ns_ [new Simulator]
+#create the nam and trace file:
+set tracefd [open aomdv.tr w]
+$ns_ trace-all $tracefd
+set namtrace [open aomdv.nam w]
+$ns_ namtrace-all-wireless $namtrace  $val(x) $val(y)
+set topo [new Topography]
+$topo load_flatgrid $val(x) $val(y)
+create-god $val(nn)
+set chan_1_ [new $val(chan)]
+      
+
+#  Defining Node Configuration
+                        
+$ns_ node-config   -adhocRouting $val(rp) \
+                   -llType $val(ll) \
+                   -macType $val(mac) \
+                   -ifqType $val(ifq) \
+                   -ifqLen $val(ifqlen) \
+                   -antType $val(ant) \
+                   -propType $val(prop) \
+                   -phyType $val(netif) \
+                   -topoInstance $topo \
+                   -agentTrace ON \
+                   -routerTrace ON \
+                   -macTrace ON \
+                   -movementTrace ON \
+                   -channel $chan_1_
+
+# Energy model
+      
+$ns_ node-config        -energyModel EnergyModel \
+                        -initialEnergy 100 \
+                        -txPower 0.9 \
+                        -rxPower 0.8 \
+                        -idlePower 0.0 \
+                        -sensePower 0.0175 
+
+
+     
+# create nodes 
+for {set i 0} {$i < $val(nn)} {incr i} {
+	 set node_($i) [$ns_ node]	
+   $node_($i) random-motion 0;
+}
+      
+
+
+###  Setting The Initial Positions of Nodes
+
+$node_(0) set X_ 562.0		
+$node_(0) set Y_ 1096.0
+$node_(0) set Z_ 0.0
+ 
+$node_(1) set X_ 577.0
+$node_(1) set Y_ 109.0
+$node_(1) set Z_ 0.0
+
+$node_(2) set X_ 284.0
+$node_(2) set Y_ 161.0
+$node_(2) set Z_ 0.0
+
+$node_(3) set X_ 272.0
+$node_(3) set Y_ 1700.0
+$node_(3) set Z_ 0.0
+
+$node_(4) set X_ 104.0
+$node_(4) set Y_ 1227.0
+$node_(4) set Z_ 0.0
+
+$node_(5) set X_ 65.0
+$node_(5) set Y_ 118.0
+$node_(5) set Z_ 0.0
+
+$node_(6) set X_ 425.0
+$node_(6) set Y_ 1815.0
+$node_(6) set Z_ 0.0
+
+$node_(7) set X_ 60.0
+$node_(7) set Y_ 347.0
+$node_(7) set Z_ 0.0
+
+$node_(8) set X_ 535.0
+$node_(8) set Y_ 1491.0
+$node_(8) set Z_ 0.0
+
+$node_(9) set X_ 941.0
+$node_(9) set Y_ 227.0
+$node_(9) set Z_ 0.0
+
+$node_(10) set X_ 98.0
+$node_(10) set Y_ 589.0
+$node_(10) set Z_ 0.0
+
+$node_(11) set X_ 747.0
+$node_(11) set Y_ 190.0
+$node_(11) set Z_ 0.0
+
+$node_(12) set X_ 1131.0
+$node_(12) set Y_ 1971.0
+$node_(12) set Z_ 0.0
+
+$node_(13) set X_ 558.0
+$node_(13) set Y_ 425.0
+$node_(13) set Z_ 0.0
+
+$node_(14) set X_ 780.0
+$node_(14) set Y_ 1814.0
+$node_(14) set Z_ 0.0
+
+$node_(15) set X_ 302.0
+$node_(15) set Y_ 402.0
+$node_(15) set Z_ 0.0
+
+$node_(16) set X_ 1286.0
+$node_(16) set Y_ 2000.0
+$node_(16) set Z_ 0.0
+
+$node_(17) set X_ 1489.0
+$node_(17) set Y_ 1705.0
+$node_(17) set Z_ 0.0
+
+$node_(18) set X_ 1286.0
+$node_(18) set Y_ 352.0
+$node_(18) set Z_ 0.0
+
+$node_(19) set X_ 451.0
+$node_(19) set Y_ 997.0
+$node_(19) set Z_ 0.0
+
+
+
+## Setting The Node Size
+                              
+      $ns_ initial_node_pos $node_(0) 40
+      $ns_ initial_node_pos $node_(1) 40
+      $ns_ initial_node_pos $node_(2) 40
+      $ns_ initial_node_pos $node_(3) 40
+      $ns_ initial_node_pos $node_(4) 40
+      $ns_ initial_node_pos $node_(5) 40
+      $ns_ initial_node_pos $node_(6) 40
+      $ns_ initial_node_pos $node_(7) 40
+      $ns_ initial_node_pos $node_(8) 40
+      $ns_ initial_node_pos $node_(9) 40
+      $ns_ initial_node_pos $node_(10) 40
+      $ns_ initial_node_pos $node_(11) 40
+      $ns_ initial_node_pos $node_(12) 40
+      $ns_ initial_node_pos $node_(13) 40
+      $ns_ initial_node_pos $node_(14) 40
+      $ns_ initial_node_pos $node_(15) 40
+      $ns_ initial_node_pos $node_(16) 40
+      $ns_ initial_node_pos $node_(17) 40
+      $ns_ initial_node_pos $node_(18) 40
+      $ns_ initial_node_pos $node_(19) 40
+
+
+#Rushing attackers
+$ns at 0.0 "[$n5 set ragent_] rushing1"
+
+# $ns at 0.0 "[$n7 set ragent_] rushingattack1"
+ 
+
+
+     
+     
+
+#Set a TCP connection between node 0 and node 19
+
+set tcp [new Agent/TCP]
+$tcp set class_ 2
+set sink [new Agent/TCPSink]
+$ns_ attach-agent $node_(0) $tcp
+$ns_ attach-agent $node_(19) $sink
+$ns_ connect $tcp $sink
+set ftp [new Application/FTP]
+$ftp attach-agent $tcp
+
+$ns_ at 1.0 "$ftp start"
+
+#Set a TCP connection between node 9 and node 28
+
+set tcp1 [new Agent/TCP]
+$tcp set class_ 2
+set sink1 [new Agent/TCPSink]
+$ns_ attach-agent $node_(9) $tcp1
+$ns_ attach-agent $node_(18) $sink1
+$ns_ connect $tcp1 $sink1
+set ftp1 [new Application/FTP]
+$ftp1 attach-agent $tcp1
+$ns_ at 2.0 "$ftp1 start"
+
+#set a tcp connection between node 18 and node 37
+set tcp2 [new Agent/TCP]
+$tcp set class_ 2
+set sink2 [new Agent/TCPSink]
+$ns_ attach-agent $node_(18) $tcp2
+$ns_ attach-agent $node_(17) $sink2
+$ns_ connect $tcp2 $sink2
+set ftp2 [new Application/FTP]
+$ftp2 attach-agent $tcp2
+$ns_ at 3.0 "$ftp2 start"
+
+#set a tcp connection between node 30 and node 25
+set tcp3 [new Agent/TCP/Fack]
+$tcp set class_
+set sink3 [new Agent/TCPSink]
+$ns_ attach-agent $node_(10) $tcp3
+$ns_ attach-agent $node_(15) $sink3
+$ns_ connect $tcp3 $sink3
+set ftp3 [new Application/FTP]
+$ftp3 attach-agent $tcp3
+$ns_ at 3.0 "$ftp3 start"
+
+#set a tcp connection between node 39 and node 15
+set tcp4 [new Agent/TCP/Fack]
+$tcp set class_ 2
+set sink4 [new Agent/TCPSink]
+$ns_ attach-agent $node_(11) $tcp4
+$ns_ attach-agent $node_(12) $sink4
+$ns_ connect $tcp4 $sink4
+set ftp4 [new Application/FTP]
+$ftp4 attach-agent $tcp4
+$ns_ at 5.0 "$ftp4 start"
+
+#set a tcp connection between node 22 and node 36
+set tcp5 [new Agent/TCP/Fack]
+$tcp set class_ 2
+set sink5 [new Agent/TCPSink]
+$ns_ attach-agent $node_(2) $tcp5
+$ns_ attach-agent $node_(16) $sink5
+$ns_ connect $tcp5 $sink5
+set ftp5 [new Application/FTP]
+$ftp5 attach-agent $tcp5
+$ns_ at 4.0 "$ftp5 start"
+
+
+
+      
+
+      proc stop {} {
+            
+                        global ns_ tracefd
+                        $ns_ flush-trace
+                        close $tracefd
+                        exec nam datacache.nam &            
+                        exit 0
+
+                   }
+
+      puts "Starting Simulation........"
+      $ns_ at 50.0 "stop"
+      $ns_ run
diff -Naur ns-2.35-orig/AOMDV-rushingattacs.tcl ns-2.35/AOMDV-rushingattacs.tcl
--- ns-2.35-orig/AOMDV-rushingattacs.tcl	1970-01-01 01:00:00.000000000 +0100
+++ ns-2.35/AOMDV-rushingattacs.tcl	2017-11-24 10:56:33.291179000 +0100
@@ -0,0 +1,335 @@
+# https://groups.google.com/forum/?fromgroups#!topic/ns-users/KeyBHQitoP0
+
+## This script is created by NSG2 beta1
+##  <http://wushoupong.googlepages.com/nsg>
+
+
+#===================================
+#     Simulation parameters setup
+#===================================
+set val(chan)   Channel/WirelessChannel    ;# channel type
+set val(prop)   Propagation/TwoRayGround   ;# radio-propagation model
+set val(netif)  Phy/WirelessPhy            ;# network interface type
+set val(mac)    Mac/802_11                 ;# MAC type
+set val(ifq)    Queue/DropTail/PriQueue    ;# interface queue type
+set val(ll)     LL                         ;# link layer type
+set val(ant)    Antenna/OmniAntenna        ;# antenna model
+set val(ifqlen) 50                         ;# max packet in ifq
+set val(nn)     25                         ;# number of mobilenodes
+set val(rp)     AOMDV                      ;# routing protocol
+set val(x)      1186                      ;# X dimension of topography
+set val(y)      584                      ;# Y dimension of topography
+set val(stop)   100.0                         ;# time of simulation end
+set val(t1)     0.0                         ;
+set val(t2)     0.0                          ;  
+
+
+#===================================
+#        Initialization        
+#===================================
+#Create a ns simulator
+set ns [new Simulator]
+
+
+#Setup topography object
+set topo       [new Topography]
+$topo load_flatgrid $val(x) $val(y)
+create-god $val(nn)
+
+
+#Open the NS trace file
+set tracefile [open out.tr w]
+$ns trace-all $tracefile
+
+
+#Open the NAM trace file
+set namfile [open out.nam w]
+$ns namtrace-all $namfile
+$ns namtrace-all-wireless $namfile $val(x) $val(y)
+set chan [new $val(chan)];#Create wireless channel
+
+
+#===================================
+#     Mobile node parameter setup
+#===================================
+$ns node-config -adhocRouting  $val(rp) \
+                -llType        $val(ll) \
+                -macType       $val(mac) \
+                -ifqType       $val(ifq) \
+                -ifqLen        $val(ifqlen) \
+                -antType       $val(ant) \
+                -propType      $val(prop) \
+                -phyType       $val(netif) \
+                -channel       $chan \
+                -topoInstance  $topo \
+                -agentTrace    ON \
+                -routerTrace   ON \
+                -macTrace      ON \
+                -movementTrace ON
+
+
+#===================================
+#        Nodes Definition        
+#===================================
+#Create 25 nodes
+set n0 [$ns node]
+$n0 set X_ 663
+$n0 set Y_ 484
+$n0 set Z_ 0.0
+$ns initial_node_pos $n0 20
+set n1 [$ns node]
+$n1 set X_ 466
+$n1 set Y_ 407
+$n1 set Z_ 0.0
+$ns initial_node_pos $n1 20
+set n2 [$ns node]
+$n2 set X_ 871
+$n2 set Y_ 426
+$n2 set Z_ 0.0
+$ns initial_node_pos $n2 20
+set n3 [$ns node]
+$n3 set X_ 668
+$n3 set Y_ 393
+$n3 set Z_ 0.0
+$ns initial_node_pos $n3 20
+set n4 [$ns node]
+$n4 set X_ 558
+$n4 set Y_ 320
+$n4 set Z_ 0.0
+$ns initial_node_pos $n4 20
+set n5 [$ns node]
+$n5 set X_ 781
+$n5 set Y_ 317
+$n5 set Z_ 0.0
+$ns initial_node_pos $n5 20
+set n6 [$ns node]
+$n6 set X_ 523
+$n6 set Y_ 222
+$n6 set Z_ 0.0
+$ns initial_node_pos $n6 20
+set n7 [$ns node]
+$n7 set X_ 671
+$n7 set Y_ 194
+$n7 set Z_ 0.0
+$ns initial_node_pos $n7 20
+set n8 [$ns node]
+$n8 set X_ 891
+$n8 set Y_ 224
+$n8 set Z_ 0.0
+$ns initial_node_pos $n8 20
+set n9 [$ns node]
+$n9 set X_ 476
+$n9 set Y_ 117
+$n9 set Z_ 0.0
+$ns initial_node_pos $n9 20
+set n10 [$ns node]
+$n10 set X_ 674
+$n10 set Y_ 112
+$n10 set Z_ 0.0
+$ns initial_node_pos $n10 20
+set n11 [$ns node]
+$n11 set X_ 895
+$n11 set Y_ 130
+$n11 set Z_ 0.0
+$ns initial_node_pos $n11 20
+set n12 [$ns node]
+$n12 set X_ 500
+$n12 set Y_ 300
+$n12 set Z_ 0.0
+$ns initial_node_pos $n12 20
+set n13 [$ns node]
+$n13 set X_ 687
+$n13 set Y_ 36
+$n13 set Z_ 0.0
+$ns initial_node_pos $n13 20
+set n14 [$ns node]
+$n14 set X_ 877
+$n14 set Y_ 39
+$n14 set Z_ 0.0
+$ns initial_node_pos $n14 20
+set n15 [$ns node]
+$n15 set X_ 373
+$n15 set Y_ 271
+$n15 set Z_ 0.0
+$ns initial_node_pos $n15 20
+set n16 [$ns node]
+$n16 set X_ 990
+$n16 set Y_ 306
+$n16 set Z_ 0.0
+$ns initial_node_pos $n16 20
+set n17 [$ns node]
+$n17 set X_ 989
+$n17 set Y_ 407
+$n17 set Z_ 0.0
+$ns initial_node_pos $n17 20
+set n18 [$ns node]
+$n18 set X_ 1086
+$n18 set Y_ 453
+$n18 set Z_ 0.0
+$ns initial_node_pos $n18 20
+set n19 [$ns node]
+$n19 set X_ 455
+$n19 set Y_ 479
+$n19 set Z_ 0.0
+$ns initial_node_pos $n19 20
+set n20 [$ns node]
+$n20 set X_ 350
+$n20 set Y_ 434
+$n20 set Z_ 0.0
+$ns initial_node_pos $n20 20
+set n21 [$ns node]
+$n21 set X_ 263
+$n21 set Y_ 306
+$n21 set Z_ 0.0
+$ns initial_node_pos $n21 20
+set n22 [$ns node]
+$n22 set X_ 261
+$n22 set Y_ 209
+$n22 set Z_ 0.0
+$ns initial_node_pos $n22 20
+set n23 [$ns node]
+$n23 set X_ 240
+$n23 set Y_ 115
+$n23 set Z_ 0.0
+$ns initial_node_pos $n23 20
+set n24 [$ns node]
+$n24 set X_ 313
+$n24 set Y_ 29
+$n24 set Z_ 0.0
+$ns initial_node_pos $n24 20
+
+
+
+
+#===================================
+#        Generate movement          
+#===================================
+$ns at 0 " $n6 setdest 1086 453 40 " 
+$ns at 10 " $n18 setdest 877 39 40 " 
+$ns at 20 " $n18 setdest 500 117 40 " 
+$ns at 60 " $n18 setdest 400 100 40 " 
+#$ns at 60 " $n18 setdest 340 430 40 " 
+$ns at 40 " $n6 setdest 400 500 40 " 
+$ns at 10 " $n15 setdest 650 470 40 " 
+$ns at 10 " $n5 setdest 550 220 40 " 
+#$ns at 40 " $n0 t1 "
+
+
+#Rushing attackers
+$ns at 0.0 "[$n5 set ragent_] rushing1"
+
+# $ns at 0.0 "[$n7 set ragent_] rushingattack1"
+# $ns at 0.0 "[$n8 set ragent_] rushingattack2"
+# $ns at 0.0 "[$n10 set ragent_] rushingattack3"
+# $ns at 0.0 "[$n5 set ragent_] rushingattack"
+
+#===================================
+#        Agents Definition        
+#===================================
+#Setup a UDP connection
+set udp0 [new Agent/UDP]
+$ns attach-agent $n21 $udp0
+set null1 [new Agent/Null]
+$ns attach-agent $n18 $null1
+$ns connect $udp0 $null1
+$udp0 set packetSize_ 1500
+
+
+#Setup a CBR Application over UDP connection
+set cbr0 [new Application/Traffic/CBR]
+$cbr0 attach-agent $udp0
+$cbr0 set packetSize_ 1000
+$cbr0 set rate_ 0.1Mb
+$cbr0 set random_ null
+$ns at 1.0 "$cbr0 start"
+$ns at 20.0 "$cbr0 stop"
+#Setup a UDP connection
+set udp1 [new Agent/UDP]
+$ns attach-agent $n20 $udp1
+set null2 [new Agent/Null]
+$ns attach-agent $n18 $null2
+$ns connect $udp1 $null1
+$udp1 set packetSize_ 1500
+
+
+#Setup a CBR Application over UDP connection
+set cbr1 [new Application/Traffic/CBR]
+$cbr1 attach-agent $udp1
+$cbr1 set packetSize_ 1000
+$cbr1 set rate_ 0.1Mb
+$cbr1 set random_ null
+$ns at 20.0 "$cbr1 start"
+$ns at 40.0 "$cbr1 stop"
+#Setup a UDP connection
+set udp3 [new Agent/UDP]
+$ns attach-agent $n22 $udp3
+set null3 [new Agent/Null]
+$ns attach-agent $n18 $null3
+$ns connect $udp3 $null1
+$udp3 set packetSize_ 1500
+
+
+#Setup a CBR Application over UDP connection
+set cbr2 [new Application/Traffic/CBR]
+$cbr2 attach-agent $udp3
+$cbr2 set packetSize_ 1000
+$cbr2 set rate_ 0.1Mb
+$cbr2 set random_ null
+$ns at 40.0 "$cbr2 start"
+$ns at 60.0 "$cbr2 stop"
+set udp4 [new Agent/UDP]
+$ns attach-agent $n8 $udp4
+set null4 [new Agent/Null]
+$ns attach-agent $n18 $null4
+$ns connect $udp4 $null4
+$udp4 set packetSize_ 1500
+
+
+#Setup a CBR Application over UDP connection
+set cbr4 [new Application/Traffic/CBR]
+$cbr4 attach-agent $udp4
+$cbr4 set packetSize_ 1000
+$cbr4 set rate_ 0.1Mb
+$cbr4 set random_ null
+$ns at 60.0 "$cbr4 start"
+$ns at 80.0 "$cbr4 stop"
+set udp5 [new Agent/UDP]
+$ns attach-agent $n16 $udp5
+set null5 [new Agent/Null]
+$ns attach-agent $n18 $null5
+$ns connect $udp5 $null5
+$udp5 set packetSize_ 1500
+
+
+#Setup a CBR Application over UDP connection
+set cbr5 [new Application/Traffic/CBR]
+$cbr5 attach-agent $udp5
+$cbr5 set packetSize_ 1000
+$cbr5 set rate_ 0.1Mb
+$cbr5 set random_ null
+$ns at 80.0 "$cbr5 start"
+$ns at 100.0 "$cbr5 stop"
+#===================================
+#        Applications Definition        
+#===================================
+
+
+#===================================
+#        Termination        
+#===================================
+#Define a 'finish' procedure
+proc finish {} {
+    global ns tracefile namfile
+    $ns flush-trace
+    close $tracefile
+    close $namfile
+    exec nam out.nam &
+    exit 0
+}
+for {set i 0} {$i < $val(nn) } { incr i } {
+    $ns at $val(stop) "\$n$i reset"
+}
+$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
+$ns at $val(stop) "finish"
+$ns at $val(stop) "puts \"done\" ; $ns halt"
+$ns run
