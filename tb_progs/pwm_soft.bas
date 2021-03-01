    5 'Software PWM, controle LED verte sur carte blue pill 
    7 CLS : PRINT #6,
   10 R = 511 :PRINT R ,
   20 K = 0 
   30 IF R THEN OUT GPIOC,13,0  
   40 FOR A = 0 TO R :NEXT A 
   50 OUT GPIOC,13,1 
   60 FOR A =A TO  1023 :NEXT A 
   70 IF QKEY THEN K =ASC(KEY)  
   80 IF K =ASC (\u) THEN GOTO  200
   84 if K =ASC (\f) THEN R =1023: GOTO 600 ' pleine intensite 
   90 IF K =ASC (\d) THEN GOTO  400 
   94 IF K =ASC (\o) THEN R=0:GOTO 600 ' eteindre
  100 IF K =ASC (\q) THEN END 
  110 GOTO  20 
  200 IF R < 1023 THEN R =R + 1 :GOTO  600 
  210 GOTO  20 
  400 IF R > 0 THEN R =R - 1 :GOTO  600 
  410 GOTO  20 
  600 CLS : PRINT R,
  610 GOTO  20 
