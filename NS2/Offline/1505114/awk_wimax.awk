BEGIN {
     
     max_node = 2000;
	nSentPackets = 0.0 ;		
	nReceivedPackets = 0.0 ;
	rTotalDelay = 0.0 ;
	max_pckt = 10000;

	header = 20;	

	idHighestPacket = 0;
	idLowestPacket = 100000;
	rStartTime = 10000.0;
	rEndTime = 0.0;
	nReceivedBytes = 0;
	rEnergyEfficeincy = 0;

	nDropPackets = 0.0;

	total_energy_consumption = 0;

	temp = 0;
	
	for (i=0; i<max_node; i++) {
		energy_consumption[i] = 0;		
	}

	total_retransmit = 0;
	for (i=0; i<max_pckt; i++) {
		retransmit[i] = 0;		
	}

}
   
{
     # event = $1; time = $3; node_id = $9; pkt_size = $37; level = $19

    strEvent = $1;      idPacket = $41; 
    rTime = $3
    node = $9
    pkt_size = $37
    strAgt = $19; # Trace level/ Agent
    strType = $35

    # strEvent = $1 ;			rTime = $2 ;
	# node = $3 ;
	# strAgt = $4 ;			idPacket = $6 ;
	# strType = $7 ;			nBytes = $8;

	# energy = $13;			total_energy = $14;
	# idle_energy_consumption = $16;	sleep_energy_consumption = $18; 
	# transmit_energy_consumption = $20;	receive_energy_consumption = $22; 
	# num_retransmit = $30;
	
	
    # Store start rTime
#     if (strAgt == "AGT" && strEvent == "s" && pkt_size > 512) {
     if (strAgt == "AGT" && strType == "cbr" ) {
          if (rTime < rStartTime) {
             rStartTime = rTime
          }
          if (rTime > rEndTime) {
             rEndTime = rTime
          }
          if ( strEvent == "s" ) {
			nSentPackets += 1 ;	
               rSentTime[ idPacket ] = rTime ;
#			printf("%15.5f\n", nSentPackets);
		}
		if ( strEvent == "r" ) {
		# if ( strEvent == "r" && idPacket >= idLowestPacket) {
			nReceivedPackets += 1 ;		
               # Rip off the header
               hdr_size = pkt_size % 512
               pkt_size -= hdr_size
               # Store received packet's size
               nReceivedBytes += pkt_size
#			printf("%15.0f\n", $6); #nBytes);
			rReceivedTime[ idPacket ] = rTime ;
			rDelay[idPacket] = rReceivedTime[ idPacket] - rSentTime[ idPacket ];
			# rTotalDelay += rReceivedTime[ idPacket] - rSentTime[ idPacket ];
			rTotalDelay += rDelay[idPacket]; 

			# printf("%15.5f   %15.5f\n", rDelay[idPacket], rReceivedTime[ idPacket] - rSentTime[ idPacket ]);
		}
     }
   
     
    if( strEvent == "D"   &&   strType == "cbr" )
	{
		if(rTime>rEndTime) rEndTime=rTime;
#		if(rTime<rStartTime) rStartTime=rTime;
		nDropPackets += 1;
	}

     # if( strType == "tcp" )
	# {
	# 	retransmit[idPacket] = num_retransmit;		
	# }
  }
   
  END {
     
     rTime = rEndTime - rStartTime ;
     rThroughput = nReceivedBytes*8 / rTime;
	# rPacketDeliveryRatio = nReceivedPackets / nSentPackets * 100 ;

     if ( nReceivedPackets != 0 ) {
		rAverageDelay = rTotalDelay / nReceivedPackets ;
		# avg_energy_per_packet = total_energy_consumption / nReceivedPackets ;
	}

	printf( "%15.2f\n%15.5f\n%15.2f\n%15.2f\n", rThroughput, rAverageDelay, nReceivedPackets);
	# printf( "%15.2f\n%10.2f\n%10.2f\n%10.5f\n", nDropPackets, rPacketDeliveryRatio, rPacketDropRatio,rTime);
	
    #  printf( "AverageDelay: %15.5f\n",rAverageDelay);
    #  printf( "SentPackets: %15.2f\n",nSentPackets);
    #  printf( "ReceivedPackets: %15.2f\n",nReceivedPackets);
    #  printf( "DropPackets: %15.2f\n",nDropPackets);
    #  printf( "PacketDeliveryRatio: %10.2f\n",rPacketDeliveryRatio);
    #  printf( "Throughput: %15.2f\n",rThroughput);
	
    #    printf("Delay= %.2f\n StartTime=%.2f\tStopTime=%.2f\trec=%d\n",(rTotalDelay / nReceivedPackets),rStartTime,rEndTime,nReceivedBytes)

    #    printf("Average Throughput[kbps] = %.2f\t\t StartTime=%.2f\tStopTime=%.2f\n",(nReceivedBytes/(rEndTime-rStartTime))*(8/1000),rStartTime,rEndTime)
  }