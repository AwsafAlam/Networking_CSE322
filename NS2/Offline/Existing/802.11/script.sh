#INPUT: output file AND number of iterations
./cleanup.sh
clear

output_file_format="wireless_802.11_mobile"
iteration_float=2.0

start=5
end=5

hop_15_4=5
dist_15_4=30
dist_11=$ expr $hop_15_4*$dist_15_4*2
pckt_size=64
pckt_per_sec=500
# pckt_interval=[expr 1 / $pckt_per_sec]
# echo "INERVAL: $pckt_interval"

routing=DSDV
row=10
topology=1 # Grid
flow_no=5
speed=25
time_sim=25

iteration=$(printf %.0f $iteration_float);

r=1

while [ $r -le $end ]
do
echo "total iteration: $iteration"
###############################START A ROUND

l=0;thr=0.0;del=0.0;s_packet=0.0;r_packet=0.0;d_packet=0.0;del_ratio=0.0;failcount=0;
dr_ratio=0.0;time=0.0;t_energy=0.0;energy_bit=0.0;energy_byte=0.0;energy_packet=0.0;total_retransmit=0.0;energy_efficiency=0.0;

i=0
row=$(($r*2))

while [ $i -lt $iteration ]
do
#################START AN ITERATION
echo "                             EXECUTING $(($i+1)) th ITERATION"

if [ `echo $i%2 | bc` -eq 0 ] 
then
	topology=1 # Grid
else
	topology=0 # Random
fi

# ns 802_11.tcl $start # $dist_11 $pckt_size $pckt_per_sec $routing $time_sim
echo "Row : $row"
ns 802_11_udp.tcl $row #$topology $flow_no $speed $pckt_per_sec $time_sim
echo "SIMULATION COMPLETE. BUILDING STAT......"
under="_"
awk -f 802_11_udp.awk 802_11_wireless.tr > "$output_file_format$under$r$under$i.out"

ok=1;
	while read val
	do
		l=$(($l+1))

		if [ "$l" == "1" ]; then
			if [ `echo "if($val > 0.0) 1; if($val <= 0.0) 0" | bc` -eq 0 ]; then
				failcount=$(($failcount+1))
				ok=0;
				break
			fi	
		# calculating throughput -> Scale=5 represents 5 decimal places, | bc is a inline-commandd-line-calculator
			thr=$(echo "scale=5; $thr+$val/$iteration_float" | bc)
	#		echo -ne "throughput: $thr "
		elif [ "$l" == "2" ]; then
			del=$(echo "scale=5; $del+$val/$iteration_float" | bc)
	#		echo -ne "delay: "
		elif [ "$l" == "3" ]; then
			s_packet=$(echo "scale=5; $s_packet+$val/$iteration_float" | bc)
	#		echo -ne "send packet: "
		elif [ "$l" == "4" ]; then
			r_packet=$(echo "scale=5; $r_packet+$val/$iteration_float" | bc)
	#		echo -ne "received packet: "
		elif [ "$l" == "5" ]; then
			d_packet=$(echo "scale=5; $d_packet+$val/$iteration_float" | bc)
	#		echo -ne "drop packet: "
		elif [ "$l" == "6" ]; then
			del_ratio=$(echo "scale=5; $del_ratio+$val/$iteration_float" | bc)
	#		echo -ne "delivery ratio: "
		elif [ "$l" == "7" ]; then
			dr_ratio=$(echo "scale=5; $dr_ratio+$val/$iteration_float" | bc)
	#		echo -ne "drop ratio: "
		elif [ "$l" == "8" ]; then
			time=$(echo "scale=5; $time+$val/$iteration_float" | bc)
	#		echo -ne "time: "
		elif [ "$l" == "9" ]; then
			t_energy=$(echo "scale=5; $t_energy+$val/$iteration_float" | bc)
	#		echo -ne "total_energy: "
		elif [ "$l" == "10" ]; then
			energy_bit=$(echo "scale=5; $energy_bit+$val/$iteration_float" | bc)
	#		echo -ne "energy_per_bit: "
		elif [ "$l" == "11" ]; then
			energy_byte=$(echo "scale=5; $energy_byte+$val/$iteration_float" | bc)
	#		echo -ne "energy_per_byte: "
		elif [ "$l" == "12" ]; then
			energy_packet=$(echo "scale=5; $energy_packet+$val/$iteration_float" | bc)
	#		echo -ne "energy_per_packet: "
		elif [ "$l" == "13" ]; then
			total_retransmit=$(echo "scale=5; $total_retransmit+$val/$iteration_float" | bc)
	#		echo -ne "total_retrnsmit: "
		elif [ "$l" == "14" ]; then
			energy_efficiency=$(echo "scale=9; $energy_efficiency+$val/$iteration_float" | bc)
	#		echo -ne "energy_efficiency: "
		fi


		echo "$val"

	done < "$output_file_format$under$r$under$i.out"

if [ $failcount -ge 3 ] 
then
	echo "********************* Failed to generated output ***************\n";
	break;
fi

if [ "$ok" -eq "0" ]; then
	l=0;
	ok=1;
	continue
fi
i=$(($i+1))
l=0

# value of single iteration obtained here.

#################END AN ITERATION
done

enr_nj=$(echo "scale=2; $energy_efficiency*1000.0" | bc)
total_retransmit=$(echo "scale=3; $total_retransmit/100.0" | bc)

dir=""
under="_"

output_file2="$dir$output_file_format$under.out"
output_file="data.out"

echo -ne "Throughput:          $thr " >> $output_file2
echo -ne "AverageDelay:         $del " >> $output_file2
echo -ne "Sent Packets:         $s_packet " >> $output_file2
echo -ne "Received Packets:         $r_packet " >> $output_file2
echo -ne "Dropped Packets:         $d_packet " >> $output_file2
echo -ne "PacketDeliveryRatio:      $del_ratio " >> $output_file2
echo -ne "PacketDropRatio:      $dr_ratio " >> $output_file2
echo -ne "Total time:  $time " >> $output_file2
echo -ne "" >> $output_file2
echo -ne "" >> $output_file2
echo -ne "Total energy consumption:        $t_energy " >> $output_file2
echo -ne "Average Energy per bit:         $energy_bit " >> $output_file2
echo -ne "Average Energy per byte:         $energy_byte " >> $output_file2
echo -ne "Average energy per packet:         $energy_packet " >> $output_file2
echo -ne "total_retransmit:         $total_retransmit " >> $output_file2
echo -ne "energy_efficiency(nj/bit):         $enr_nj " >> $output_file2
echo "" >> $output_file2

echo -ne "$(($row*$row)) " >> $output_file
echo -ne "$thr " >> $output_file
echo -ne "$del " >> $output_file
echo -ne "$s_packet " >> $output_file
echo -ne "$r_packet " >> $output_file
echo -ne "$d_packet " >> $output_file
echo -ne "$del_ratio " >> $output_file
echo -ne "$dr_ratio " >> $output_file
echo -ne "$time " >> $output_file
echo -ne "$t_energy " >> $output_file
echo -ne "$energy_bit " >> $output_file
echo -ne "$energy_byte " >> $output_file
echo -ne "$energy_packet " >> $output_file
echo -ne "$total_retransmit " >> $output_file
echo -ne "$enr_nj " >> $output_file
echo "" >> $output_file
r=$(($r+1))
#######################################END A ROUND
done

echo "Generating graphs ..."
gnuplot plot.plt
gnuplot plot_pdf.plt

echo "Evaluation complete ..."
