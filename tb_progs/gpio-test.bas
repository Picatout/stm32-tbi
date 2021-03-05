5 rem GPIO test 
10  input "gpio:a,b,c,d?"g, "pin"p
20  g=GPIOA+(g-65)*1024 : p=and(p,15)
30 PMODE g ,p ,OUTPUT_PP 
40 OUT g ,p ,1 
50 PAUSE 1 
60 OUT g ,p ,0 
70 PAUSE 1 
80 if not qkey then goto 30 
90 goto 10

