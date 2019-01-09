
#check input parameters
# if {$argc != 4} {
#     puts ""
#     puts "Wrong Number of Arguments! No arguments in this topology"
#     puts "Syntax: ns test-be.tcl seed diuc dl/ul distance"
#     puts ""
#     exit (1)
# }
#============================================ 802.16 ================================
# Network Parameters
set cbr_type CBR
set cbr_size [lindex $argv 5]; #4,8,16,32,64
set cbr_rate 11.0Mb
set cbr_pckt_per_sec [lindex $argv 6]
set cbr_interval [expr 1.0/$cbr_pckt_per_sec] ;# 1 for 1 packets per second and 0.1 for 10 packets per second
set num_row [lindex $argv 0] ;#number of row
set num_col [lindex $argv 0] ;#number of column
set x_dim [lindex $argv 4] ;# 150
set y_dim [lindex $argv 4] ;# 150
set time_duration 50 ; #[lindex $argv 5] ;#50
set start_time 25 ;# 100
set parallel_start_gap 0.0
set cross_start_gap 0.0

#============= ENERGY PARAMETERS =====================
set val(energymodel_11)    EnergyModel     ;
set val(initialenergy_11)  1000            ;# Initial energy in Joules

set val(idlepower_11) 869.4e-3			;#LEAP (802.11g) 
set val(rxpower_11) 1560.6e-3			;#LEAP (802.11g)
set val(txpower_11) 1679.4e-3			;#LEAP (802.11g)
set val(sleeppower_11) 37.8e-3			;#LEAP (802.11g)
set val(transitionpower_11) 176.695e-3		;#LEAP (802.11g)
set val(transitiontime_11) 2.36			;#LEAP (802.11g)

set num_random_flow [lindex $argv 2]
set num_parallel_flow [lindex $argv 2]
set num_cross_flow [lindex $argv 2]
set speed_node [lindex $argv 3]

if { $num_random_flow > $num_col} {
	set num_random_flow  [expr $num_col-1]
	set num_cross_flow  [expr $num_col-1]
	set num_parallel_flow  [expr $num_col-1]
}

set grid [lindex $argv 1]
set extra_time 10 ;#10

set tcp_src Agent/TCP/Vegas
set tcp_sink Agent/TCPSink

#==========================================================================

set val(chan) Channel/WirelessChannel ;# channel type
set val(prop) Propagation/OFDMA ;# radio-propagation model
set val(netif) Phy/WirelessPhy/OFDMA ;# network interface type
set val(mac) Mac/802_16/SS ;# MAC type -> BS for base station
set val(ifq) Queue/DropTail/PriQueue ;# interface queue type
set val(ll) LL ;# link layer type
set val(ant) Antenna/OmniAntenna ;# antenna model
set val(ifqlen) 50 ;# 50  max packet in ifq
set val(rp) AODV ; # NOAH [lindex $argv 4] ;# routing protocol

#=======================================================
#define debug values
Mac/802_16 set debug_           1
Mac/802_16 set rtg_             20
Mac/802_16 set ttg_             20
Mac/802_16 set frame_duration_  0.005
Mac/802_16 set ITU_PDP_         2
Mac/802_16/BS set dlratio_      .66
Mac/802_16/SS set dlratio_      .66
Mac/802_16 set fbandwidth_      10e+6
Mac/802_16 set disable_interference_ 0


#for ARQ parameters
Mac/802_16 set arq_block_size_ 256
Mac/802_16 set data_loss_rate_ 0.5
Mac/802_16 set arqfb_in_dl_data_  1
Mac/802_16 set arqfb_in_ul_data_  1
Mac/802_16 set queue_length_      100000     ;# maximum number of packets

Phy/WirelessPhy/OFDMA set g_ 0.25

#define coverage area for base station
#Phy/WirelessPhy set Pt_ 20 
Phy/WirelessPhy set Pt_ 0.2 
Phy/WirelessPhy set RXThresh_ 1.90546e-16
Phy/WirelessPhy set CSThresh_ [expr 0.9*[Phy/WirelessPhy set RXThresh_]]
Phy/WirelessPhy set OFDMA_ 1 

#==============================================================
# set global variables
#set nb_mn [lindex $argv 0]				;# max number of mobile node
# set nb_mn 1


# set seed [lindex $argv 0]		;# seed
# set diuc [lindex $argv 1]
# set direction [lindex $argv 2]
# set distance [lindex $argv 3]


# global defaultRNG
# $defaultRNG seed $seed

# set packet_size 1500			;# packet size in bytes at CBR applications 
# set output_dir ~/Desktop/Networking_CSE322/NS2/Offline/1505114
# set gap_size 0.05 				;#compute gap size between packets
# puts "gap size=$gap_size"
# set traffic_start 10
# set traffic_stop  20
# set simulation_stop 21



