#INPUT: output file AND number of iterations
# ./cleanup.sh
clear
output_file_format="wireless_mobile"
iteration_float=1.0
iteration=$(printf %.0f $iteration_float);

rootDir=~/Documents/ns_mod/ns-allinone-2.35/ns-2.35/

printf "For Existing press 1\n\
For modification press 0\n-------------------\n"
read mod

if [ $mod -eq 1 ]; then
ns_ver=ns
else
ns_ver=./ns
fi

printf "Choose Network Topology \n-------------------\n\
1 - Wireless 802.11 (mobile)\n\
2 - Wireless 802.15.4 (mobile)\n\
3 - Wimax 802.16\n\
4 - Wired\n-------------\n"
read option


printf "Choose Variation \n-------------------\n\
1. Number of mobile nodes\n\
2. Number of flows\n\
3. Number of packets per second\n\
4. Speed of the mobile nodes\n\
5. Packet Size\n\
6. Grid/Hop distance\n--------------\n"
read p


######## parameter initialization ##########
hop_15_4=5
dist_15_4=30
dist_11=$(($hop_15_4*$dist_15_4*2))
pckt_size=64
pckt_per_sec=500
# pckt_interval=[expr 1 / $pckt_per_sec]
# echo "INERVAL: $pckt_interval"
row=5
flow_no=5
speed=25
qlen=50
datapoints=3

# === Simulation file
if [ $option -eq 1 ] 
then
tcl=802_11.tcl
awk_file=awk_tcp.awk
dist=$dist_11
elif [ $option -eq 2 ] 
then
tcl=802_15_4.tcl
awk_file=awk_tcp.awk
dist=$dist_15_4
elif [ $option -eq 3 ]; then
# ./ns test-be-mod.tcl 1 2 ul 300
# cd ~/Documents/ns_mod/ns-allinone-2.35/ns-2.35/
# Execute awk for wimax
rootDir=~/Documents/ns_wimax/ns-allinone-2.35/ns-2.35/
tcl=802_16.tcl
awk_file=awk_wimax.awk
dist=$dist_11

elif [ $option -eq 4 ]; then
tcl=wired.tcl
awk_file=wired.awk
dist=$dist_11

fi

#Copying latest files
cp -f $tcl $rootDir
cp -f $awk_file $rootDir

# Moving to Modified NS dir
cd $rootDir
#Cleanup
# rm *.out
# rm *.tr
# rm plot.plt
# clear

# ============== Graph init
echo "set   autoscale" >> plot.plt
echo "set terminal pdf" >> plot.plt
echo "set output \"$tcl.$p.$mod.pdf\"" >> plot.plt
echo "set title \"$tcl Comparing metrics with variation in $metric\"" >> plot.plt
echo "set xlabel \"Node\"" >> plot.plt


for((r=1;r<=$datapoints;r++));
do

echo "total iteration: $iteration"
#=============================  START A ROUND

l=0;thr=0.0;del=0.0;s_packet=0.0;r_packet=0.0;d_packet=0.0;del_ratio=0.0;failcount=0;
dr_ratio=0.0;time=0.0;t_energy=0.0;energy_bit=0.0;energy_byte=0.0;energy_packet=0.0;total_retransmit=0.0;energy_efficiency=0.0;
awkval=0.0;

i=0

