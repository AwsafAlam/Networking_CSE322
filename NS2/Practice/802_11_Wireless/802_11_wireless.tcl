# Network size
set x_dim 150 ; #[lindex $argv 1]
set y_dim 150 ; #[lindex $argv 1]

# Number ans positioning of nodes (Here, nodes are arranged in a grid)
set num_row [lindex $argv 0] ;#number of row
set num_col [lindex $argv 0] ;#number of column

# Number and other attr of flow ( flow start etc )

set time_duration 25 ; #[lindex $argv 5] ;#50
set start_time 50 ;# 100
set parallel_start_gap 0.0
# set cross_start_gap 0.0 ;# for cross flow

############################
#Setting Flow parameters

set num_parallel_flow 20 ;#[lindex $argv 0]	# along column
set num_cross_flow 20 ;#[lindex $argv 0]		#along row
set num_random_flow 20
set num_sink_flow [expr $num_row*$num_col] ;#sink
set sink_node 100 ;#sink id, dummy here; updated next

set grid 0
set extra_time 10 ;#10

# TCP
set tcp_src Agent/UDP
set tcp_sink Agent/Null

# Transfer rate
set cbr_size 64 ; #[lindex $argv 2]; #4,8,16,32,64
set cbr_rate 11.0Mb
set cbr_pckt_per_sec 500
set cbr_interval [expr 1.0/$cbr_pckt_per_sec] ;# ?????? 1 for 1 packets per second and 0.1 for 10 packets per second

#set cbr_interval 0.00005 ; #[expr 1/[lindex $argv 2]] ;# ?????? 1 for 1 packets per second and 0.1 for 10 packets per second

###########################
# Energy parameters
set val(energymodel_11)    EnergyModel     ;
set val(initialenergy_11)  1000            ;# Initial energy in Joules

set val(idlepower_11) 869.4e-3			;#LEAP (802.11g) 
set val(rxpower_11) 1560.6e-3			;#LEAP (802.11g)
set val(txpower_11) 1679.4e-3			;#LEAP (802.11g)
set val(sleeppower_11) 37.8e-3			;#LEAP (802.11g)
set val(transitionpower_11) 176.695e-3		;#LEAP (802.11g)	??????????????????????????????/
set val(transitiontime_11) 2.36			;#LEAP (802.11g)

################################
# Protocols and models for different layers

set val(chan) Channel/WirelessChannel ;# channel type
set val(prop) Propagation/TwoRayGround ;# radio-propagation model
#set val(prop) Propagation/FreeSpace ;# radio-propagation model
set val(netif) Phy/WirelessPhy ;# network interface type
set val(mac) Mac/802_11 ;# MAC type
#set val(mac) SMac/802_15_4 ;# MAC type
set val(ifq) Queue/DropTail/PriQueue ;# interface queue type
set val(ll) LL ;# link layer type
set val(ant) Antenna/OmniAntenna ;# antenna model
set val(ifqlen) 50 ;# max packet in ifq
set val(rp) DSDV ; #[lindex $argv 4] ;# routing protocol

#################################################################################################

# Initialize ns
#
set ns_ [new Simulator]

# Init different files
set nm out.nam
set tr wireless.tr
set topo_file topo.txt

## Set different trace parameters

set tracefd [open $tr w]
$ns_ trace-all $tracefd

#$ns_ use-newtrace ;# use the new wireless trace file format

set namtrace [open $nm w]
$ns_ namtrace-all-wireless $namtrace $x_dim $y_dim ;# For wireless only
# $ns_ namtrace-all $namtrace

set topofile [open $topo_file "w"]

# set up topography object
set topo [new Topography]
$topo load_flatgrid $x_dim $y_dim
#$topo load_flatgrid 1000 1000

if {$num_sink_flow > 0} { ;#sink
	create-god [expr $num_row * $num_col + 1 ]
} else {
	create-god [expr $num_row * $num_col ] ;# general operations director
}

## TODO: why need if else?

#############################################################################################
#set node configuration

$ns_ node-config -adhocRouting $val(rp) -llType $val(ll) \
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


#          		 -transitionTime 0.005 \
 
#######################################################################################################
puts "start node creation"
for {set i 0} {$i < [expr $num_row*$num_col]} {incr i} {
	set node_($i) [$ns_ node]
	$node_($i) random-motion 0;# For static only
}

# Node positioning in grid

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

	# With grid
    set x_pos [expr $x_start+$j*($x_dim/$num_col)];#grid settings
    set y_pos [expr $y_start+$i*($y_dim/$num_row)];#grid settings
	
    # Randomisedd
    # set x_pos [expr int($x_dim*rand())] ;#random settings
    # set y_pos [expr int($y_dim*rand())] ;#random settings

	$node_($m) set X_ $x_pos;
	$node_($m) set Y_ $y_pos;
	$node_($m) set Z_ 0.0
    #puts "$m"
	puts -nonewline $topofile "$m x: [$node_($m) set X_] y: [$node_($m) set Y_] \n"
    }
    incr i;
}; 

####################################################################################################
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
for {set i 0} {$i < $num_parallel_flow} {incr i} { ;#sink
#    set udp_($i) [new Agent/UDP]
#    set null_($i) [new Agent/Null]

	set udp_($i) [new $tcp_src]
	$udp_($i) set class_ $i
	set null_($i) [new $tcp_sink]
	$udp_($i) set fid_ $i
	if { [expr $i%2] == 0} {
		$ns_ color $i Blue
	} else {
		$ns_ color $i Red
	}

} 

######## ------------  PARALLEL FLOW

#CHNG
for {set i 0} {$i < $num_parallel_flow } {incr i} {
	set udp_node $i
	set null_node [expr $i+(($num_col)*($num_row-1))];#CHNG
	$ns_ attach-agent $node_($udp_node) $udp_($i)
  	$ns_ attach-agent $node_($null_node) $null_($i)
	puts -nonewline $topofile "PARALLEL: Src: $udp_node Dest: $null_node\n"
} 

#  $ns_ attach-agent $node_(0) $udp_(0)
#  $ns_ attach-agent $node_(6) $null_(0)

#CHNG
for {set i 0} {$i < $num_parallel_flow } {incr i} {
     $ns_ connect $udp_($i) $null_($i)
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
     $ns_ at [expr $start_time+$i*$parallel_start_gap] "$cbr_($i) start"
}

puts "flow creation complete"
######################---------------------- END OF FLOW GENERATION
#  Set timings for different events
# Tell nodes when the simulation ends
#
for {set i 0} {$i < [expr $num_row*$num_col] } {incr i} {
    $ns_ at [expr $start_time+$time_duration] "$node_($i) reset";
}
$ns_ at [expr $start_time+$time_duration +$extra_time] "finish"
#$ns_ at [expr $start_time+$time_duration +20] "puts \"NS Exiting...\"; $ns_ halt"
$ns_ at [expr $start_time+$time_duration +$extra_time] "$ns_ nam-end-wireless [$ns_ now]; puts \"NS Exiting...\"; $ns_ halt"

$ns_ at [expr $start_time+$time_duration/2] "puts \"half of the simulation is finished\""
$ns_ at [expr $start_time+$time_duration] "puts \"end of simulation duration\""

proc finish {} {
	puts "finishing"

	global ns_ tracefd namtrace topofile nm
	#global ns_ topofile

	$ns_ flush-trace
	close $tracefd
	close $namtrace
	close $topofile
	
    exec nam $nm &
	exit 0
}

for {set i 0} {$i < [expr $num_row*$num_col]  } { incr i} {
	$ns_ initial_node_pos $node_($i) 4
}

puts "Starting Simulation..."
$ns_ run 