# set opt(x)		11000			   ;# X dimension of the topography
# set opt(y)		11000			   ;# Y dimension of the topography

# #defines function for flushing and closing files
# proc finish {} {
#     global ns tf output_dir nb_mn
#     $ns flush-trace
#     close $tf
#     exit 0
# }

#============================================================
set tr trace.tr
set topo_file topo_802.11.txt
# set conges_data [open conges_data.txt w]


# Initialize ns
set ns [new Simulator]

set tracefd [open $tr w]
$ns trace-all $tracefd


set topofile [open $topo_file "w"]

# set up topography object
set topo       [new Topography]
$topo load_flatgrid $x_dim $y_dim


create-god [expr $num_row * $num_col ] ;# general operations director

$ns node-config -adhocRouting $val(rp) -llType $val(ll) \
     -macType $val(mac)  -ifqType $val(ifq) \
     -ifqLen $val(ifqlen) -antType $val(ant) \
     -propType $val(prop) -phyType $val(netif) \
     -channel  [new $val(chan)] -topoInstance $topo \
     -agentTrace ON -routerTrace OFF\
     -macTrace ON \
     -movementTrace OFF \
			 -energyModel $val(energymodel_11) \
			 -idlePower $val(idlepower_11) \
			 -rxPower $val(rxpower_11) \
			 -txPower $val(txpower_11) \
          		 -sleepPower $val(sleeppower_11) \
          		 -transitionPower $val(transitionpower_11) \
			 -transitionTime $val(transitiontime_11) \
			 -initialEnergy $val(initialenergy_11)

puts "start node creation"
for {set i 0} {$i < [expr $num_row*$num_col]} {incr i} {
	set node_($i) [$ns node]
#	$node_($i) random-motion 0
    set st_ime [expr int([expr $start_time+$time_duration]*rand())]

	$ns at $st_ime "$node_($i) setdest [expr $x_dim*rand()] [expr $y_dim*rand()] $speed_node"
}


# position of nodes
set x_start [expr $x_dim/($num_col*2)];
set y_start [expr $y_dim/($num_row*2)];
set i 0;
while {$i < $num_row } {
#in same column
    for {set j 0} {$j < $num_col } {incr j} {
#in same row
	set m [expr $i*$num_col+$j];
#	$node_($m) set X_ [expr $i*240];
#	$node_($m) set Y_ [expr $k*240+20.0];
#CHNG
	if {$grid == 1} {
		set x_pos [expr $x_start+$j*($x_dim/$num_col)];#grid settings
		set y_pos [expr $y_start+$i*($y_dim/$num_row)];#grid settings
	} else {
		set x_pos [expr int($x_dim*rand())] ;#random settings
		set y_pos [expr int($y_dim*rand())] ;#random settings
	}
	$node_($m) set X_ $x_pos;
	$node_($m) set Y_ $y_pos;
	$node_($m) set Z_ 0.0
	puts -nonewline $topofile "$m x: [$node_($m) set X_] y: [$node_($m) set Y_] \n"
    }
    incr i;
}; 

if {$grid == 1} {
	puts "GRID topology"
} else {
	puts "RANDOM topology"
}
puts "node creation complete"
#CHNG
if {$num_parallel_flow > $num_row} {
	set num_parallel_flow $num_row
}

#CHNG
if {$num_cross_flow > $num_col} {
	set num_cross_flow $num_col
}

#CHNG
for {set i 0} {$i < [expr $num_parallel_flow + $num_cross_flow + $num_random_flow ]} {incr i} { ;#sink
#    set udp_($i) [new Agent/UDP]
#    set null_($i) [new Agent/Null]

	set udp_($i) [new $tcp_src]
	$udp_($i) set class_ $i
	set null_($i) [new $tcp_sink]
	$udp_($i) set fid_ $i
	if { [expr $i%2] == 0} {
		$ns color $i Blue
	} else {
		$ns color $i Red
	}

} 

#####################------------  PARALLEL FLOW

#CHNG
for {set i 0} {$i < $num_parallel_flow } {incr i} {
	set udp_node $i
	set null_node [expr $i+(($num_col)*($num_row-1))];#CHNG
	$ns attach-agent $node_($udp_node) $udp_($i)
  	$ns attach-agent $node_($null_node) $null_($i)
	puts -nonewline $topofile "PARALLEL: Src: $udp_node Dest: $null_node\n"
} 

#  $ns attach-agent $node_(0) $udp_(0)
#  $ns attach-agent $node_(6) $null_(0)

