#basic
set x "Hello World"
set y 5

puts $x
puts $x$x

puts $y
puts $y$y

# command line arg
set x [lindex $argv 0]


#expression
puts [expr 10+20]

puts [expr (10+20)*$y]
set x [expr (10+20)*$y -10]
puts $x

#conditioning

if {$x > 100} { ;#inline comments
	puts "More than 100"
} else {
	puts "Less than 100"
}

#ternary
set x [expr $x>$y ? 10:20]
puts $x

# Looping
set msg "Index : "
for {set i 0} {$i < 10} {incr i} {
    puts $msg$i ;# Concatenated string
}

# Class