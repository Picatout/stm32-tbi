5 rem GPIO test 
10  input "gpio:a,b,c?"g, "pin"p
20  g=GPIOA+(g-65)*1024 : p=and(p,15)
30 PMODE g ,p ,OUTPUT_PP 
40 OUT g ,p ,1 
50 PAUSE 100 
60 OUT g ,p ,0 
70 PAUSE 100 
80 if not qkey then goto 30 
90 goto 10

