set title "Force Deflection Data for a Beam and a Column"
set xlabel "Deflection (meters)"
set ylabel "Force (kN)"
set autoscale
plot  "data.txt" using 1:2  with lines title "Column" lw 2  
