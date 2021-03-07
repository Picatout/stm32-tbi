10 ' servo test
12 ' channel 1 on A15, channel 2 on B3
14 ' channel 3 on B4, channel 4 on B5 
20 ? "select channel 1,2,3,4"
30 input c 
40 if c=1 then s=servo_a goto 80 
50 if c=2 then s=servo_b goto 80
60 if c=3 then s=servo_c goto 80
70 s=servo_d 
80 servo_init s  
90 ? "set position 1000-2000" 
100 input p 
110 if p=asc(\N) then goto 20 
120 if p=asc(\Q) then end 
130 servo_pos s,p 
140 goto 90 
150 end  
