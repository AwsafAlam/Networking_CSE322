# For wireless 802.11 mobile init vaariables
# Step - 1
# (a) Setup network size
set num_row [lindex $argv 0] ;#number of row
set num_col [lindex $argv 0] ;#number of column
set val(nn) [expr $num_row*$num_col] ;# Number of nodes

# (b) - Positioning of nodes
set val(nn) [expr $num_row*$num_col] ;# Number of nodes
set x_dim 150 ; #[lindex $argv 1]
set y_dim 150 ; #[lindex $argv 1]

# Setting time duration
set time_duration [lindex $argv 5] ;#50
set start_time 5 ;#100
set parallel_start_gap 1.0
set num_parallel_flow [lindex $argv 2] ;# along column
set num_cross_flow [lindex $argv 2]
set extra_time 5 ;#10

# set routing_prot [lindex $argv 4]
# (e) - protocols and models for different layers
# A wireless environment can be modeled by configuring the protocol stack of each node.  

set val(chan) Channel/WirelessChannel ;# channel type ->C++ file

## Physical Layer
set val(netif) Phy/WirelessPhy ;# network interface type
# Phy/WirelessPhy set Pt 2.07983391e-01
# Phy/WirelessPhy set RXThresh 2.591168e-08
# Phy/WirelessPhy set CSThresh 3.497734e-09
# set frequency_ 2.461e+9

# Phy/WirelessPhy set Rb_ 11*1e6            ;# Bandwidth
# Phy/WirelessPhy set freq_ $frequency_
# Phy/WirelessPhy/802_15_4 ;# network interface type

# set dist(5m)  7.69113e-06
# set dist(9m)  2.37381e-06
# set dist(10m) 1.92278e-06
# set dist(11m) 1.58908e-06
# set dist(12m) 1.33527e-06
# set dist(13m) 1.13774e-06
# set dist(14m) 9.81011e-07
# set dist(15m) 8.54570e-07
# set dist(16m) 7.51087e-07
# set dist(20m) 4.80696e-07
# set dist(25m) 3.07645e-07
# set dist(30m) 2.13643e-07
# set dist(35m) 1.56962e-07
# set dist(40m) 1.20174e-07
# Phy/WirelessPhy set CSThresh_ $dist(40m)
# Phy/WirelessPhy set RXThresh_ $dist(40m)


# Configuring propagation model
set val(prop) Propagation/TwoRayGround ;# radio-propagation model
#set val(prop) Propagation/FreeSpace ;# radio-propagation model

# Configuring Antena model
set val(ant) Antenna/OmniAntenna ;# antenna model
# set val(ant) Antenna/Directional ;# antenna model

#### Linked Layer
set val(ll) LL ;# link layer type- include ARP protocol

### Configuring Mac model
set val(mac) Mac/802_11 ;# MAC type -> wifi
# set val(mac) Mac/802_15_4 ;# MAC type -> Sensors
# set val(mac) SMac/802_15_4 ;# MAC type


### Configuring Queue
set val(ifq) Queue/DropTail/PriQueue ;# interface queue type
# set val(ifq) Queue/DropTail/REDQueue ;# interface queue type
set val(ifqlen) 50 ;# max packet in ifq -> Queue length
set val(rp) [lindex $argv 4] ;# routing protocol

#remove-all-packet-headers
# add-packet-header DSDV AODV ARP LL MAC CBR IP

############# ENERGY PARAMETERS

set val(energymodel_11)    EnergyModel     ;
set val(initialenergy_11)  1000            ;# Initial energy in Joules

set val(idlepower_11) 869.4e-3			;#LEAP (802.11g) 
set val(rxpower_11) 1560.6e-3			;#LEAP (802.11g)
set val(txpower_11) 1679.4e-3			;#LEAP (802.11g)
set val(sleeppower_11) 37.8e-3			;#LEAP (802.11g)
set val(transitionpower_11) 176.695e-3		;#LEAP (802.11g)
set val(transitiontime_11) 2.36			;#LEAP (802.11g)

#set val(idlepower_11) 900e-3			;#Stargate (802.11b) 
#set val(rxpower_11) 925e-3			;#Stargate (802.11b)
#set val(txpower_11) 1425e-3			;#Stargate (802.11b)
#set val(sleeppower_11) 300e-3			;#Stargate (802.11b)
#set val(transitionpower_11) 200e-3		;#Stargate (802.11b)	??????????????????????????????/
#set val(transitiontime_11) 3			;#Stargate (802.11b)

