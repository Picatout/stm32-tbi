<!-- 
Copyright Jacques Deschênes, 2021
Ce document fait parti du projet stm32-tbi
https://github.com/picatout/stm32-tbi
-->
[-&gt;English](user-manual.md)
# Manuel de l'utilisateur de blue pill Tiny BASIC 

Blue pill Tiny BASIC est un langage simple qui cependant permet de configurer et d'utiliser tous les périphériques du microcontrôleur. La seule limitation est que les interruptions ne sont pas utilisée. Tiny BASIC lui-même utilise 2 interruptions 

* systick (-1) pour le compteur de millisecondes et la commande **TIMER**.
* usart1 rx (IRQ37) Pour la réception des caractères reçus du terminal VT100.

Le déclenchement de tout autre interruption a pour effet réinitialise le MCU. Cependant la table est vecteurs d'interruption est déplacé au début de la mémoire RAM à l'adresse **0x20000000**. De cette façon il est techniquement possible pour une application d'utiliser une interruption à condition de stocke du code machine pour la routine d'interruption quelque part en mémoire RAM. Une partie de mémoire RAM qui n'est pas utilisée par le programme BASIC pourrait être utilisée à cet effet.  

L'objectif de ce manuel est de présenter les fonctionnalités du langage à travers des applications du microcontrôleur. Je n'ai pas définie toutes les constantes des registres du MCU dans le langage il est donc nécessaire de se réréfer au [feuillet de spécifications](docs/stm8s208rb.pdf) ainsi qu'au manuel de référence du [STM8S](docs/stm8s_reference.pdf). Le manuel d'utilisateur de la carte [NUCLEO-8S208RB](docs/nucleo-8s208rb_user_manual.pdf) est aussi utile.

Il est aussi recommander de lire en pré-requis de ce manuel la [référence du langage Tiny BASIC](tbi_reference.md)

### abbréviation des commandes 
Le nom des commandes peut-être abrégé au plus court à 2 lettres. Cependant même si vous entrez votre texte avec les abbréviation lorsque vous utilisez la commande LIST pour afficher votre programme les noms sont affichés dans toute leur longueur.

La commande **WORDS** affiche la liste complète des mots qui sont dans le dictionnaire. Pour plus d'informations consultez le [manuel de référence](tbi_reference.md).

### exécution des programmes
Si une ligne de commande est saisie sans numéro de ligne elle est compilée et exécutée immédiatement. Par contre si le texte commence par un entier entre 1 et 65535 cette ligne est considérée comme faisant partie d'un programme est après sa compilation elle est insérée dans la zone texte réservée au progammes BASIC. Les programmes sont exécutés à partir de la mémoire RAM. Pour le STM32f103C8 il y a 20Ko de mémoire RAM une partie ce cette mémoire est utilisée par l'interpréteur et il reste environ 19360 octets disponibles pour les progammes. Il serait possible d'exécuter un programme à partir de la mémoire FLASH mais la version 1 de blue pill tiny BASIC ne supporte pas ce mode. 

## exemple blink.bas  
Sur la carte il y a une LED verte branchée sur **PC13**. Cette GPIO   est pré-configurée en mode sortie drain ouvert par le système Tiny BASIC. Pour contrôler son état il suffit donc de modifier l'éat du bit 13 de GPIO C. Dans ce premier exemple nous allons faire clignoer cette LED au rythme de 1 fois par seconde.
```
5 ' CLIGNOTE LED VERTE DE LA CARTE BLUE PILL 
10 BLINK
20 OUT GPIOC,13,0
30 PAUSE 100 
40 OUT GPIOC,13,1
50 PAUSE 100 
60 GOTO BLINK 
```
Notez que vous pouvez saisir le texte aussi bien en minuscules qu'en majuscules. l'interpréteur convertie en majuscules. La commande LIST affiche ceci:
```
list
5 REM  CLIGNOTE LED VERTE DE LA CARTE BLUE PILL 
10 BLINK 
20 OUT GPIOC ,13 ,0 
30 PAUSE 100 
40 OUT GPIOC ,13 ,1 
50 PAUSE 100 
60 GOTO BLINK 
READY
```

## exemple 2 PWM logiciel

Dans cet exemple l'intensité de la LED est contrôlée par PWM logiciel.
```
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
```
L'intensité de la LED est contrôlée à partir du terminal avec les touches **u** pour augmenter l'intensitée et **d** pour la réduire, **f** pleine intensité, **o** éteinte et **q** pour quitter le programme. La variable **R** contrôle l'intensitée. 
L'Intensité s'affiche dans le coin supérieur gauche du terminal.

## exemple 3 lecture analogique
Dans cet exemple il s'agit encore de contrôler l'intensité de LD2 mais cette fois l'intensité est déterminée par la lecture d'un potentimètre. Il faut brancher un potentiomètre de 10Ko entre **GND**,**V3,3** et **CN4-A5**. **CN4-A5** est branchée à l'entrée analogique **AN0** du MCU.
```
5 REM TEST CONVERTISSEUR ANALOG/DIGITAL 
10 CLS 
20 ADC 1
30 T=0 B=ANA(16) PAUSE 100 
40 D=B
50 T=ANA(16) LOCATE 1,1 ? "TEMP:", T ;"DELTA:",D,"    "
60 D=ABS(T-B)
70 B=T 
80 PAUSE 500 
90 IF NOT QKEY THEN GOTO 50 
100 K=ASC(KEY)
110 CLS 
120 B=ANA(0)  D=0 PAUSE 100   
130 A=ANA(0) LOCATE 1,1 ? "ANA0:",A,"   DELTA: ",D,"   "
140 D=ABS(A-B) B=A 
150 PAUSE 500
160 IF NOT QKEY THEN GOTO 130 
170 K=ASC(KEY)
180 ADC 0 
190 END 
 ```
Dans la première partie le programme affiche la lecture de la sonde de température interne du MCU qui est sur le canal 16. Dans la deuxième parti il affiche la valeur lue sur l'entrée **PA0** qui correspond au canal **0**. Il suffit de presser une touche pour passer à la deuxième parti. Presser une touche pour la deuxième fois termine le programme.
