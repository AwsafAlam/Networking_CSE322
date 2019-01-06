#creating New ns simulaor

set ns [new Simulator]

set nm [open out.nam w]
$ns namtrace-all $nm

proc finish {} \
{ 
	global ns nm 
	$ns flush-trace 
	
	# Close the NAM trace file 
	close $nm 
	
	# Execute NAM on the trace file 
	exec nam out.nam & 
	exit 0
}

#creating nodes
# 4 nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]

# Link between nodes
# For wired connection

$ns duplex-link $n0 $n1 2Mb 20ms DropTail
$ns duplex-link $n0 $n2 2Mb 20ms DropTail
$ns duplex-link $n1 $n3 2Mb 20ms DropTail
$ns duplex-link $n3 $n2 2Mb 20ms DropTail
$ns duplex-link $n2 $n1 2Mb 20ms DropTail

#creating traffic----
set src [new Agent/TCP]
$ns attach-agent $n0 $src

set sink [new Agent/TCPSink]
$ns attach-agent $n3 $sink

$ns connect $src $sink

# ftp- layer
# Applcation layer
set ftp [new Application/FTP]
$ftp attach-agent $src
$ftp set type_ FTP


#simulation---------------
$ns at 1.0 "$ftp start"
$ns at 4.0 "$ftp stop"
$ns at 5.0 "finish"

$ns run