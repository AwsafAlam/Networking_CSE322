# We use AWK to parse the .tr file, and calculate variuous performance metrics. Some common metrics

# 1. Avg Throughput
# 2. instant Throughput
# 3. Packet Delivery ratio
# 4. Residual Energy of the nodes

# awk-> Aho Weinberger keningbrag
# use-newtrace in tcl, to get new format. It is easy to procss

#  In NS2 new trace format, there can be 52 columns. Each column satisfy some parameteers. See documenttion for more

BEGIN	{
    receive_size = 0;
    startTime = 1e6;
    stopTime = 0;
    NumOfRecPackt = 0;

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
# Only works for new trace format
{
    # $1 == 1st col etc,

    # event  = $1
    # time = $3
    # node_id= $5
    # packet = $19
    # pckt_id = $41
    # flow_id = $39
    # packet_size = $37
    # flow_type = $45

    event = $1 ;			time = $2 ;
	node = $3 ;
	strAgt = $4 ;			idPacket = $6 ;
	strType = $7 ;			nBytes = $8;

	energy = $13;			total_energy = $14;
	idle_energy_consumption = $16;	sleep_energy_consumption = $18; 
	transmit_energy_consumption = $20;	receive_energy_consumption = $22; 
	num_retransmit = $30;

    sub(/^_*/, "", node);
	sub(/_*$/, "", node);

    # if(packet == "AGT" && sendTime[pckt_id] == 0 && (event == "+" || event == "s")){
    #     if(time < startTime){
    #         startTime = time;
    #     }
    #     sendTime[pckt_id] = time;
    #     this_flow = flow_type;
    # }

    # if(packet == "AGT"  && event == "r" ){
    #     if(time > stopTime){
    #         stopTime = time;
    #     }
    #     receive_size += packet_size;
    #     recvTime[pckt_id] = time
    #     NumOfRecPackt ++;
    # }

    if (energy == "[energy") {
		energy_consumption[node] = (idle_energy_consumption + sleep_energy_consumption + transmit_energy_consumption + receive_energy_consumption);
#		printf("%d %15.5f\n", node, energy_consumption[node]);
	}

	if( 0 && temp <=25 && energy == "[energy" && event == "D") {
		# printf("%s %15.5f %d %s %15.5f %15.5f %15.5f %15.5f %15.5f \n", event, time, idPacket, energy, total_energy, idle_energy_consumption, sleep_energy_consumption, transmit_energy_consumption, receive_energy_consumption);
		temp+=1;
	}

	if ( strAgt == "AGT" ) {
		if (idPacket > idHighestPacket) idHighestPacket = idPacket;
		if (idPacket < idLowestPacket) idLowestPacket = idPacket;

		if(time>rEndTime) rEndTime=time;
        # printf("********************\n");
		if(time<rStartTime) {
			# printf("********************\n");
			# printf("%10.0f %10.0f %10.0f\n",time, node, idPacket);
			rStartTime=time;
		}

		if ( event == "s" ) {
			nSentPackets += 1 ;	rSentTime[ idPacket ] = time ;
			# printf("%15.5f\n", nSentPackets);
		}
#		if ( event == "r" ) {
		if ( event == "r" && idPacket >= idLowestPacket) {
			nReceivedPackets += 1 ;		nReceivedBytes += (nBytes-header);
			# printf("%15.0f\n", $6); #nBytes);
			rReceivedTime[ idPacket ] = time ;
			rDelay[idPacket] = rReceivedTime[ idPacket] - rSentTime[ idPacket ];
			# rTotalDelay += rReceivedTime[ idPacket] - rSentTime[ idPacket ];
			rTotalDelay += rDelay[idPacket]; 

#			printf("%15.5f   %15.5f\n", rDelay[idPacket], rReceivedTime[ idPacket] - rSentTime[ idPacket ]);
		}
	}

	if( event == "D")
	{
		if(time>rEndTime) rEndTime=time;
#		if(time<rStartTime) rStartTime=time;
		nDropPackets += 1;
	}

	if( strType == "tcp" )
	{
#		printf("%d \n", idPacket);
#		printf("%d %15d\n", idPacket, num_retransmit);
		retransmit[idPacket] = num_retransmit;		
	}
	
	# if(time<rStartTime) rStartTime=time;
	if(time>rEndTime) rEndTime=time;


}
END {
    if(nReceivedBytes == 0)
    {
        printf("No packets \n");

    }

    time = rEndTime - rStartTime ;
	rThroughput = (nReceivedBytes)/time*(8/1000);
	rPacketDeliveryRatio = nReceivedPackets / nSentPackets * 100 ;
	rPacketDropRatio = nDropPackets / nSentPackets * 100;

    printf(" Start Time: %d\n", rStartTime); 
    printf(" Stop Time: %d\n", rEndTime); 
    printf(" Packets: %d\n", nReceivedBytes); 
    # time = (stopTime - startTime);
    # printf(" Throughput in  kbps: %f \n", (NumOfRecPackt)/time*(8/1000)); 
    printf(" Throughput in  kbps: %f \n", rThroughput); 

for(i=0; i<max_node;i++) {
#		printf("%d %15.5f\n", i, energy_consumption[i]);
		total_energy_consumption += energy_consumption[i];
	}
	if ( nReceivedPackets != 0 ) {
		rAverageDelay = rTotalDelay / nReceivedPackets ;
		avg_energy_per_packet = total_energy_consumption / nReceivedPackets ;
	}

	if ( nReceivedBytes != 0 ) {
		avg_energy_per_byte = total_energy_consumption / nReceivedBytes ;
		avg_energy_per_bit = avg_energy_per_byte / 8;
		rEnergyEfficeincy = total_energy_consumption / (nReceivedBytes*8);
	}

	for (i=0; i<max_pckt; i++) {
		total_retransmit += retransmit[i] ;		
#		printf("%d %15.5f\n", i, retransmit[i]);
	}

#	printf( "AverageDelay: %15.5f PacketDeliveryRatio: %10.2f\n", rAverageDelay, rPacketDeliveryRatio ) ;


	# printf( "%15.2f\n%15.5f\n%15.2f\n%15.2f\n%15.2f\n%10.2f\n%10.2f\n%10.5f\n", rThroughput, rAverageDelay, nSentPackets, nReceivedPackets, nDropPackets, rPacketDeliveryRatio, rPacketDropRatio,rTime) ;
	# printf("%15.5f\n%15.5f\n%15.5f\n%15.5f\n%15.0f\n%15.9f\n", total_energy_consumption, avg_energy_per_bit, avg_energy_per_byte, avg_energy_per_packet, total_retransmit, rEnergyEfficeincy);
    # Printing individually
    # printf( "Throughput: %15.2f",rThroughput);
    printf( "AverageDelay: %15.5f\n",rAverageDelay);
    printf( "SentPackets: %15.2f\n",nSentPackets);
    printf( "ReceivedPackets: %15.2f\n",nReceivedPackets);
    printf( "DropPackets: %15.2f\n",nDropPackets);
    printf( "PacketDeliveryRatio: %10.2f\n",rPacketDeliveryRatio);
    printf( "PacketDropRatio: %10.2f\n",rPacketDropRatio);
    
    printf("**********************\nEnergy:\n");
    printf( "Total Energy Consumption: %15.2f\n",total_energy_consumption);
    printf( "avg_energy_per_bit: %15.5f\n",avg_energy_per_bit);
    printf( "avg_energy_per_byte: %15.2f\n",avg_energy_per_byte);
    printf( "avg_energy_per_packet: %15.2f\n",avg_energy_per_packet);
    printf( "total_retransmit: %15.2f\n",total_retransmit);
    printf( "Energy Efficeincy: %10.2f\n",rEnergyEfficeincy);
    
}