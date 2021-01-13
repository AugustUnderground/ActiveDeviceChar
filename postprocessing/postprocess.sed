#!/bin/sed -Ef
s/\@m\S+\[(\S+)\]/\1/g
s/^\s+//g
s/\s+$//g
s/\s+/,/g
