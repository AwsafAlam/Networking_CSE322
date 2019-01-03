set   autoscale
set terminal pdf
set output "802_11.tcl.2.pdf"
set title "802_11.tcl Comparing metrics with variation in flow"
set xlabel "Number of Flows"
set ylabel "Throughput"
plot "data_2.out" using 1:2 title 'Throughput' with linespoints lw 2
set ylabel "Sent Packets"
plot "data_2.out" using 1:3 title 'Avg delay' with linespoints lw 2
set ylabel "Sent Packets"
plot "data_2.out" using 1:4 title 'Sent Packets' with linespoints lw 2
set ylabel "Received Packets"
plot "data_2.out" using 1:5 title 'Received Packets' with linespoints lw 2
set ylabel "Dropped packets"
plot "data_2.out" using 1:6 title 'Dropped packets' with linespoints lw 2
set ylabel "Packet delivery Ratio"
plot "data_2.out" using 1:7 title 'Packet delivery Ratio' with linespoints lw 2
set ylabel "Packet Drop Ratio"
plot "data_2.out" using 1:8 title 'Packet Drop Ratio' with linespoints lw 2
set title "802_11.tcl Comparing Energy variation"
set ylabel "Total Energy"
plot "data_2.out" using 1:10 title 'Total Energy' with linespoints lw 2
set ylabel "Energy Per bit"
plot "data_2.out" using 1:11 title 'Energy Per bit' with linespoints lw 2
set ylabel "Energy Per Byte"
plot "data_2.out" using 1:12 title 'Energy Per Byte' with linespoints lw 2
set ylabel "Energy Per Packet"
plot "data_2.out" using 1:13 title 'Energy Per Packet' with linespoints lw 2
set ylabel "Total retransmit"
plot "data_2.out" using 1:14 title 'Total retransmit' with linespoints lw 2
set ylabel "Efficiency"
plot "data_2.out" using 1:15 title 'Efficiency' with linespoints lw 2
set title "802_11.tcl Comparing variation in congestion window size with time"
set xlabel "Time"
set ylabel "Congestion Window size"
plot "conges_data_0_3.6.out" using 1:2  with lines title "6 Congestion Window" lw 2, "conges_data_1_5.10.out" using 1:2  with lines title "10 Congestion Window" lw 2, "conges_data_1_3.6.out" using 1:2  with lines title "6 Congestion Window" lw 2, "conges_data_0_2.4.out" using 1:2  with lines title "4 Congestion Window" lw 2, "conges_data_1_2.4.out" using 1:2  with lines title "4 Congestion Window" lw 2, "conges_data_1_4.8.out" using 1:2  with lines title "8 Congestion Window" lw 2, "conges_data_0_1.2.out" using 1:2  with lines title "2 Congestion Window" lw 2, "conges_data_0_5.10.out" using 1:2  with lines title "10 Congestion Window" lw 2, "conges_data_0_4.8.out" using 1:2  with lines title "8 Congestion Window" lw 2, "conges_data_1_1.2.out" using 1:2  with lines title "2 Congestion Window" lw 2, 
