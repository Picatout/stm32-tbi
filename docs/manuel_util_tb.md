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
Le nom des commandes peut-être abrégé au plus court à 2 lettres. Cependant même si vous entrez votre texte avec les abbréviation lorsque vous utilisez la commande LIST pour afficher votre programme les noms sont affichés dans toute leur longueur à l'exception de la commande **REMARK** qui s'affiche comme une apostrophe.

La commande **WORDS** affiche la liste complète des mots qui sont dans le dictionnaires. 

nom|abrévation
-|-
ABS|AB
ADCON|ADCO
ADCREAD|ADCR
AND|AN
ASC|AS
AUTORUN|AU
AWU|AW 
BIT|BI
BRES|BR
BSET|BS
BTEST|BTE
BTOGL|BTO
BYE|BY
CHAR|CH
CRH|CRH
CRL|CRL
DATA|DATA
DATALN|DATAL
DDR|DD
DEC|DE
DIR|DI
DO|DO
DREAD|DR
DWRITE|DW
EEPROM|EE
END|EN
FCPU|FC 
FOR|FO
FORGET|FORG
GOSUB|GOS
GOTO|GOT
GPIO|GP
HEX|HE
IDR|ID
IF|IF
INPUT|IN
INVERT|INV
IWDGEN|IDGE
IWDGREF|IWGR
KEY|KE
LET|LE
LIST|LI
LOAD|LO
LOG|LOG
LSHIFT|LS
MULDIV|MU
NEW|NEW
NEXT|NE
NOT|NO
ODR|OD
OR|OR
PAD|PA
PAUSE|PA
PEEK|PE
PINP|PI
PMODE|PM
POKE|PO
POUT|POU
PRINT|?
PRTA|PRTA
PRTB|PRTB
PRTC|PRTC
PRTD|PRTD
PRTE|PRTE
PRTF|PRTF
PRTG|PRTG
PRTH|PRTH
PRTI|PRTI
QKEY|QK
READ|REA
REBOOT|REB
REMARK|'
RESTORE|RES
RETURN|RET
RND|RN
RSHIFT|RS
RUN|RU
SAVE|SA
SHOW|SH
SIZE|SI
SLEEP|SL
SPIEN|SPIE
SPIRD|SPIR
SPISEL|SPIS
SPIWR|SPIW
STEP|STE
STOP|ST
TICKS|TI
TIMER|TIMER
TIMEOUT|TIMEO
TO|TO
TONE|TON
UBOUND|UB
UFLASH|UF
UNTIL|UN
USR|US
WAIT|WA
WORDS|WO
WRITE|WR
XOR|XO
XRCV|XR
XTRMT|XT

### exécution des programmes
Si une ligne de commande est saisie sans numéro de ligne elle est compilée et exécutée immédiatement. Par contre si le texte commence par un entier entre 1 et 32767 cette ligne est considérée comme faisant partie d'un programme est après sa compilation elle est insérée dans la zone texte réservée au progammes BASIC. Les programmes sont exécutés à partir de la mémoire RAM. Pour le STM8S208RB il y a 6Ko de mémoire RAM une partie ce cette mémoire est utilisée par l'interpréteur et il reste environ 5740 octets disponibles pour les progammes. Il serait possible d'exécuter un programme à partir de la mémoire FLASH mais la version 1 de Tiny BASIC pour STM8 ne supporte pas ce mode. 

## exemple 1 blinky 
Sur la carte il y a une LED indentifiée **LD2**. Cette LED est connecté à la broche qui correspond au bit 5 du GPIO C. Cette GPIO   est pré-configurée en mode sortie par le système Tiny BASIC. Pour contrôler son état il suffit donc de modifier l'éatt du bit 5 du registre **ODR** du GPIO C. Dans ce premier exemple nous allons faire clignoer cette LED au rythme de 1 fois par seconde.
```
   10 btoggle gpio(2,odr),32
   20 pause 500
   30 goto 10
```
Notez que vous pouvez saisir le texte aussi bien en minuscules qu'en majuscules. l'interpréteur convertie en majuscules. La commande LIST affiche ceci:
```
>list
   10 BTOGL GPIO ( 2 ,ODR ), 32 
   20 PAUSE  500 
   30 GOTO  10 
```
Une autre méthode pour faire clignoter LD2 est d'utiliser la commande **DWRITE** comme illustré dans l'exemple suivant:
```
    5 ' enfoncez bouton USER pour arreter
    7 ' clignote 3 fois par seconde
   10 B = 1 
   20 FOR A = 0 TO  0 STEP  0 ' boucle infinie
   30 DWRITE  13 ,B 
   40 B = 1 -B 
   50 PAUSE  333 
   60 NEXT A 

```

## exemple 2 PWM logiciel

Dans cet exemple l'intensité de la LED est contrôlée par PWM logiciel.
```
    5 'Software PWM, controle LD2 sur carte
    7 PRINT # 6,
   10 R = 511 :PRINT R ,
   20 K = 0 
   30 IF R :BSET GPIO ( 2 ,ODR ), 32 
   40 FOR A = 0 TO R :NEXT A 
   50 BRES GPIO ( 2 ,ODR ), 32 
   60 FOR A =A TO  1023 :NEXT A 
   70 IF QKEY :K =KEY 
   80 IF K =ASC (\u):GOTO  200
   84 if K =ASC (\f):R =1023: GOTO 600 ' pleine intensite 
   90 IF K =ASC (\d):GOTO  400 
   94 IF K =ASC (\o):R=0:GOTO 600 ' eteindre
  100 IF K =ASC (\q):END 
  110 GOTO  20 
  200 IF R < 1023 :R =R + 1 :GOTO  600 
  210 GOTO  20 
  400 IF R > 0 :R =R - 1 :GOTO  600 
  410 GOTO  20 
  600 PRINT "\b\b\b\b\b",R ,
  610 GOTO  20 
```
L'intensité de la LED est contrôlée à partir du terminal avec les touches **u** pour augmenter l'intensitée et **d** pour la réduire. La variable **R** contrôle l'intensitée. 

## exemple 3 lecture analogique
Dans cet exemple il s'agit encore de contrôler l'intensité de LD2 mais cette fois l'intensité est déterminée par la lecture d'un potentimètre. Il faut brancher un potentiomètre de 10Ko entre **GND**,**V3,3** et **CN4-A5**. **CN4-A5** est branchée à l'entrée analogique **AN0** du MCU.
```
>li
    5 'demo lecture analogique
   10 K = 0 :PRINT # 6 ,:PWRADC  1 
   20 R =RDADC ( 0 )
   30 IF R :BSET GPIO ( 2 ,ODR ), 32 
   40 FOR A = 0 TO R :NEXT A 
   50 BRES GPIO ( 2 ,ODR ), 32 
   60 FOR A =A TO  1023 :NEXT A 
   70 IF QKEY :K =KEY 
   80 IF K =ASC (\q):PWRADC  0 :END
   90 PRINT "\b\b\b\b\b\b",R ,
  100 GOTO  20 

>run
   981
 ```
 Le programme peut-être interrompue par le bouton **USER** de la carte ou par le terminal en enfonçant la touche **q**. 
