#!/usr/bin/expect
set website [lindex $argv 0]
spawn wpscan -u $website --enumerate u
expect "\[Y\]es \[N\]o \[A\]bort, default: \[N\]"
send "Y\n"
interact
