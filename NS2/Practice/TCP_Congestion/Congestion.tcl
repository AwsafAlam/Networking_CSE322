#Make a NS simulator   
  set ns [new Simulator]	

  # Define a 'finish' procedure
  proc finish {} {
     exit 0
  }

  # Create the nodes:
  set n0 [$ns node]
  set n1 [$ns node]
  set n2 [$ns node]
  set n3 [$ns node]
  set n4 [$ns node]
  set n5 [$ns node]

  # Create the links:
  $ns duplex-link $n0 $n2   2Mb  10ms DropTail
  $ns duplex-link $n1 $n2   2Mb  10ms DropTail
  $ns duplex-link $n2 $n3 0.3Mb 200ms DropTail
  $ns duplex-link $n3 $n4 0.5Mb  40ms DropTail
  $ns duplex-link $n3 $n5 0.5Mb  30ms DropTail

  # Add a TCP sending module to node n0
  set tcp1 [new Agent/TCP/Reno]
  $ns attach-agent $n0 $tcp1

   # Add a TCP sending module to node n0
  set tcp2 [new Agent/TCP/Vegas]
  $ns attach-agent $n1 $tcp2

  # Add a TCP receiving module to node n4
  set sink1 [new Agent/TCPSink]
  $ns attach-agent $n4 $sink1

  set sink2 [new Agent/TCPSink]
  $ns attach-agent $n3 $sink2

  # Direct traffic from "tcp1" to "sink1"
  $ns connect $tcp1 $sink1
  $ns connect $tcp2 $sink2

  # Setup a FTP traffic generator on "tcp1"
  set ftp1 [new Application/FTP]
  $ftp1 attach-agent $tcp1
  $ftp1 set type_ FTP              ;# (no necessary)

   set ftp2 [new Application/FTP]
  $ftp2 attach-agent $tcp2

  # Schedule start/stop times
  $ns at 0.1   "$ftp1 start"
  $ns at 100.0 "$ftp1 stop"

  $ns at 0.1   "$ftp2 start"
  $ns at 100.0 "$ftp2 stop"

  # Set simulation end time
  $ns at 125.0 "finish"		    ;#(Will invoke "exit 0")   


  ##################################################
  ## Obtain CWND from TCP agent
  ##################################################

  proc plotWindow {tcpSource outfile} {
     global ns

     set now [$ns now]
     set cwnd [$tcpSource set cwnd_]

  ###Print TIME CWND   for  gnuplot to plot progressing on CWND
     puts  $outfile  "$now $cwnd"

     $ns at [expr $now+0.1] "plotWindow $tcpSource  $outfile"
  }
   set reno [open reno_data.txt w]
   set vegas [open vegas_data.txt w]

  $ns  at  0.0  "plotWindow $tcp1  $reno" 
  $ns  at  0.0  "plotWindow $tcp2  $vegas" 

  # Run simulation !!!!
  $ns run