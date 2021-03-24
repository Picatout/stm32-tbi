1 REM external interrupt 0 tested
2 REM in this example the interrupt is software triggered.
5 CONST EXTIR =$40010400 ,SWIER =EXTIR +16 , EXTIPR=EXTIR+20
10 BSET EXTIR,1 REM enable EXTI0 interrupt 
20 ISR_INIT 6 ,100
30 A=1 
40 DO PRINT A ,
50 A =A +1 
60 IF NOT  (A % 10) THEN BSET SWIER ,1 REM trigger interrupt  
70 PAUSE 100  
80 UNTIL QKEY :K=ASC(KEY) 
90 END 
99 REM EXTI0 interrupt service routine
100 PRINT " [EXTI0 interrupt triggered]"
110 BSET EXTIPR,1 REM reset interrupt  
120 IRET 
