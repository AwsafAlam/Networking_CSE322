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
}
# Only works for new trace format
{
    # $1 == 1st col etc,

    event  = $1
    time = $3
    node_id= $5
    packet = $19
    pckt_id = $41
    flow_id = $39
    packet_size = $37
    flow_type = $45

    if(packet == "AGT" && sendTime[pckt_id] == 0 && (event == "+" || event == "s")){
        if(time < startTime){
            startTime = time;
        }
        sendTime[pckt_id] = time;
        this_flow = flow_type;
    }

    if(packet == "AGT"  && event == "r" ){
        if(time > stopTime){
            stopTime = time;
        }
        receive_size += packet_size;
        recvTime[pckt_id] = time
        NumOfRecPackt ++;
    }

}
END {
    if(NumOfRecPackt == 0)
    {
        printf("No packets \n");

    }

    printf(" Start Time: %d\n", startTime); 
    printf(" Stop Time: %d\n", stopTime); 
    printf(" Packets: %d\n", NumOfRecPackt); 
    rTime = (stopTime - startTime);
    printf(" Throughput in  kbps: %f \n", (NumOfRecPackt)/rTime*(8/1000)); 

}