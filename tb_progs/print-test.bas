5 REM PRINT command test
10 REM set colum width to 6 
20 PRINT #6 
30 REM PRINT 5 INTEGER aligned to column.
40 FOR I=1 TO 10 : PRINT RND(1000); : NEXT I 
50 REM move cursor to column 20 before printing 
60 PRINT CHAR(13), TAB(20), "Hello world!"
70 REM move cursor right 5 spaces before
80 ? "hello",SPC(5),"world!"
90 REM characters arguments 
100 PRINT \A,\ ,\B,\ ,\C 
