set terminal png size 600,400
set output "802.11.png"
plot  "data.out" using 1:2  with lines title "Column" lw 2,\
"data.out" using 1:3 title 'Beam' with linespoints lw 2,\
"data.out" using 1:4 title 'Beam' with linespoints lw 2,\
"data.out" using 1:5 title 'Beam' with linespoints lw 2,\
"data.out" using 1:6 title 'Beam' with linespoints lw 2,\
"data.out" using 1:7 title 'Beam' with linespoints lw 2,\
"data.out" using 1:9 title 'Beam' with linespoints lw 2

set terminal png size 600,400
set output "802.11_energy.png"
"data.out" using 1:10 title 'Beam' with linespoints lw 2,\
"data.out" using 1:11 title 'Beam' with linespoints lw 2,\
"data.out" using 1:12 title 'Beam' with linespoints lw 2,\
"data.out" using 1:13 title 'Beam' with linespoints lw 2,\
"data.out" using 1:14 title 'Beam' with linespoints lw 2,\
"data.out" using 1:15 title 'Beam' with linespoints lw 2