### Init traffic parameters
set cbr_size 64 ; #[lindex $argv 2]; #4,8,16,32,64
set cbr_rate 11.0Mb
set cbr_pckt_per_sec 500
set cbr_interval [expr 1.0/$cbr_pckt_per_sec] ;# ?????? 1 for 1 packets per second and 0.1 for 10 packets per second
#set cbr_interval 0.00005 ; #[expr 1/[lindex $argv 2]] ;# ?????? 1 for 1 packets per second and 0.1 for 10 packets per second

#### MAC Layer properties
Mac/802_11 set dataRate_ 11Mb
Mac/802_11 set syncFlag_ 1
Mac/802_11 set dutyCycle_ cbr_interval


# Step 2 - Init simulator object
set ns [new Simulator]

# Step 3 - Create trace and nam files
set nm wireless.nam
set tr wireless.tr

set tracefd [open $tr w]
$ns trace-all $tracefd ;# Done creation of trace file
# $ns use-newtrace ;# to include new trace format. More details in docs.

set namtrace [open $nm w]
$ns namtrace-all-wireless $namtrace $x_dim $y_dim ;# Creation of nam

set topofile [open topo.txt "w"]

# Step 4 - Topology
set topo    [new Topography]
$topo load_flatgrid $x_dim $y_dim ;# FLATGRID MEANS NO z axis. So,  z axis = 0.0. The nodes are moving on a (2D)

# Step 5 - create-god -> General Operations Directory
create-god $val(nn) ;# GOD handles routine, pckt exchange etc, must store total ndes. wireless nodes are autoomous, controlled by GOD

# Configure the node

$ns node-config -adhocRouting $val(rp) -llType $val(ll) \
     -macType $val(mac)  -ifqType $val(ifq) \
     -ifqLen $val(ifqlen) -antType $val(ant) \
     -propType $val(prop) -phyType $val(netif) \
     -channel  [new $val(chan)] -topoInstance $topo \
     -agentTrace ON -routerTrace OFF\
     -macTrace ON \
     -movementTrace ON \
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
}

# Step 5 - position of nodes (Only needed for wireless)
set grid [lindex $argv 1]
set speed [lindex $argv 3]

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
		$ns at [expr rand()*($start_time+$time_duration)] "$node_($m) setdest [expr $x_dim - $x_pos] [expr $y_dim - $y_pos] $speed"

        #	puts "$m"
        puts -nonewline $topofile "$m x: [$node_($m) set X_] y: [$node_($m) set Y_] \n"
    }
    incr i;
}; 
if {$grid == 1} {
	puts "GRID topology"
} else {
	puts "RANDOM topology"
}
puts "node creation and positioning complete"

# - Any mobility ( If nodes are moving )
# At what time, which node, at what speed?
# set speed [lindex $argv 3]
#     Time  Node            src   dst    speed-> Node can move anywhere at any time, any speed
# $ns at 3.0 "$node_(1) setdest 490.0 340.0 25.0"
#
# for {set i 0} {$i < [expr $num_row*$num_col]} {incr i} {

# 	$ns at [expr rand()*$time_duration] "$node_($i) setdest [expr $i+(($num_col)*($num_row-1))] [expr $i+(($x_dim)*($y_dim-1))] $speed"

# }


set tcp_src Agent/TCP
set tcp_sink Agent/TCPSink

# TAHOE:	Agent/TCP		Agent/TCPSink
# RENO:		Agent/TCP/Reno		Agent/TCPSink
# NEWRENO:	Agent/TCP/Newreno	Agent/TCPSink
# SACK: 	Agent/TCP/FullTcp/Sack	Agent/TCPSink/Sack1
# VEGAS:	Agent/TCP/Vegas		Agent/TCPSink
# FACK:		Agent/TCP/Fack		Agent/TCPSink
# LINUX:	Agent/TCP/Linux		Agent/TCPSink

