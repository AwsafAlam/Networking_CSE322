set   autoscale                        # scale axes automatically
set title "802.11 Comparing metrics with variation in number of nodes"
# set ylabel "Performance metrics"
set xlabel "Number of Nodes"
set terminal png size 600,400
set output "802.11.0.png"
plot "data.out" using 1:2 title 'Throughput' with linespoints lw 2
set output "802.11.1.png"
plot "data.out" using 1:3 title 'Avg delay' with linespoints lw 2
set output "802.11.2.png"
plot "data.out" using 1:4 title 'Sent Packets' with linespoints lw 2
set output "802.11.3.png"
plot "data.out" using 1:5 title 'Received Packets' with linespoints lw 2
set output "802.11.4.png"
plot "data.out" using 1:6 title 'Dropped packets' with linespoints lw 2
set output "802.11.5.png"
plot "data.out" using 1:7 title 'Packet delivery Ratio' with linespoints lw 2
set output "802.11.6.png"
plot "data.out" using 1:8 title 'Packet Drop Ratio' with linespoints lw 2


set title "802.11 Comparing Energy variation with variation in number of nodes"
# set ylabel "Energy"
set xlabel "Number of nodes"
set terminal png size 600,400
set output "802.11_energy.0.png"
plot "data.out" using 1:10 title 'Total Energy' with linespoints lw 2
set output "802.11_energy.1.png"
plot "data.out" using 1:11 title 'Per bit' with linespoints lw 2
set output "802.11_energy.2.png"
plot "data.out" using 1:12 title 'Per Byte' with linespoints lw 2
set output "802.11_energy.3.png"
plot "data.out" using 1:13 title 'Per Packet' with linespoints lw 2
set output "802.11_energy.4.png"
plot "data.out" using 1:14 title 'Total retransmit' with linespoints lw 2
set output "802.11_energy.5.png"
plot "data.out" using 1:15 title 'Efficiency' with linespoints lw 2