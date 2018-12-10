clear
# g++ -v -da -Q Routing.cpp -o router
g++ Routing.cpp -o router
./router "$1" topo.txt
# gdb router
# run "$1" topo.txt
# where
# list