####  Step 6 - Create flows and associate them with nodes
for {set i 0} {$i < $val(nn)} {incr i} { ;#sink
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

for {set i 0} {$i < $num_parallel_flow } {incr i} {
	set tcp_node $i
	set null_node [expr $i+(($num_col)*($num_row-1))];#CHNG
	$ns attach-agent $node_($tcp_node) $udp_($i) ;# Init ar src
  	$ns attach-agent $node_($null_node) $null_($i);# Init as sink
	puts -nonewline $topofile "PARALLEL: Src: $tcp_node Dest: $null_node\n"
} 

#  $ns attach-agent $node_(0) $udp_(0)
#  $ns attach-agent $node_(6) $null_(0)

#Connecting src and sink
for {set i 0} {$i < $num_parallel_flow } {incr i} {
     $ns connect $udp_($i) $null_($i)
}
#creating traffic
for {set i 0} {$i < $num_parallel_flow } {incr i} {
	set cbr_($i) [new Application/Traffic/CBR]
	$cbr_($i) set packetSize_ $cbr_size
	$cbr_($i) set rate_ $cbr_rate
	$cbr_($i) set interval_ $cbr_interval
	$cbr_($i) attach-agent $udp_($i)
} 

#Start trafic
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
	$ns at [expr $start_time+$i*$parallel_start_gap] "$cbr_($k) start"
	incr k
}
#########################------------RANDOM FLOW
set r $k
set rt $r
set num_node [expr $num_row*$num_col]
for {set i 1} {$i < [expr $num_cross_flow]} {incr i} {
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
for {set i 1} {$i < [expr $num_cross_flow]} {incr i} {
	$ns connect $udp_($rt) $null_($rt)
	incr rt
}
set rt $r
for {set i 1} {$i < [expr $num_cross_flow]} {incr i} {
	set cbr_($rt) [new Application/Traffic/CBR]
	$cbr_($rt) set packetSize_ $cbr_size
	$cbr_($rt) set rate_ $cbr_rate
	$cbr_($rt) set interval_ $cbr_interval
	$cbr_($rt) attach-agent $udp_($rt)
	incr rt
} 

set rt $r
for {set i 1} {$i < [expr $num_cross_flow]} {incr i} {
	$ns at [expr $start_time] "$cbr_($rt) start"
	incr rt
}

#######################################################################SINK FLOW
# set r $rt
# set rt $r
# set num_node [expr $num_row*$num_col]
# for {set i 1} {$i < [expr $num_sink_flow+1]} {incr i} {
# 	set udp_node [expr $i-1] ;#[expr int($num_node*rand())] ;# src node
# 	set null_node $sink_node
# 	#while {$null_node==$udp_node} {
# 	#	set null_node [expr int($num_node*rand())] ;# dest node
# 	#}
# 	$ns attach-agent $node_($udp_node) $udp_($rt)
#   	$ns attach-agent $node_($null_node) $null_($rt)
# 	puts -nonewline $topofile "SINK:  Src: $udp_node Dest: $null_node\n"
# 	incr rt
# } 

# set rt $r
# for {set i 1} {$i < [expr $num_sink_flow+1]} {incr i} {
# 	$ns connect $udp_($rt) $null_($rt)
# 	incr rt
# }
# set rt $r
# for {set i 1} {$i < [expr $num_sink_flow+1]} {incr i} {
# 	set cbr_($rt) [new Application/Traffic/CBR]
# 	$cbr_($rt) set packetSize_ $cbr_size
# 	$cbr_($rt) set rate_ $cbr_rate
# 	$cbr_($rt) set interval_ $cbr_interval
# 	$cbr_($rt) attach-agent $udp_($rt)
# 	incr rt
# } 

# set rt $r
# for {set i 1} {$i < [expr $num_sink_flow+1]} {incr i} {
# 	$ns at [expr $start_time+$i*$sink_start_gap+rand()] "$cbr_($rt) start"
# 	incr rt
# }

puts "flow creation complete"

# Tell nodes when the simulation ends
#
for {set i 0} {$i < [expr $num_row*$num_col] } {incr i} {
    $ns at [expr $start_time+$time_duration] "$node_($i) reset";
}
$ns at [expr $start_time+$time_duration +$extra_time] "finish"
#$ns at [expr $start_time+$time_duration +20] "puts \"NS Exiting...\"; $ns halt"
$ns at [expr $start_time+$time_duration +$extra_time] "$ns nam-end-wireless [$ns now]; puts \"NS Exiting...\"; $ns halt"

$ns at [expr $start_time+$time_duration/2] "puts \"half of the simulation is finished\""
$ns at [expr $start_time+$time_duration] "puts \"end of simulation duration\""

proc finish {} {
	puts "finishing"
	global ns tracefd namtrace topofile nm
	#global ns topofile

	$ns flush-trace
	close $tracefd
	close $namtrace
	close $topofile
	
	# exec nam $nm &
	exit 0
}

#set opt(mobility) "position.txt"
#source $opt(mobility)
#set opt(traff) "traffic.txt"
#source $opt(traff)

for {set i 0} {$i < [expr $num_row*$num_col]  } { incr i} {
	$ns initial_node_pos $node_($i) 4
}

puts "Starting Simulation..."
$ns run 
#$ns nam-end-wireless [$ns now]
