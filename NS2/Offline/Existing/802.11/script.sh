row=10
topology=1 # Grid
flow_no=5
speed=25
ns wireless_mobile.tcl $row $topology $flow_no $speed
awk -f wireless_mobile.awk wireless.tr
# awk -f rule_wireless_udp.awk wireless.tr