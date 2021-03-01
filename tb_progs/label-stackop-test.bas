' test label as target and stack operators
10  INPUT A,B
20  PUSH A,B GOSUB PROD
30  PRINT  POP
40  GOTO 10 
50 PROD PUSH  POP* POP  RETURN 