#CHNG
for {set i 0} {$i < $num_parallel_flow } {incr i} {
     $ns connect $udp_($i) $null_($i)
	#  $ns  at  0.0  "plotWindow $udp_($i)  $conges_data"
}
#CHNG
for {set i 0} {$i < $num_parallel_flow } {incr i} {
	set cbr_($i) [new Application/Traffic/CBR]
	$cbr_($i) set packetSize_ $cbr_size
	$cbr_($i) set rate_ $cbr_rate
	$cbr_($i) set interval_ $cbr_interval
	$cbr_($i) attach-agent $udp_($i)
} 

#CHNG
for {set i 0} {$i < $num_parallel_flow } {incr i} {
     $ns at [expr $start_time+$i*$parallel_start_gap] "$cbr_($i) start"
}
###############---------------- CROSS FLOW
#CHNG
set k $num_parallel_flow 
#for {set i 1} {$i < [expr $num_col-1] } {incr i} {
#CHNG
for {set i 0} {$i < $num_cross_flow } {incr i} {
	set udp_node [expr $i*$num_col];#CHNG
	set null_node [expr ($i+1)*$num_col-1];#CHNG
	$ns attach-agent $node_($udp_node) $udp_($k)
  	$ns attach-agent $node_($null_node) $null_($k)
	puts -nonewline $topofile "CROSS: Src: $udp_node Dest: $null_node\n"
	incr k
} 

#CHNG
set k $num_parallel_flow
#CHNG
for {set i 0} {$i < $num_cross_flow } {incr i} {
	$ns connect $udp_($k) $null_($k)
	# $ns  at  0.0  "plotWindow $udp_($k)  $conges_data"

	incr k
}
#CHNG
set k $num_parallel_flow
#CHNG
for {set i 0} {$i < $num_cross_flow } {incr i} {
	set cbr_($k) [new Application/Traffic/CBR]
	$cbr_($k) set packetSize_ $cbr_size
	$cbr_($k) set rate_ $cbr_rate
	$cbr_($k) set interval_ $cbr_interval
	$cbr_($k) attach-agent $udp_($k)
	incr k
} 

#CHNG
set k $num_parallel_flow
#CHNG
for {set i 0} {$i < $num_cross_flow } {incr i} {
	$ns at [expr $start_time+$i*$cross_start_gap] "$cbr_($k) start"
	incr k
}
#########################------------RANDOM FLOW
set r $k
set rt $r
set num_node [expr $num_row*$num_col]
for {set i 1} {$i < [expr $num_random_flow+1]} {incr i} {
	set udp_node [expr int($num_node*rand())] ;# src node
	set null_node $udp_node
	while {$null_node==$udp_node} {
		set null_node [expr int($num_node*rand())] ;# dest node
	}
	$ns attach-agent $node_($udp_node) $udp_($rt)
  	$ns attach-agent $node_($null_node) $null_($rt)
	puts -nonewline $topofile "RANDOM:  Src: $udp_node Dest: $null_node\n"
	incr rt
} 

set rt $r
for {set i 1} {$i < [expr $num_random_flow+1]} {incr i} {
	$ns connect $udp_($rt) $null_($rt)
	# $ns  at  0.0  "plotWindow $udp_($rt)  $conges_data"
	incr rt
}
set rt $r
for {set i 1} {$i < [expr $num_random_flow+1]} {incr i} {
	set cbr_($rt) [new Application/Traffic/CBR]
	$cbr_($rt) set packetSize_ $cbr_size
	$cbr_($rt) set rate_ $cbr_rate
	$cbr_($rt) set interval_ $cbr_interval
	$cbr_($rt) attach-agent $udp_($rt)
	incr rt
} 

set rt $r
for {set i 1} {$i < [expr $num_random_flow+1]} {incr i} {
	$ns at [expr $start_time] "$cbr_($rt) start"
	incr rt
}
puts "flow creation complete"
######################---------------------- END OF FLOW GENERATION
# Tell nodes when the simulation ends
#
for {set i 0} {$i < [expr $num_row*$num_col] } {incr i} {
    $ns at [expr $start_time+$time_duration] "$node_($i) reset";
}
$ns at [expr $start_time+$time_duration +$extra_time] "finish"
$ns at [expr $start_time+$time_duration +20] "puts \"NS Exiting...\"; $ns halt"
# $ns at [expr $start_time+$time_duration +$extra_time] "$ns nam-end-wireless [$ns now]; puts \"NS Exiting...\"; $ns halt"

$ns at [expr $start_time+$time_duration/2] "puts \"half of the simulation is finished\""
$ns at [expr $start_time+$time_duration] "puts \"end of simulation duration\""

proc finish {} {
	puts "finishing"
	# global ns tracefd namtrace topofile nm
	global ns tracefd topofile
	#global ns topofile

	$ns flush-trace
	close $tracefd
	# close $namtrace
	close $topofile
	
	# exec nam out.nam &
	exit 0
}

