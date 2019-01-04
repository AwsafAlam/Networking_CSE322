set   autoscale
set terminal pdf
set output "802_11.tcl.7.pdf"
set title "802_11.tcl Comparing metrics with variation in Queue length"
set xlabel "Queue length"
set ylabel "Throughput"
plot "data_7.out" using 1:2 title 'Throughput' with linespoints lw 2
set ylabel "Sent Packets"
plot "data_7.out" using 1:3 title 'Avg delay' with linespoints lw 2
set ylabel "Sent Packets"
plot "data_7.out" using 1:4 title 'Sent Packets' with linespoints lw 2
set ylabel "Received Packets"
plot "data_7.out" using 1:5 title 'Received Packets' with linespoints lw 2
set ylabel "Dropped packets"
plot "data_7.out" using 1:6 title 'Dropped packets' with linespoints lw 2
set ylabel "Packet delivery Ratio"
plot "data_7.out" using 1:7 title 'Packet delivery Ratio' with linespoints lw 2
set ylabel "Packet Drop Ratio"
plot "data_7.out" using 1:8 title 'Packet Drop Ratio' with linespoints lw 2
set title "802_11.tcl Comparing Energy variation"
set ylabel "Total Energy"
plot "data_7.out" using 1:10 title 'Total Energy' with linespoints lw 2
set ylabel "Energy Per bit"
plot "data_7.out" using 1:11 title 'Energy Per bit' with linespoints lw 2
set ylabel "Energy Per Byte"
plot "data_7.out" using 1:12 title 'Energy Per Byte' with linespoints lw 2
set ylabel "Energy Per Packet"
plot "data_7.out" using 1:13 title 'Energy Per Packet' with linespoints lw 2
set ylabel "Total retransmit"
plot "data_7.out" using 1:14 title 'Total retransmit' with linespoints lw 2
set ylabel "Efficiency"
plot "data_7.out" using 1:15 title 'Efficiency' with linespoints lw 2
set title "802_11.tcl Comparing variation in congestion window size with time"
set xlabel "Time"
set ylabel "Congestion Window size"
plot "conges_data_0_5.50.out" using 1:2  with lines title "50", "conges_data_1_1.10.out" using 1:2  with lines title "10", "conges_data_1_3.30.out" using 1:2  with lines title "30", "conges_data_0_4.40.out" using 1:2  with lines title "40", "conges_data_0_2.20.out" using 1:2  with lines title "20", "conges_data_1_2.20.out" using 1:2  with lines title "20", "conges_data_0_3.30.out" using 1:2  with lines title "30", "conges_data_1_4.40.out" using 1:2  with lines title "40", "conges_data_0_1.10.out" using 1:2  with lines title "10", "conges_data_1_5.50.out" using 1:2  with lines title "50", 
plot "conges_data_0_5.50.out" using 1:2  with lines title "50" lw 2, 
plot "conges_data_1_1.10.out" using 1:2  with lines title "10" lw 2, 
plot "conges_data_1_3.30.out" using 1:2  with lines title "30" lw 2, 
plot "conges_data_0_4.40.out" using 1:2  with lines title "40" lw 2, 
plot "conges_data_0_2.20.out" using 1:2  with lines title "20" lw 2, 
plot "conges_data_1_2.20.out" using 1:2  with lines title "20" lw 2, 
plot "conges_data_0_3.30.out" using 1:2  with lines title "30" lw 2, 
plot "conges_data_1_4.40.out" using 1:2  with lines title "40" lw 2, 
plot "conges_data_0_1.10.out" using 1:2  with lines title "10" lw 2, 
plot "conges_data_1_5.50.out" using 1:2  with lines title "50" lw 2, 
