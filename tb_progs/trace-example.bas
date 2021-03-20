5 REM trace example
10 PRINT "now trace is disabled"
20 PRINT "now trace is at level 1"
30 TRACE 1 
32 PUSH 32 
40 PRINT "now trace at level 2"
50 TRACE 2 
60 PRINT "now trace is at level 3"
70 TRACE 3 
72 DROP 1 
80 TRACE 0 
90 PRINT "now trace is disabled"
100 END 
