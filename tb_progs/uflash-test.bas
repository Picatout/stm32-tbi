1 ' exemple d'utilisation de la commande ERASE
2 ' Sauvegarde d'une valeur dans user flash 
3 ' tout en preservant les 16 premiers octets
10 for i=0 to 15 step 4 
20 @(i)=peekw(uflash+i)
30 next i 
40 erase 
50 adc 1 
60 @(16)=ana(16) 'temperature interne mcu 
70 for i=0 to 16 step 4 
80 store uflash+i,@(i)
90 next i 
100 ? peekw(uflash+16)
110 end  

