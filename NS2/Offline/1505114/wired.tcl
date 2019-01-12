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

# $tcl $row $topology $flow_no $speed $dist $pckt_size $pckt_per_sec 
set num_random_flow [lindex $argv 2]
set speed [lindex $argv 3] ;# Not needed for wired
set grid [lindex $argv 1]
set extra_time 10 ;#10

set tcp_src Agent/TCP ;# Agent/TCP or Agent/TCP/Reno or Agent/TCP/Newreno or Agent/TCP/FullTcp/Sack or Agent/TCP/Vegas
set tcp_sink Agent/TCPSink ;# Agent/TCPSink or Agent/TCPSink/Sack1


# set nm tcp_wired.nam
set tr trace.tr
set topo_file topo_tcp_wired.txt


set ns [new Simulator]


$ns rtproto DV
set tracefd [open $tr w]
$ns trace-all $tracefd

# set namtrace [open $nm w]
#$ns namtrace-all $namtrace

set topofile [open $topo_file "w"]
set conges_data [open conges_data.txt w]


set topo  [new Topography]
$topo load_flatgrid $x_dim $y_dim


create-god [expr $num_row * $num_col ]


puts "start node creation"
for {set i 0} {$i < [expr $num_row*$num_col]} {incr i} {
	set node_($i) [$ns node]
#	$node_($i) random-motion 0
}


set x_start [expr $x_dim/($num_col*2)];
set y_start [expr $y_dim/($num_row*2)];
set i 0;
while {$i < $num_row } {
#in same column
    for {set j 0} {$j < $num_col } {incr j} {
#in same row
	set m [expr $i*$num_col+$j];

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

########################connection between nodes###################
#$ns duplex-link-op $n0 $n2 orient right-down
#$ns duplex-link-op $n1 $n2 orient right-up
#$ns duplex-link-op $n2 $n3 orient right

#####  row connection ###########
set count 0
for {set i 0} {$count < [expr $num_row]} {set i [expr $i+$num_col]} {
	set count1 0
	for {set j $i} {$count1 < [expr $num_col-1]} {incr j} {
		set next1 [expr $j+1]
		#puts "connection $j $next1"
		$ns duplex-link $node_($j) $node_($next1) 2Mb 10ms DropTail
		$ns duplex-link-op $node_($j) $node_($next1) orient right
		$ns queue-limit $node_($j) $node_($next1) 1000
		#$ns duplex-link-op $node_($j) $node_($next1) queuePos 0.5
		incr count1
	}
	incr count
}

######   column connection ######
for {set i 0} {$i < $num_col} {incr i} {
	set count 0
	for {set j $i} {$count < [expr $num_row-1]} {set j [expr $j+$num_col]} {
		set next [expr $j+$num_col]
		#puts "connection $j $next"
		$ns duplex-link $node_($j) $node_($next) 2Mb 10ms DropTail
		$ns duplex-link-op $node_($j) $node_($next) orient up
		$ns queue-limit $node_($j) $node_($next) 1000
		#$ns duplex-link-op $node_($j) $node_($next) queuePos 0.5
		incr count
	}
}
#set num_node [expr $num_row*$num_col]
#for {set i 0} {$i < $num_node} {incr i} {

#		set next [expr ($i+1)%$num_node]
		#puts "connection $i $next"
#		$ns duplex-link $node_($i) $node_($next) 2Mb 10ms DropTail
#		$ns duplex-link-op $node_($i) $node_($next) orient right
#		$ns queue-limit $node_($i) $node_($next) 50

#}

puts "flows: $num_random_flow"

for {set i 0} {$i <  $num_random_flow} {incr i} {
	set udp_($i) [new $tcp_src]
	$udp_($i) set class_ $i
	# $ns  at  0.0  "plotWindow $udp_($i)  $conges_data"
	
	set null_($i) [new $tcp_sink]
	$udp_($i) set fid_ $i
}
#######################################################################RANDOM FLOW

set num_node [expr $num_row*$num_col]
for {set i 0} {$i < $num_random_flow } {incr i} {
	set udp_node [expr int($num_node*rand())] ;# src node
	set null_node $udp_node
	while {$null_node==$udp_node} {
		set null_node [expr int($num_node*rand())] ;# dest node
	}
	$ns attach-agent $node_($udp_node) $udp_($i)
  	$ns attach-agent $node_($null_node) $null_($i)
	puts -nonewline $topofile "RANDOM:  Src: $udp_node Dest: $null_node\n"

}

for {set i 0} {$i < $num_random_flow} {incr i} {
	$ns connect $udp_($i) $null_($i)
	$ns  at  0.0  "plotWindow $udp_($i)  $conges_data"
}

for {set i 0} {$i < $num_random_flow} {incr i} {
	set cbr_($i) [new Application/Traffic/CBR]
	$cbr_($i) set packetSize_ $cbr_size
	$cbr_($i) set rate_ $cbr_rate
	$cbr_($i) set interval_ $cbr_interval
	$cbr_($i) attach-agent $udp_($i)
}

for {set i 0} {$i < $num_random_flow} {incr i} {
	$ns at [expr $start_time] "$cbr_($i) start"

}

puts "flow creation complete"
##########################################################################END OF FLOW GENERATION
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
# $ns at [expr $start_time+$time_duration +$extra_time] "$ns nam-end-wireless [$ns now]; puts \"NS Exiting...\"; $ns halt"
$ns at [expr $start_time+$time_duration +$extra_time] "puts \"NS Exiting...\"; $ns halt"

$ns at [expr $start_time+$time_duration/2] "puts \"half of the simulation is finished\""
$ns at [expr $start_time+$time_duration] "puts \"end of simulation duration\""

proc finish {} {
	puts "finishing"
	global ns tracefd topofile
	# global ns tracefd namtrace topofile nm
	#global ns topofile
	$ns flush-trace
	close $tracefd
	# close $namtrace
	close $topofile
	#exec xgraph tcp_wireless.tr -geometry 800x400 &
        #exec nam $nm &
        exit 0
}
for {set i 0} {$i < [expr $num_row*$num_col]  } { incr i} {
	$ns initial_node_pos $node_($i) 4
}

puts "Starting Simulation..."
$ns run
#$ns nam-end-wireless [$ns now]