for {set i 0} {$i < [expr $num_row*$num_col]  } { incr i} {
	$ns initial_node_pos $node_($i) 4
}

puts "Starting Simulation..."
$ns run 

#==========================================================================
# set up for hierarchical routing (needed for routing over a basestation)
#puts "start hierarchical addressing"
# $ns node-config -addressType hierarchical
# AddrParams set domain_num_ 2          			;# domain number
# lappend cluster_num 1 1            			;# cluster number for each domain 
# AddrParams set cluster_num_ $cluster_num
# lappend eilastlevel 1 [expr ($nb_mn+1)] 		;# number of nodes for each cluster (1 for sink and one for mobile nodes + base station
# AddrParams set nodes_num_ $eilastlevel
# puts "Configuration of hierarchical addressing done"

#setup channel model
# set prop_inst [$ns set propInstance_]
# $prop_inst ITU_PDP PED_A
# puts "after set pPDP"


# set bstation [$ns node 1.0.0]  
# $bstation random-motion 0
# #puts "Base-Station node created"
# #provide some co-ord (fixed) to base station node
# $bstation set X_ 60.0
# $bstation set Y_ 50.0
# $bstation set Z_ 1.5
# [$bstation set mac_(0)] set-channel 0

# creation of the mobile nodes
# $ns node-config -macType Mac/802_16/SS \
#     -wiredRouting OFF \
#     -macTrace ON  				;# Mobile nodes cannot do routing.
# for {set i 0} {$i < $nb_mn} {incr i} {
#     set wl_node_($i) [$ns node 1.0.[expr $i + 1]] 	;# create the node with given @.	
#     $wl_node_($i) random-motion 0			;# disable random motion
#     $wl_node_($i) base-station [AddrParams addr2id [$bstation node-addr]] ;#attach mn to basestation
#     #compute position of the node
#     $wl_node_($i) set X_ [expr 60.0+$distance]
#     $wl_node_($i) set Y_ 50.0
#     $wl_node_($i) set Z_ 0.0
#     puts "wireless node $i created ..."			;# debug info

#     [$wl_node_($i) set mac_(0)] set-channel 0
#     [$wl_node_($i) set mac_(0)] set-diuc $diuc
#     [$wl_node_($i) set mac_(0)] setflow UL 10000 BE 275 2 0 0.05 1024 1 0 0 0 0 0 0 0 0 0 0 ;# setting up static flows 
#     [$wl_node_($i) set mac_(0)] setflow DL 10000 BE 275 2 0 0.05 1024 1 0 0 0 0 0 0 0 0 0 0 ;# setting up static flows 

#     #create source traffic
#     #Create a UDP agent and attach it to node n0
#     set udp_($i) [new Agent/UDP]
#     $udp_($i) set packetSize_ $packet_size

#     if { $direction == "ul" } {
# 	$ns attach-agent $wl_node_($i) $udp_($i)
#     } else {
# 	$ns attach-agent $sinkNode $udp_($i)
#     }

#     # Create a CBR traffic source and attach it to udp0
#     set cbr_($i) [new Application/Traffic/CBR]
#     $cbr_($i) set packetSize_ $packet_size
#     $cbr_($i) set interval_ $gap_size
#     $cbr_($i) attach-agent $udp_($i)

#     #create an sink into the sink node

#     # Create the Null agent to sink traffic
#     set null_($i) [new Agent/Null] 
#     if { $direction == "ul" } {    
# 	$ns attach-agent $sinkNode $null_($i)
#     } else {
# 	$ns attach-agent $wl_node_($i) $null_($i)
#     }
    
#     # Attach the 2 agents
#     $ns connect $udp_($i) $null_($i)
# }

# # create the link between sink node and base station
# $ns duplex-link $sinkNode $bstation 100Mb 1ms DropTail

# # Traffic scenario: if all the nodes start talking at the same
# # time, we may see packet loss due to bandwidth request collision
# set diff 0.02
# for {set i 0} {$i < $nb_mn} {incr i} {
#     $ns at [expr $traffic_start+$i*$diff] "$cbr_($i) start"
#     $ns at [expr $traffic_stop+$i*$diff] "$cbr_($i) stop"
# }

# #$ns at 4 "$nd_(1) dump-table"
# #$ns at 5 "$nd_(1) send-rs"
# #$ns at 6 "$nd_(1) dump-table"
# #$ns at 8 "$nd_(1) dump-table"

# $ns at $simulation_stop "finish"
# #$ns at $simulation_stop "$ns halt"
# # Run the simulation
# puts "Running simulation for $nb_mn mobile nodes..."

# $ns run
# puts "Simulation done."
