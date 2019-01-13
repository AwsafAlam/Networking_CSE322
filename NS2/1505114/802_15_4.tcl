#============================================ 802.15.4 ================================
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
set parallel_start_gap 0.1
set cross_start_gap 0.1

#===========================ENERGY PARAMETERS ==============
set val(energymodel_15_4)    EnergyModel     ;
set val(initialenergy_15_4)  1000            ;# Initial energy in Joules
set val(idlepower_15_4) 3e-3			;#telos	(active power in spec)
set val(rxpower_15_4) 38e-3			;#telos
set val(txpower_15_4) 35e-3			;#telos
set val(sleeppower_15_4) 15e-6			;#telos
set val(transitionpower_15_4) 1.8e-6		;#telos: volt = 1.8V; sleep current of MSP430 = 1 microA; so, 1.8 micro W
set val(transitiontime_15_4) 6e-6		;#telos

set num_random_flow [lindex $argv 2]
set num_parallel_flow [lindex $argv 2]
set num_cross_flow [lindex $argv 2]
set speed_node [lindex $argv 3]
set grid [lindex $argv 1]
set extra_time 10 ;#10

if { $num_random_flow > $num_col} {
	set num_random_flow  [expr $num_col-1]
	set num_cross_flow  [expr $num_col-1]
	set num_parallel_flow  [expr $num_col-1]
}

set tcp_src Agent/TCP ;# Agent/TCP or Agent/TCP/Reno or Agent/TCP/Newreno or Agent/TCP/FullTcp/Sack or Agent/TCP/Vegas
set tcp_sink Agent/TCPSink ;# Agent/TCPSink or Agent/TCPSink/Sack1

# =====================
# source / sink options
# =====================
# UDP:		Agent/UDP		Agent/Null
# TAHOE:	Agent/TCP		Agent/TCPSink
# RENO:		Agent/TCP/Reno		Agent/TCPSink
# NEWRENO:	Agent/TCP/Newreno	Agent/TCPSink
# SACK: 	Agent/TCP/FullTcp/Sack	Agent/TCPSink/Sack1
# VEGAS:	Agent/TCP/Vegas		Agent/TCPSink
# FACK:		Agent/TCP/Fack		Agent/TCPSink
# LINUX:	Agent/TCP/Linux		Agent/TCPSink


#set frequency_ 2.461e+9
#Phy/WirelessPhy set Rb_ 11*1e6            ;# Bandwidth
#Phy/WirelessPhy set freq_ $frequency_

#==========================================================================
set val(chan) Channel/WirelessChannel ;# channel type
set val(prop) Propagation/TwoRayGround ;# radio-propagation model
set val(netif) Phy/WirelessPhy/802_15_4 ;# network interface type
set val(mac) Mac/802_15_4 ;# MAC type
#set val(mac) SMac/802_15_4 ;# MAC type
set val(ifq) Queue/DropTail/PriQueue ;# interface queue type
set val(ll) LL ;# link layer type
set val(ant) Antenna/OmniAntenna ;# antenna model
set val(ifqlen) 50 ;#   max packet in ifq
set val(rp) AODV ;# routing protocol
set val(energymodel) EnergyModel;
set val(initialenergy) 100;

set dist(5m)  7.69113e-06
set dist(9m)  2.37381e-06
set dist(10m) 1.92278e-06
set dist(11m) 1.58908e-06
set dist(12m) 1.33527e-06
set dist(13m) 1.13774e-06
set dist(14m) 9.81011e-07
set dist(15m) 8.54570e-07
set dist(16m) 7.51087e-07
set dist(20m) 4.80696e-07
set dist(25m) 3.07645e-07
set dist(30m) 2.13643e-07
set dist(35m) 1.56962e-07
set dist(40m) 1.20174e-07
Phy/WirelessPhy set CSThresh_ $dist(40m)
Phy/WirelessPhy set RXThresh_ $dist(40m)

# set nm tcp_wireless.nam
set tr trace.tr
set topo_file topo_802.15.4.txt
set conges_data [open conges_data.txt w]

set ns [new Simulator]

set tracefd [open $tr w]
$ns trace-all $tracefd

# set namtrace [open $nm w]
# $ns namtrace-all-wireless $namtrace $x_dim $y_dim

set topofile [open $topo_file "w"]

# set up topography object
set topo       [new Topography]
$topo load_flatgrid $x_dim $y_dim
#$topo load_flatgrid 1000 1000

create-god [expr $num_row * $num_col ]

$ns node-config -adhocRouting $val(rp) -llType $val(ll) \
	     -macType $val(mac)  -ifqType $val(ifq) \
	     -ifqLen $val(ifqlen) -antType $val(ant) \
	     -propType $val(prop) -phyType $val(netif) \
	     -channel  [new $val(chan)] -topoInstance $topo \
	     -agentTrace ON -routerTrace ON\
	     -macTrace ON \
	     -movementTrace OFF \
			 -energyModel $val(energymodel_15_4) \
			 -idlePower $val(idlepower_15_4) \
			 -rxPower $val(rxpower_15_4) \
			 -txPower $val(txpower_15_4) \
          		 -sleepPower $val(sleeppower_15_4) \
          		 -transitionPower $val(transitionpower_15_4) \
			 -transitionTime $val(transitiontime_15_4) \
			 -initialEnergy $val(initialenergy_15_4)


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
	 $ns  at  0.0  "plotWindow $udp_($i)  $conges_data"
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
	$ns  at  0.0  "plotWindow $udp_($k)  $conges_data"
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
	$ns  at  0.0  "plotWindow $udp_($rt)  $conges_data"
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

#======= Congestion Window size ============
proc plotWindow {tcpSource outfile} {
     global ns

     set now [$ns now]
     set cwnd [$tcpSource set cwnd_]

  	###Print TIME CWND   for  gnuplot to plot progressing on CWND
     puts  $outfile  "$now $cwnd"

     $ns at [expr $now+0.7] "plotWindow $tcpSource  $outfile"
  }


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
	#exec xgraph tcp_wireless.tr -geometry 800x400 &
        # exec nam $nm &
        exit 0
}

for {set i 0} {$i < [expr $num_row*$num_col]  } { incr i} {
	$ns initial_node_pos $node_($i) 4
}

puts "Starting Simulation..."
$ns run
#$ns nam-end-wireless [$ns now]