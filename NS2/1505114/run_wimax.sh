#INPUT: output file AND number of iterations
# ./cleanup.sh
rm data.out
rm trace.tr
rm wimax.pdf
rm plot.plt

clear
output_file=data.out

# ============== Graph init
echo "set autoscale" >> plot.plt
echo "set terminal pdf" >> plot.plt
echo "set output \"wimax.pdf\"" >> plot.plt

for((r=1;r<=5;r++));
do
var=$r #No. of nodes
grid=1
flow=5
speed=25
dimension=150
packet_size=64
pckt_per_sec=500

./ns 802_16.tcl $r $grid $flow $speed $dimension $packet_size $pckt_per_sec

awk -f awk_wimax.awk trace.tr > "$r.out"

echo -ne "$var " >> $output_file
l=0
while read val
do
	l=$(($l+1))

	if [ "$l" == "1" ]; then
		if [ `echo "if($val > 0.0) 1; if($val <= 0.0) 0" | bc` -eq 0 ]; then
			failcount=$(($failcount+1))
			ok=0;
			break
		fi	
		echo -ne "$val " >> $output_file
	elif [ "$l" == "2" ]; then
		echo -ne "$val " >> $output_file
	elif [ "$l" == "3" ]; then
		echo -ne "$val " >> $output_file
	fi

	echo "$val"

	done < "$r.out"
	
	echo "" >> $output_file

done
echo "set title \"$tcl Comparing metrics with variation in $metric\"" >> plot.plt
echo "set xlabel \"$metric\"" >> plot.plt


echo "set ylabel \"Throughput\"" >> plot.plt
echo "plot \"data.out\" using 1:2 title 'Throughput' with linespoints lw 2" >> plot.plt
echo "set ylabel \"Avg Delay\"" >> plot.plt
echo "plot \"data.out\" using 1:3 title 'Avg delay' with linespoints lw 2" >> plot.plt
echo "set ylabel \"Received Packets\"" >> plot.plt
echo "plot \"data.out\" using 1:4 title 'Received Packets' with linespoints lw 2" >> plot.plt
echo "" >> plot.plt

echo "Plot file generation complete ..."

gnuplot plot.plt
echo "Graph generation complete ..."
evince wimax.pdf


# printf "Choose Variation \n-------------------\n\
# 1. Number of mobile nodes\n\
# 2. Number of flows\n\
# 3. Number of packets per second\n\
# 4. Speed of the mobile nodes\n\
# 5. Packet Size\n\
# 6. Grid/Hop distance\n--------------\n"
# read p


# ######## parameter initialization ##########
# hop_15_4=5
# dist_15_4=30
# dist_11=$(($hop_15_4*$dist_15_4*2))
# pckt_size=64
# pckt_per_sec=500
# # pckt_interval=[expr 1 / $pckt_per_sec]
# # echo "INERVAL: $pckt_interval"
# row=5
# flow_no=5
# speed=25
# qlen=50
# datapoints=3

# tcl=802_16.tcl
# awk_file=awk_wimax.awk
# dist=$dist_11




# for((r=1;r<=$datapoints;r++));
# do

# echo "total iteration: $iteration"
# #=============================  START A ROUND

# l=0;thr=0.0;del=0.0;s_packet=0.0;r_packet=0.0;d_packet=0.0;del_ratio=0.0;failcount=0;
# dr_ratio=0.0;time=0.0;t_energy=0.0;energy_bit=0.0;energy_byte=0.0;energy_packet=0.0;total_retransmit=0.0;energy_efficiency=0.0;

# i=0

# if [ $p -eq 1 ]; then
# echo "------------- VARIAION IN NODE NUMBER -----------------";
# metric="Number of Nodes"
# row=$(($r))
# vari=$(($row*$row))
# elif [ $p -eq 2 ]; then
# echo "------------- VARIAION IN FLOW -----------------";
# metric="Number of Flows"
# flow_no=$(($r*2))
# vari=$flow_no
# elif [ $p -eq 3 ]; then
# echo "------------- VARIAION IN PACKET PER SEC -----------------";
# metric="Packets per second"
# pckt_per_sec=$(($r*100))
# vari=$pckt_per_sec
# elif [ $p -eq 4 ]; then
# echo "------------- VARIAION IN SPEED -----------------";
# metric=Speed
# speed=$(($r*5))
# vari=$speed
# elif [ $p -eq 5 ]; then
# echo "------------- VARIAION IN Packet Size -----------------";
# metric="Packet Size"
# pckt_size=$(($r*12))
# vari=$pckt_size
# elif [ $p -eq 6 ]; then
# echo "------------- VARIAION IN Grid/Hop distance -----------------";
# metric="Grid Dimension"
# dist=$((10 + $dist))
# vari=$dist
# fi

# 	while [ $i -lt $iteration ]
# 	do
# 	#################START AN ITERATION #############
# 	echo "		EXECUTING $(($i+1)) th ITERATION"

