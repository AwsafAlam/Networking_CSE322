BEGIN {
       recvdSize = 0
       startTime = 400
       stopTime = 0
  }
   
{
    strEvent = $1;      #idPacket = 
    rTime = $3
    node = $9
    pkt_size = $37
    strAgt = $19
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
        if (rTime < startTime) {
             startTime = rTime
        }
        if (rTime > stopTime) {
             stopTime = rTime
             }
    }
   
  # Update total received packets' size and store packets arrival rTime
  if (strAgt == "AGT" && strEvent == "r" && pkt_size > 512) {
     #   printf("rTime %.2f\n",rTime);
       if (rTime > stopTime) {
             stopTime = rTime
             }
       # Rip off the header
       hdr_size = pkt_size % 512
       pkt_size -= hdr_size
       # Store received packet's size
       recvdSize += pkt_size
       }

    
  }
   
  END {
       printf(" StartTime=%.2f\tStopTime=%.2f\n",startTime,stopTime)

       printf("Average Throughput[kbps] = %.2f\t\t StartTime=%.2f\tStopTime=%.2f\n",(recvdSize/(stopTime-startTime))*(8/1000),startTime,stopTime)
  }