if [ $p -eq 1 ]; then
echo "------------- VARIAION IN NODE NUMBER -----------------";
metric="Number of Nodes"
row=$(($r*2))
vari=$(($row*$row))
elif [ $p -eq 2 ]; then
echo "------------- VARIAION IN FLOW -----------------";
metric="Number of Flows"
flow_no=$(($r*2))
vari=$flow_no
elif [ $p -eq 3 ]; then
echo "------------- VARIAION IN PACKET PER SEC -----------------";
metric="Packets per second"
pckt_per_sec=$(($r*100))
vari=$pckt_per_sec
elif [ $p -eq 4 ]; then
echo "------------- VARIAION IN SPEED -----------------";
metric=Speed
speed=$(($r*5))
vari=$speed
elif [ $p -eq 5 ]; then
echo "------------- VARIAION IN Packet Size -----------------";
metric="Packet Size"
pckt_size=$(($r*12))
vari=$pckt_size
elif [ $p -eq 6 ]; then
echo "------------- VARIAION IN Grid/Hop distance -----------------";
metric="Grid Dimension"
dist=$((10 + $dist))
vari=$dist
fi

	while [ $i -lt $iteration ]
	do
	#################START AN ITERATION #############
	echo "		EXECUTING $(($i+1)) th ITERATION"

	if [ `echo $i%2 | bc` -eq 0 ]
	then
		topology=1 # Grid
		# routing=DSDV
	else
		topology=0 # Random
		# routing=AODV
	fi

	# ns 802_11.tcl $start # $dist_11 $pckt_size $pckt_per_sec $routing $time_sim
	echo "Row : $row"
	echo "Flow : $flow_no"
	echo "Speed: $speed"

	$ns_ver $tcl $row $topology $flow_no $speed $dist $pckt_size $pckt_per_sec #$qlen #$routing $time_sim
	# echo "Executing $ns_ver $tcl $row $topology $flow_no $speed $dist $pckt_size $pckt_per_sec"
	# ns $tcl $row $topology $flow_no $speed $dist $pckt_size $pckt_per_sec $qlen #$routing $time_sim
	echo "SIMULATION COMPLETE. BUILDING STAT......"
	under="_"
	awk -f $awk_file trace.tr > "$output_file_format$under$i$under$r.out"

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
		else
			temp=$(($l - 14))
			awkval=$(echo "scale=5; $awkval+$val/$iteration_float" | bc)
			per_node[$temp]=$awkval
		fi

		# echo "$val"

	done < "$output_file_format$under$i$under$r.out"

	if [ $failcount -ge 3 ]; then
		echo "********************* Failed to generated output ***************\n";
		break;
	fi

	if [ "$ok" -eq "0" ]; then
		l=0;
		ok=1;
		continue
	fi
	
	# value of single iteration obtained here.
	# mv "conges_data.txt" "conges_data_$i$under$r.$vari.out"
	# sort "conges_data_$i$under$r.$vari.out" | uniq -u
	uniq "conges_data.txt" "conges_data_$i$under$r.$vari.out"

	#################END AN ITERATION
	i=$(($i+1))
	l=0
	done
	# uniq "conges_data.txt" "conges_data_$i$under$r.$vari.out" # Plotting for last iteration only
  
	enr_nj=$(echo "scale=2; $energy_efficiency*1000.0" | bc)
	# total_retransmit=$(echo "scale=3; $total_retransmit/100.0" | bc)

	dir=""
	under="_"

	output_file2="$dir$output_file_format$under.out"
	output_file="data_$p.out"
	thruput_pernode="perNode_$r.out"
	# echo "------------- VARIAION IN $metric -----------------";
	echo -ne "$vari " >> $output_file
	echo -ne "$vari " >> $output_file2


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

	echo -ne "$thr " >> $output_file
	echo -ne "$del " >> $output_file
	# echo -ne "$s_packet " >> $output_file
	# echo -ne "$r_packet " >> $output_file
	# echo -ne "$d_packet " >> $output_file
	echo -ne "$del_ratio " >> $output_file
	echo -ne "$dr_ratio " >> $output_file
	echo -ne "$time " >> $output_file
	echo -ne "$t_energy " >> $output_file
	# echo -ne "$energy_bit " >> $output_file
	# echo -ne "$energy_byte " >> $output_file
	echo -ne "$energy_packet " >> $output_file
	echo -ne "$total_retransmit " >> $output_file
	echo -ne "$enr_nj " >> $output_file
	echo "" >> $output_file

	
	for((t=0;t<$vari;t++));
	do
		echo "$t ${per_node[$t]}" >> $thruput_pernode
		
	done
	
	####################################### END A ROUND
	echo "plot \"$thruput_pernode\" using 1:2 title '$vari $metric' with linespoints lw 2" >> plot.plt
done

echo " Generating graphs ... for $p"