# 	if [ `echo $i%2 | bc` -eq 0 ]
# 	then
# 		topology=1 # Grid
# 		# routing=DSDV
# 	else
# 		topology=0 # Random
# 		# routing=AODV
# 	fi

# 	# ns 802_11.tcl $start # $dist_11 $pckt_size $pckt_per_sec $routing $time_sim
# 	echo "Row : $row"
# 	echo "Flow : $flow_no"
# 	echo "Speed: $speed"

# 	./ns $tcl $row $topology $flow_no $speed $dist $pckt_size $pckt_per_sec #$qlen #$routing $time_sim
# 	# echo "Executing $ns_ver $tcl $row $topology $flow_no $speed $dist $pckt_size $pckt_per_sec"
	# ns $tcl $row $topology $flow_no $speed $dist $pckt_size $pckt_per_sec $qlen #$routing $time_sim
# 	echo "SIMULATION COMPLETE. BUILDING STAT......"
# 	under="_"
# 	awk -f awk_wimax.awk trace.tr > "$output_file_format$under$i$under$r.out"

# 	ok=1;
# 	while read val
# 	do
# 		l=$(($l+1))

# 		if [ "$l" == "1" ]; then
# 			if [ `echo "if($val > 0.0) 1; if($val <= 0.0) 0" | bc` -eq 0 ]; then
# 				failcount=$(($failcount+1))
# 				ok=0;
# 				break
# 			fi	
# 		# calculating throughput -> Scale=5 represents 5 decimal places, | bc is a inline-commandd-line-calculator
# 			thr=$(echo "scale=5; $thr+$val/$iteration_float" | bc)
# 	#		echo -ne "throughput: $thr "
# 		elif [ "$l" == "2" ]; then
# 			del=$(echo "scale=5; $del+$val/$iteration_float" | bc)
# 	#		echo -ne "delay: "
# 		elif [ "$l" == "3" ]; then
# 			s_packet=$(echo "scale=5; $r_packet+$val/$iteration_float" | bc)
# 	#		echo -ne "send packet: "
		
# 		fi


# 		echo "$val"

# 	done < "$output_file_format$under$i$under$r.out"

# 	if [ $failcount -ge 3 ]; then
# 		echo "********************* Failed to generated output ***************\n";
# 		break;
# 	fi

# 	if [ "$ok" -eq "0" ]; then
# 		l=0;
# 		ok=1;
# 		continue
# 	fi
	
# 	# value of single iteration obtained here.
# 	# mv "conges_data.txt" "conges_data_$i$under$r.$vari.out"
# 	# sort "conges_data_$i$under$r.$vari.out" | uniq -u
# 	uniq "conges_data.txt" "conges_data_$i$under$r.$vari.out"

# 	#################END AN ITERATION
# 	i=$(($i+1))
# 	l=0
# 	done
	
# 	dir=""
# 	under="_"

# 	output_file2="$dir$output_file_format$under.out"
# 	output_file="data_$p.out"

# 	# echo "------------- VARIAION IN $metric -----------------";
# 	echo -ne "$vari " >> $output_file
# 	echo -ne "$vari " >> $output_file2


# 	echo -ne "Throughput:          $thr " >> $output_file2
# 	echo -ne "AverageDelay:         $del " >> $output_file2
# 	echo -ne "Received Packets:         $r_packet " >> $output_file2
# 	echo "" >> $output_file2

# 	echo -ne "$thr " >> $output_file
# 	echo -ne "$del " >> $output_file
# 	echo -ne "$r_packet " >> $output_file
# 	echo "" >> $output_file
# 	####################################### END A ROUND

# done

# echo " Generating graphs ... for $p"

# echo "set title \"$tcl Comparing metrics with variation in $metric\"" >> plot.plt
# echo "set xlabel \"$metric\"" >> plot.plt


# echo "set ylabel \"Throughput\"" >> plot.plt
# echo "plot \"data_$p.out\" using 1:2 title 'Throughput' with linespoints lw 2" >> plot.plt
# echo "set ylabel \"Avg Delay\"" >> plot.plt
# echo "plot \"data_$p.out\" using 1:3 title 'Avg delay' with linespoints lw 2" >> plot.plt
# echo "set ylabel \"Received Packets\"" >> plot.plt
# echo "plot \"data_$p.out\" using 1:5 title 'Received Packets' with linespoints lw 2" >> plot.plt
# echo "" >> plot.plt

# echo "Plot file generation complete ..."

# gnuplot plot.plt
# echo "Graph generation complete ..."

# # rm $tcl
# # rm $awk_file
# # rm *.out
# # rm *.tr
# rm plot.plt
# # rm *.txt
# # mv "$tcl.$p.$mod.pdf" ~/Desktop/Networking_CSE322/NS2/Offline/1505114
# # cd ~/Desktop/Networking_CSE322/NS2/Offline/1505114
# evince "$tcl.$p.$mod.pdf"
