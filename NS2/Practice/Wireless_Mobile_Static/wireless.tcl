# Step 1 - init vaariables
# We call C++ files from the TCL, which are implemented in the NS library. tcl and otcl wrks together
# Values are stored in an array
# Wireless networks need a channnel to communicated
# Two RayGround propagation model, for router. others are Shadowing
# Shadowing models for celluler network.
# physical layer depends on the radio model
# AODV protocol - Adhoc OnDemand Distance vector routing protocol

set val(chan) Channel/WirelessChannel ;# channel type ->C++ file
set val(prop) Propagation/TwoRayGround ;# radio-propagation model
#set val(prop) Propagation/FreeSpace ;# radio-propagation model
set val(netif) Phy/WirelessPhy ;# network interface type
set val(mac) Mac/802_11 ;# MAC type
# set val(mac) Mac/802_15_4 ;# MAC type
# set val(mac) SMac/802_15_4 ;# MAC type
set val(ifq) Queue/DropTail/PriQueue ;# interface queue type
set val(ll) LL ;# link layer type
set val(ant) Antenna/OmniAntenna ;# antenna model
set val(ifqlen) 50 ;# max packet in ifq
set val(rp) AODV ; #[lindex $argv 4] ;# routing protocol
# set val(rp) DSDV ; #[lindex $argv 4] ;# routing protocol

set num_row [lindex $argv 0] ;#number of row
set num_col [lindex $argv 0] ;#number of column
set val(nn) [expr $num_row*$num_col] ;# Number of nodes

# Setting grid size for nam
set x_dim 500 ; #[lindex $argv 1] 500 meters
set y_dim 500 ; #[lindex $argv 1] 500 meters

#############################################################ENERGY PARAMETERS
# By default all nodes have infinite energy

set val(energymodel_11)    EnergyModel     ;
set val(initialenergy_11)  1000            ;# Initial energy in Joules

set val(idlepower_11) 869.4e-3			;#LEAP (802.11g) 
set val(rxpower_11) 1560.6e-3			;#LEAP (802.11g)
set val(txpower_11) 1679.4e-3			;#LEAP (802.11g)
set val(sleeppower_11) 37.8e-3			;#LEAP (802.11g)
set val(transitionpower_11) 176.695e-3		;#LEAP (802.11g)
set val(transitiontime_11) 2.36			;#LEAP (802.11g)

# Step 2 - Ceate simulator object
set ns [new Simulator]

# Step 3 - Create trace and nam files
set nm wireless.nam
set tr wireless.tr

set tracefd [open $tr w]
$ns trace-all $tracefd ;# Done creation of trace file

set namtrace [open $nm w]
$ns namtrace-all-wireless $namtrace $x_dim $y_dim ;# Creation of nam

# Step 4 - Topology
set topo    [new Topography]
$topo load_flatgrid $x_dim $y_dim ;# FLATGRID MEANS NO z axis. So,  z axis = 0.0. The nodes are moving on a (2D)
set topofile [open topo.txt "w"]

# Step 5 - create-god -> General Operations Directory
create-god $val(nn) ;# GOD handles routine, pckt exchange etc, must store total ndes. wireless nodes are autoomous, controlled by GOD

# - Create Channel (Communication Path)
set ch1 [new $val(chan)] ;# Here, 2 nodes act on the same channel
set ch2 [new $val(chan)]


# Configure the node
# No space after \ .
$ns node-config -adhocRouting $val(rp) -llType $val(ll) \
     -macType $val(mac)  -ifqType $val(ifq) \
     -ifqLen $val(ifqlen) -antType $val(ant) \
     -propType $val(prop) -phyType $val(netif) \
     -channel  $ch1 -topoInstance $topo \
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



# Step 6 - Create Nodes
puts "start node creation"
for {set i 0} {$i < $val(nn)} {incr i} {
	set node_($i) [$ns node]
#	$node_($i) random-motion 0
# For creating nodes in different channels\
if i%2 == 0\
$ns node-config -channel $ch2\
else ch1. we can also add other properties similarly

# Here, we are using one channel only
# INITIALIZE THE LIST xListHead multiple times for multiple channels
}

# Step 8 - position of nodes (Only needed for wireless)
set grid [lindex $argv 1]

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

# Step 9 - Any mobility ( If nodes are moving )
# At what time, which node, at what speed?
set speed [lindex $argv 2]

#     Time  Node            src   dst    speed-> Node can move anywhere at any time, any speed

$ns at 3.0 "$node_(1) setdest 490.0 340.0 25.0"

# Step 10 - TCP, UDP Traffic
set tcp [new Agent/TCP]
$ns attach-agent $node_(1) $tcp

set sink [new Agent/TCPSink]
$ns attach-agent $node_(9) $sink

$ns connect $tcp $sink

set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 1.0 "$ftp start"

set udp [new Agent/UDP]
set null [new Agent/Null]

$ns attach-agent $node_(2) $udp
$ns attach-agent $node_(13) $null

$ns connect $udp $null

set cbr [new Application Application/Traffic/CBR]
$cbr attach-agent $udp
$ns at 1.0 "$cbr start"

$ns at 30.0 "finish"

## Finish
proc finish {} {
    puts "finishing"
	global ns tracefd namtrace topofile nm
	#global ns_ topofile

	$ns flush-trace
	close $tracefd
	close $namtrace
	close $topofile
	
	exec nam $nm &
	exit 0
}
# Run Simulation
# Initial nodes size, needed for nam only

for {set i 0} {$i < [expr $num_row*$num_col]  } { incr i} {
	$ns initial_node_pos $node_($i) 4
}

$ns run
