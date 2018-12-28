# Gnuplot script file for plotting data in file "force.dat"
# This file is called   force.p
set   autoscale                        # scale axes automatically
# unset log                              # remove any log-scaling
# unset label                            # remove any previous labels
# set xtic auto                          # set xtics automatically
# set ytic auto
set title "Force Deflection Data for a Beam and a Column"
set xlabel "Deflection (meters)"
set ylabel "Force (kN)"
# set key 0.01,100
# set label "Yield Point" at 0.003,260
# set arrow from 0.0028,250 to 0.003,280
# set xr [0.0:0.022]
# set yr [0:325]

set terminal pdf
set output "Mydata.pdf"
plot  "data.txt" using 1:2  with lines title "Column" lw 2,\
"data.txt" using 1:3 title 'Beam' with linespoints

set terminal png size 600,400
set output "Mydata.png"
plot  "data.txt" using 1:2  with lines title "Column" lw 2,\
"data.txt" using 1:3 title 'Beam' with linespoints