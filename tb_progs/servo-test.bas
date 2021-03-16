10 ' servo test
12 ' channel 1 on A15, channel 2 on B3
14 ' channel 3 on B4, channel 4 on B5 
15 ' channel 5 on B8, channel 6 on B9
20 ? "select channel 1,2,3,4,5,6"
30 input s 
40 if s<1 then goto 20 
50 if s>6 then goto 20 
80 servo_init s  
90 ? "set position 1000-2000" 
100 input p 
110 if p=asc(\N) then servo_off s goto 20 
120 if p=asc(\Q) then goto 150
130 servo_pos s,p 
140 goto 90 
150 servo_off s
160 end  

