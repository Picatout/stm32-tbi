1  REM EEPROM 25LC640A write,read test
2  REM Vdd=3.3 EEPROM Fck max is 5Mhz at this Vdd 
3  REM Fpclk for SPI(1) is 72Mhz, set divisor 16
4  REM Fpclk for SPI(2) is 36Mhz, set divisor 8 
5  REM 0->DIV=2, 1->DIV=4, 2->div=8, 3->div=16
6  REM EEPROM write cycle time 5msec max.  
7  INPUT "channel (1|2)? " C
8  D=3 : IF C=2 THEN D=D-1 : REM clock divisor for Fsck=4.5Mhz
10 SPI_INIT C,D : SPI_SEL C : PRINT CHAR(13),"channel ",C   
18 REM write to eeprom 
20 REM send WREN cmd # 6
30 POKEB PAD,6
40 SPI_WRITE C,1,PAD : SPI_DSEL C
48 REM can program up to 32 bytes, WR cmd # 2 
50 SPI_SEL C 
60 RANDOMIZE 
64 INPUT "EEPROM address? "a 
70 POKEB PAD ,2 POKEB PAD +1 ,RSHIFT(a,8) POKEB PAD +2 ,AND(a,8) 
80 FOR I=3 TO 12 R=RND(255) ? R, : POKEB PAD+I,R NEXT I  
90 SPI_WRITE C ,13 ,PAD 
100 SPI_DSEL C : PAUSE 5 : PRINT CHAR(13),"Write completed."
110 SPI_SEL C 
118 PRINT "reading back" 
120 POKEB PAD,3 POKEB PAD+1,RSHIF(A,8) POKEB PAD+2,AND(A,8) 
130 SPI_WRITE C,3,PAD  
140 FOR I =1 TO 10 PRINT SPI_READ(C),:NEXT I 
150 SPI_DSEL C
160 END

