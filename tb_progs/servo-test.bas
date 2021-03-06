10 ' servo test
12 ' channel 1 on A15, channel 2 on B3
14 ' channel 3 on B4, channel 4 on B5 
20 ? "select channel 1,2,3,4"
30 input c 
40 if c=1 then gosub servoa goto 80 
50 if c=2 then gosub servob goto 80
60 if c=3 then gosub servoc goto 80
70 gosub servod 
80 servo_init s  
90 ? "set position 1000-2000" 
100 input p 
110 servo_pos s,p 
120 goto 90 
140 end  
150 servoa
160 pmode gpioa,15,output_afpp 
170 s=servo_a
180 return 
190 servob
200 pmode gpiob,3,output_afpp 
210 s=servo_b
220 return 
230 servoc 
240 pmode gpiob,4,output_afpp 
250 s=servo_c 
260 return 
270 servod 
280 pmode gpiob,5,output_afpp 
290 s=servo_d 
300 return 
