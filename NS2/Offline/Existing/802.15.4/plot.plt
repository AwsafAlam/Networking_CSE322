set terminal png size 600,400
set output "802.11.png"
plot "data.out" using 1:3 title 'Avg delay' with linespoints lw 2,\
"data.out" using 1:4 title 'Sent Packets' with linespoints lw 2,\
"data.out" using 1:5 title 'Received Packets' with linespoints lw 2,\
"data.out" using 1:6 title 'Dropped packets' with linespoints lw 2,\
"data.out" using 1:7 title 'Packet delivery Ratio' with linespoints lw 2,\
"data.out" using 1:8 title 'Packet Drop Ratio' with linespoints lw 2
# "data.out" using 1:2  with lines title "Throughput" lw 2,\

set terminal png size 600,400
set output "802.11_energy.png"
plot "data.out" using 1:10 title 'Total Energy' with linespoints lw 2,\
"data.out" using 1:11 title 'Per bit' with linespoints lw 2,\
"data.out" using 1:12 title 'Per Byte' with linespoints lw 2,\
"data.out" using 1:13 title 'Per Packet' with linespoints lw 2,\
"data.out" using 1:14 title 'Total retransmit' with linespoints lw 2,\
"data.out" using 1:15 title 'Efficiency' with linespoints lw 2