echo "set title \"$tcl Comparing metrics with variation in $metric\"" >> plot.plt
echo "set xlabel \"$metric\"" >> plot.plt

echo "set ylabel \"Throughput\"" >> plot.plt
echo "plot \"data_$p.out\" using 1:2 title 'Throughput' with linespoints lw 2" >> plot.plt
echo "set ylabel \"Sent Packets\"" >> plot.plt
echo "plot \"data_$p.out\" using 1:3 title 'Avg delay' with linespoints lw 2" >> plot.plt
# echo "set ylabel \"Sent Packets\"" >> plot.plt
# echo "plot \"data_$p.out\" using 1:4 title 'Sent Packets' with linespoints lw 2" >> plot.plt
# echo "set ylabel \"Received Packets\"" >> plot.plt
# echo "plot \"data_$p.out\" using 1:5 title 'Received Packets' with linespoints lw 2" >> plot.plt
# echo "set ylabel \"Dropped packets\"" >> plot.plt
# echo "plot \"data_$p.out\" using 1:6 title 'Dropped packets' with linespoints lw 2" >> plot.plt
echo "set ylabel \"Packet delivery Ratio\"" >> plot.plt
echo "plot \"data_$p.out\" using 1:4 title 'Packet delivery Ratio' with linespoints lw 2" >> plot.plt
echo "set ylabel \"Packet Drop Ratio\"" >> plot.plt
echo "plot \"data_$p.out\" using 1:5 title 'Packet Drop Ratio' with linespoints lw 2" >> plot.plt

echo "set title \"$tcl Comparing Energy variation\"" >> plot.plt
echo "set ylabel \"Total Energy\"" >> plot.plt
echo "plot \"data_$p.out\" using 1:7 title 'Total Energy' with linespoints lw 2" >> plot.plt 
# echo "set ylabel \"Energy Per bit\"" >> plot.plt
# echo "plot \"data_$p.out\" using 1:11 title 'Energy Per bit' with linespoints lw 2" >> plot.plt
# echo "set ylabel \"Energy Per Byte\"" >> plot.plt
# echo "plot \"data_$p.out\" using 1:12 title 'Energy Per Byte' with linespoints lw 2" >> plot.plt
echo "set ylabel \"Energy Per Packet\"" >> plot.plt
echo "plot \"data_$p.out\" using 1:8 title 'Energy Per Packet' with linespoints lw 2" >> plot.plt
echo "set ylabel \"Total retransmit\"" >> plot.plt
echo "plot \"data_$p.out\" using 1:9 title 'Total retransmit' with linespoints lw 2" >> plot.plt
echo "set ylabel \"Efficiency\"" >> plot.plt
echo "plot \"data_$p.out\" using 1:10 title 'Efficiency' with linespoints lw 2" >> plot.plt

echo "set title \"$tcl Comparing variation in congestion window size with time\"" >> plot.plt
echo "set xlabel \"Time\"" >> plot.plt
echo "set ylabel \"Congestion Window size\"" >> plot.plt
echo -ne "plot " >> plot.plt

find -iname "conges_data_*.out"| cut -c 3- | while read plt_flie
do
tmp=`echo "$plt_flie" | cut -d "." -f2`
# echo $tmp
echo -ne "\"$plt_flie\" using 1:2  with lines title \"$tmp $metric\", " >> plot.plt

done
echo "" >> plot.plt

find -iname "conges_data_*.out"| cut -c 3- | while read plt_flie
do
tmp=`echo "$plt_flie" | cut -d "." -f2`
# echo $tmp
echo "plot \"$plt_flie\" using 1:2  with lines title \"$tmp $metric\" lw 2, " >> plot.plt

done

echo "Plot file generation complete ..."

gnuplot plot.plt
echo "Graph generation complete ..."

rm $tcl
rm $awk_file
rm *.out
rm *.tr
rm plot.plt
# rm *.txt
mv "$tcl.$p.$mod.pdf" ~/Desktop/Networking_CSE322/NS2/Offline/1505114
cd ~/Desktop/Networking_CSE322/NS2/Offline/1505114
evince "$tcl.$p.$mod.pdf"
