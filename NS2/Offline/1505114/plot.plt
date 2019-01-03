set   autoscale
set terminal pdf
set output "802_11.tcl.2.pdf"
set title "802.11 Comparing metrics with variation in Packets per second"
set xlabel "Packets per second"
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
set title "802.11 Comparing Energy variation"
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
