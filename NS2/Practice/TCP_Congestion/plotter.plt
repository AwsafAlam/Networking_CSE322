set terminal png size 600,400
set output "tcp_congestion.png"

set title "Comparison of tcp congestion control"
set xlabel "Time"
set ylabel "TCP Congestion window"
set autoscale
plot  "data.txt" using 1:2  with lines title "TCP Reno" lw 2  
