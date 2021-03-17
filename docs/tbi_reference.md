<!-- 
Copyright Jacques Deschênes, 2021
Ce document fait parti du projet stm32-tbi
https://github.com/picatout/stm32-tbi
-->
[-&gt;english](refman.md)
# référence du langage blue pill Tiny BASIC

<a id="index-princ"></a>
## index principal 

* [Types de données](#data-types)

* [Variables](#variables)

* [Constantes utilisateur](#userconst)

* [Expressions arithmétiques](#expressions)

* [Syntaxe](#syntaxe)

* [Bases numériques](#bases)

* [Ligne de commande](#cli)

* [Fichiers](#fichiers)

* [Référence des commandes et fonctions](#index)

* [Installation](#install)

* [Utilisation](#utilisation)

* [transfert de fichiers](#xmodem)

* [Code source](#sources)

<a id="data-types"></a>
### Type de données 

Le seul type de donné numérique est l'entier 32 bits donc dans l'intervalle **{-2147483650...2147483649**}.  

Cependant pour des fins d'impression des chaînes de caractères entre guillemets sont disponibles. Seul les commandes **PRINT** et **INPUT** utilisent ces chaînes comme arguments. 

Le type caractère est aussi disponible sous la forme **\c** i.e. un *backslash* suivit d'un caractère ASCII. 

Il est aussi possible d'imprimer un caractère en utilisant la fonction **CHAR()**. Qui retourne un jeton de type **TK_CHAR**. Ce type de donnée ne peut-être sauvegardé dans une variable sauf en utilisant la fonction **ASC()** qui le convertie ent type **TK_INTGR** qui peut-être sauvegardé dans une variable ou utilisé dans un expression.  

[index principal](#index-princ)

<a id="variables"></a>
### Variables 

Le nombre des variables est limité à 26 et chacune d'elle est représentée par une lettre de l'alphabet. 

[index principal](#index-princ)

<a id="tableau"></a>
### Tableau 

Il n'y a qu'un seul tableau appelé **@** et dont la taille dépend de la taille du programme. En effet ce tableau utilise la mémoire RAM laissée libre par le programme. Un programme peut connaître la taille de ce tableau en invoquant la fonction **UBOUND**. 

[index principal](#index-princ)

<a id="userconst"></a>
### Constantes utilisateurs

Il est possible de définir des constantets symboliques en utilisant le mot réservé  **CONST** les noms de constantes doivent avaoir un maximum de 6 caractères. Seules les lettres et le caractère **'_'** sont acceptés. Les lettres sont converties en majuscules.
```
HEX LIST
5 REM  Adresse de base des UART2 et 3
10 CONST UART_B =$40000400 ,UART_C =$40000800 
15 PRINT UART_B ,UART_C 
READY
RUN
1073742848 1073743872 
```

[index principal](#index-princ)

<a id="expressions"></a>
### expression arithmétiques 

Il y a 5 opérateurs arithmétiques par ordre de précédence:
1. **'-'**  moins unaire, qui a la plus haute priorité.
1.  __'*'__ mulitipliation, **'/'** division, **'%'** modulo 
1. **'+'** addition, **'-'** soustraction.

**NOTE:** Le quotient de la divison n'est pas arrondie. 

### opérateurs relationnels.

Les opérateurs relationnels sont utilisés pour comparer la valeur de 2 expressions arithmétiques. Les relations ne peuvent-être utilisées qu'après le **IF** ou le **UNTIL**.
Toute valeur non nulle est considérée comme vrai.

1. **'&gt;'**   Retourne vrai si le premier terme est plus grand que le deuxième.
1. **'&lt;'** Retourne vrai si le premier terme est plus petit que le second.
1. **'&gt;='** Retourne vrai si le premier terme est plus grand ou égal au second. 
1. **'&lt;='** Retourne vrai si le premier terme est plus petit ou égal au second. 
1. **'='** Retourne vrai si les 2 termes sont identiques. 
1. **'&lt;&gt;'** ou **'&gt;&lt;'** Retourne vrai si les 2 termes sont différents. 

[index principal](#index-princ)
<a id="syntaxe"></a>
## Syntaxe 

Le code utilisé pour le texte est le code [ASCII](https://fr.wikipedia.org/wiki/American_Standard_Code_for_Information_Interchange).

Un programme débute par un numéro de ligne suivit optionnellement d'une *étiquette cible* et d'une ou plusieurs commandes séparées par le caractère **':'**. Les lignes vides sont supprimées. Le séparateur de commande **':'** n'est pas obligatoire s'il n'y a pas d'ambiguité sur la fin de la commande précédente.

Une commande est suivie de ses arguments séparés par une virgule. Les arguments des fonctions doivent-être mis entre parenthèses. Par fonction j'entends une sous-routine qui retourne une valeur. Cependant une fonction qui n'utilise pas d'arguments n'est pas suivie de parenthèses. Les commandes , c'est à dire les sous-routines qui ne retoune pas de valeur, reçoivent leur arguments sans parenthèses sauf pout **TAB** et **SPC**. 

Les *espaces* entre les *unitées lexicales* sont facultatifs sauf s'il y a ambiguité. Par exemple si le nom d'un commande est immédiatement suivit par le nom d'une variable un espace doit les séparer. 

Les commandes peuvent-être entrées indifféremment en minuscule ou majuscule.
L'analyseur lexical convertie les lettres en  majuscule sauf à l'intérieur d'une chaîne entre guillemets.

Les commandes peuvent-être abrégées au plus court à 2 caractères à condition qu'il n'y est pas d'ambiguité entre 2 commandes. L'abréviation doit-être d'au moins 2 lettres pour éviter la confusion avec les variables. Par exemple **GOTO**peut-être abrégé **GOT** et **GOSUB** peut-être abrégé **GOS**.  Ces abréviations ne sauvent pas d'espaces mémoire et n'accélère aucunement l'exécution car chaque ligne est compilée en jetons à la fin de sa saisie.  Seule cette version compilée est sauvegardée. La commande **LIST** décompile le programme avant de l'afficher.

Certaines commandes sont représentées facultativement par une caractère unique. Par exemple la commande **PRINT** peut-être remplacée par le caractère **'?'**. La commande **REM** peut-être remplacée par un apostrophe (**'**). Cependant lors de la décompilation c'est le nom de la commande qui apparaît.

Plusieurs commandes peuvent-être présentent sur la même ligne. Le caractère **':'** est utilisé pour indiqué la fin d'une commande. Son utilisation est facultif s'il n'y pas pas d'ambiguité. 
```
A=2:B=4   ' valide
READY
C=3 D=35 ' valide car il n'y pas d'ambiguité.
READY
```

Une fin de ligne marque la fin d'une commande. Autrement dit une commande ne peut s'étendre sur plusieurs lignes. 

[index principal](#index-princ)
<a id="bases"></a>
## bases numériques
Les entiers peuvent-être indiqués en décimal,hexadécimal ou binaire. Cependant ils ne peuvent-être affichés qu'en décimal ou hexadécimal. 

Forme lexicale des entiers. Dans la liste qui suit ce qui est entre **'['** et **']'** est facultatif. Le caractère **'+'** indique que le symbole apparaît au moins une fois. Un caractère entre apostrophes est écris tel quel *(symbole terminal)*. **::=** introduit la définition d'un symbole.

*  digit::= '0','1','2','3','4','5','6','7','8','9'
*  hex_digit::= digit,'A','B','C','D','E','F' 
*  entier décimaux::=  ['+'|'-']digit+
*  entier hexadécimaux::= ['+'|'-']'$'hex_digit+
*  entier binaire::= ['+'|'-']'&'('0'|'1')+   

examples d'entiers:

    -13534 ' entier décimal négatif 
    $ff0f  ' entier hexadécimal 
    &101   ' entier binaire correspondant à 5 en décimal. 

[index principal](#index-princ)
<a id="cli"></a>
## Ligne de commande et programmes 

La communication avec la carte **blue pill** se fait via le périphérique **UART1** et un adapteur de niveau. Du côté PC seul est requis un port sériel RS-232 et un émulateur de terminal VT100. Il n'y a pas d'application à installer sur le PC.

Au démarrage l'information sur Tiny BASIC est affichée. Ensuite viens le texte **READY** sur la ligne suivante. Ce qui signifit que le système est prêt à recevoir des commandes. 
```
blue pill tiny BASIC, version 1.0
READY
```

À partir de là l'utilisateur doit saisir une commande au clavier. Cette commande est considérée comme complétée lorsque la touche **ENTER** est enfoncée. Le texte est d'abord compilé en *jetons*. Si il y a un numéro de ligne alors cette ligne est inséré dans l'espace mémoire réservé aux programmes sinon elle est exécutée immédiatement. 

* Un numéro de ligne doit-être dans l'intervalle {1...65535}.

* Si une ligne avec le même numéro existe déjà elle est remplacée par la nouvelle. 

* Si la ligne ne contient qu'un numéro sans autre texte et qu'il existe déjà une ligne avec ce numéro la ligne en question est supprimée. Sinon elle est ignorée. 

* Les lignes sont insérée en ordre numérique croissant. 

Certaines commandes ne peuvent-être utilisées qu'à l'intérieur d'un programme et d'autres seulement en mode ligne de commande. L'exécution est interrompue et un message d'erreur est affiché si une commande est utilisée dans un contexte innaproprié. 

Le programme en mémoire RAM est perdu à chaque réinitialiation du processeur sauf s'il a été sauvegardé comme fichier dans la mémoire flash. Les commandes de fichiers sont décrites dans la section [référence des commandes](#reference).

[index principal](#index-princ)
<a id="fichiers"></a>
## Système de fichier
Le microcontrôleur de la carte blue pill possède 64Ko de mémoire flash. Cependant seulement une partie de cette mémoire est utilisée par l'interpréteur BASIC. 1Ko de la mémoire 
restante est utilisée comme émulation EEPROM et le reste par le système de fichier.

<a id="reference"></a>
## Référence des commandes, fonctions et constantes système.
la remarque **{C,P}** après le nom de chaque commande indique dans quel contexte cette commande ou fonction peut-être utilisée. **P** pour *programme* et **C** pour ligne de commande. Une fonction ne peut-être utilisée que comme argument d'une commande ou comme partie d'une expression. 

[index principal](#index-princ)

<a id="index"></a>
## INDEX du vocabulaire
nom|abrévation
-|-
[ABS](#abs)|AB
[ANA](#adcread)|AN
[ADC](#adcon)|ADCO
[AND](#and)|AN
[ASC](#asc)|AS
[AUTORUN](#autorun)|AU
[AWU](#awu)|AW 
[BIT](#bit)|BI
[BRES](#bres)|BR
[BSET](#bset)|BS
[BTEST](#btest)|BTE
[BTOGL](#btogl)|BTO
[CHAR](#char)|CH
[CLS](#cls)|CL
[CONST](#const)|CO 
[DATA](#data)|DA
[DEC](#dec)|DE
[DIR](#dir)|DI
[DO](#do)|DO
[DROP](#drop)|DR
[DUMP](#dump)|DU 
[END](#end)|EN
[ERASE](#erase)|ER
[FOR](#for)|FO
[FORGET](#forget)|FORG
[FREE](#free)|FR
[GET](#get)|GE
[GOSUB](#gosub)|GOS
[GOTO](#goto)|GOT
[GPIOA](#gpio)|GPIOA
[GPIOB](#gpio)|GPIOB
[GPIOC](#gpio)|GPIOC
[HEX](#hex)|HE
[IF](#if)|IF
[IN](#in)|IN
[INPUT](#input)|INP
[INPUT_ANA](#input-xxx)|INPUT_A
[INPUT_FLOAT](#input-xxx)|INPUT_F
[INPUT_PD](#input-xxx)|INPUT_PD
[INPUT_PU](#input-xxx)|INPUT_PU
[INVERT](#invert)|INV
[KEY](#key)|KE
[LET](#let)|LE
[LIST](#list)|LI
[LOCATE](#locate)|LO
[LSHIFT](#lshift)|LS
[NEW](#new)|NEW
[NEXT](#next)|NE
[NOT](#not)|NO
[OR](#or)|OR
[OUT](#out)|OU
[OUTPUT_AFOD](#output-xxx)|OUTPUT_AF
[OUTPUT_AFPP](#output-xxx)|OUTPUT_AFP
[OUTPUT_OD](#output-xxx)|OUTPUT_O
[OUTPUT_PP](#output-xxx)|OUTPUT_P
[PAD](#pad)|PA
[PAUSE](#pause)|PA
[PEEKB](#peekx)|PE
[PEEKH](#peekx)|PEEKH 
[PEEKW](#peekx)|PEEKW
[PMODE](#pmode)|PM
[POKEB](#pokex)|PO
[POKEH](#pokex)|POKEH
[POKEW](#pokex)|POKEW
[POP](#pop)|POP
[PRINT](#print)|?
[PUSH](#push)|PU
[PUT](#put)|PUT
[QKEY](#qkey)|QK
[READ](#read)|REA
[REM](#remark)|'
[RESTORE](#restore)|RES
[RETURN](#return)|RET
[RND](#rnd)|RN
[RSHIFT](#rshift)|RS
[RUN](#run)|RU
[SAVE](#save)|SA
[SERVO_INIT](#servo-init)|SE
[SERVO_OFF](#servo-off)|SERVO_O
[SERVO_POS](#servo-pos)|SERVO_P
[SLEEP](#sleep)|SL
[SPC](#space)|SP
[SPIEN](#spien)|SPIE
[SPIRD](#spird)|SPIR
[SPISEL](#spisel)|SPIS
[STEP](#step)|STE
[STOP](#stop)|ST
[STORE](#store)|STO
[TAB](#tab)|TA
[THEN](#then)|TH
[TICKS](#ticks)|TI
[TIMEOUT](#timeout)|TIMEO
[TIMER](#timer)|TIMER
[TO](#to)|TO
[TONE](#tone)|TON
[TONE_INIT](#toneinit)|TONE_
[TRACE](#trace)|TR
[UBOUND](#ubound)|UB
[UFLASH](#uflash)|UF
[UNTIL](#until)|UN
[WAIT](#wait)|WA
[WORDS](#words)|WO
[XOR](#xor)|XO
[XPOS](#xpos)|XP
[YPOS](#ypos)|YP 

<hr>

<a id="abs"></a>
### ABS(*expr*)  {C,P}
Cette fonction retourne la valeur absolue de l'expression fournie en argument. 

    ? abs(-45)
    45
[index](#index)
<a id="adcon"></a>
### ADC 0|1 {C,P}
Active **1** ou désactive **0** le convertisseur analogique/numérique.
```
pmode gpioa,0,input_ana 'set pin mode GPIOA:0       
READY
adc 1 ' active l'ADC 
READY
? ana(0)
2291 
READY
? ana(16) ' sonde de température interne au MCU.
1619 
READY
adc 0
READY
```
On peut désactiver le convertisseur pour réduire la consommation du MCU.

[index](#index)
<a id="adcread"></a>
### ANA(canal) {C,P}
Lecture d'une des 17 entrées analogiques. L'argument **canal** détermine quel entrée est lue {0..17}. Le canal 16 correspond à la sonde de température interne. Le canal 17 est un voltage de référence interne au MCU utilisé par le convertisseur analogue/numérique. 
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

[index](#index)
<a id="and"></a>
### AND(*expr1*,*expr2*) {C,P}
Il s'agit de la fonction logique **AND** binaire c'est à dire d'une application bit à bit entre les 2 expressions. L'équivalent de l'opérateur **&** en C. 
```
>? and(4,6)
   4

>? and(255,127)
 127

>
```

[index](#index)
<a id="asc"></a>
### ASC(*string*|*char*) {C,P}
La fonction **ascii** retourne la valeur ASCII du premier caractère de la chaîne fournie en argument ou du caractère.
```
    >? asc("A")
    65 

    >? asc(\Z)
    90

    >
```
[index](#index)
<a id="autorun"></a>
### AUTORUN *"file"*  {C}
Cette commande définie un fichier programme à charger et exécuter au démarrage. Si le fichier n'existe il y a message d'erreur *file not found* et on se retrouve simplement sur la ligne de commande. Le nom du fichier est sauvegardé au début de la mémoire **UFLASH**  .Il faut donc faire attention pour ne pas l'écraser avec la commande **STORE**.
```
LIST
5 REM  CLIGNOTE LED VERTE DE LA CARTE BLUE PILL 
10 BLINK 
20 OUT GPIOC ,13 ,0 
30 PAUSE 200 
40 OUT GPIOC ,13 ,1 
50 PAUSE 200 
60 GOTO BLINK 
READY
SAVE "blink"
file size: 137 bytes

READY
autorun "blink" 
READY

user reboot!

blue pill tiny BASIC, version 1.0
file size: 137 bytes

```
Maintenant chaque fois que la carte est réinitialisée le progamme **blink** est chargé et exécuté. La grandeur du fichier chargé pour exécution est indiquée sur le terminal.

[index](#index)
<a id="awu"></a>
### AWU *expr*  {C,P}
Cette commande arrête le MCU pour une durée déterminée. Son nom signifit  *Auto Wake up*.  Cette commande utilise l'oscillateur interne **LSI** ainsi que le **IWDG** *(Independant WatchDog timer)*. Lorsque le compteur arrive à expiration le MCU redémarre. Ce mode réduit la consommation électrique au minimum. *expr* doit résulter en un entier dans l'interval {0..26214}. Cet entier correspond à la durée de la mise en sommeil en millisecondes. La durée maximale est d'environ 26 secondes. Notez que la fréquence LSI nominale est de 40Khz mais elle peut varier entre 30Khz et 60Khz (selon les spécifications fournies par le fabricant, section 5.3.7 du datatsheet ). 
```
awu 0  ' delais minimum 

blue pill tiny BASIC, version 1.0
READY
awu 26214 ' delais maximum  

blue pill tiny BASIC, version 1.0
READY
```
 Voir aussi [SLEEP](#sleep)

[index](#index)
<a id="bit"></a>
### BIT(*expr*) {C,P}
Cette fonction retourne 2^*expr*  (2 à la puissance n). *expr* doit-être entre {0..31} 
```
for i=0 to 31 : ? bit(i), next i
1 2 4 8 16 32 64 128 256 512 1024 2048 4096 8192 16384 32768 65536 131072 262144 524288 1048576 2097152 4194304 8388608 16777216 33554432 67108864 134217728 268435456 536870912 1073741824 -2147483648 
READY
```
[index](#index)
<a id="bres"></a>
### BRES addr,mask {C,P}
La commande **bit reset** met à **0** les bits de l'octet situé à *addr*. Seul les bits à **1** dans l'argument *mask* sont affectés. 
```
bres gpioc+$c,bit(13)
READY
```
Allume la LED sur la carte en mettant le bit 13 à 0. **Notez** que les bits sont numérotés de **0..31**, **0** étant le bit le moins significatif. 

[index](#index)
<a id="bset"></a>
### BSET addr,mask  {C,P}
La commande **bit set** met à **1** les bits de l'octet situé à *addr*. Seul les bits à **1** dans l'argument *mask* sont affectés. 
```
bset gpioc+$c,bit(13)
READY
```
Éteint la LED sur la carte en mettant le bit 13 à 1.

[index](#index)
<a id="btest"></a>
### BTEST(addr,bit) {C,P}
Cette fonction retourne l'état du *bit* à *addr*.  Permet entre autre de lire l'état d'une broche GPIO configurée en entrée.
*bit* doit-être dans l'intervalle {0..31}. 
```
? btest(gpioc+$c,13)
0 
READY
bset gpioc+$c,bit(13) ? btest(gpioc+$c,13)
1 
READY
```

[index](#index)
<a id="btogl"></a>
### BTOGL addr,mask  {C,P}
La commande **bit toggle** inverse les bits de l'octet situé à *addr*. Seul les bits à **1** dans l'argument *mask* sont affectés. 
```
btogl gpioc+$c,bit(13) ? btest(gpioc+$c,13)
1 
READY
btogl gpioc+$c,bit(13) ? btest(gpioc+$c,13)
0 
READY
```

Inverse l'état de la LED sur la carte. 

[index](#index)
<a id="char"></a>
### CHAR(*expr*) {C,P}
La fonction *character* retourne le caractère ASCII correspondant aux 7 bits les moins significatifs de l'expression utilisée en argument. Pour l'interpréteur cette fonction retourne un jeton de type **TK_CHAR** qui n'est reconnu que par les commandes **PRINT** et **ASC**.
```
for a=32 to 126:? char(a),:next a
 !"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~
READY
```
[index](#index)
<a id="cls"></a>
### CLS {C,P}
Efface l'écran du terminal. 

[index](#index)

<a id="const"></a>
### CONST nom=expr [,nom=expr]*  {P}
Cette commande permet de définir des constantes symboliques à l'intérieur d'un programme. Plus d'une constante peuvent-être définies dans la même commande. Ces symboles peuvent par la suite être utilisés dans les expressions arithmétiques ou comme argument de commandes ou fonctions. Les noms doivent avoir un maximum de 6 caractères constitué seulement de lettres et du symbole **'_'**.
```
LIST
10 CONST CENTPI =314 
20 REM  DEG TO RAD 
30 PRINT 180 *2 *CENTPI /36000 
READY
RUN
3 
```

[index](#index)
<a id="data"></a>
### DATA {P}
Cette directive permet de définir des données dans un programme. L'interpréteur ignore les lignes qui débute par **DATA**.  Ces lignes ne sont utilisées que par la commande **READ**.
```
    5 ' haut-parleur sur broche B6.
    7 TONE_INIT     
   10 RESTORE 
   20 DATA 440,250,440,250,466,250,523,250,523,250,466,250,440,250
   30 DATA 392,250,349,250,349,250,392,250,440,250,440,375,392,125
   40 DATA 392,500
   50 FOR I =1TO 15:TONE READ ,READ :NEXT I 
```

[index](#index)
<a id="dec"></a>
### DEC {C,P}
La commande *decimal* définie la base numérique pour l'affichage des entiers à la base décimale. C'est la base par défaut. Voir la commande **HEX**.
```
hex ?-10 dec ? -10
$FFFFFFF6 
-10 
READY
```
[index](#index)
<a id="dir"></a>
### DIR {C,P}
La commande *directory*  affiche la liste des fichiers sauvegardés en mémoire flash.
```
5 REM  joue 15 notes
6 TONE_INIT 
10 RESTORE 
20 DATA 440 ,250 ,440 ,250 ,466 ,250 ,523 ,250 ,523 ,250 ,466 ,250 ,440 ,250 
30 DATA 392 ,250 ,349 ,250 ,349 ,250 ,392 ,250 ,440 ,250 ,440 ,375 ,392 ,125 
40 DATA 392 ,500 
50 FOR I =1 TO 15 :TONE READ ,READ :NEXT I 
READY
save "tone-test"
file size: 284 bytes

READY
dir
tone-test      284 

               1 files

READY
```
[index](#index)
<a id="do"></a>
### DO {C,P}
Mot réservé qui débute une boucle **DO ... UNTIL** Les instructions entre  **DO** et **UNTIL**  s'exécutent en boucle aussi longtemps que l'expression qui suit **UNTIL** est fausse.  Voir **UNTIL**. 
```
list
10 A =1 
20 DO 
30 PRINT A ,
40 A =A +1 
50 UNTIL A >10 
READY
run
1 2 3 4 5 6 7 8 9 10 
READY
``` 
[index](#index)

<a id="drop"></a>
### DROP n {C,P}
Cette commande permet de jeter n entiers qui a été préalablement déposés sur la pile avec la commande **PUSH**. 
```
push 1,2,3  ? get(0)+get(1)+get(2) drop 3
6
READY

```
[index](#index)
<a id="dump"></a>
### DUMP adr,n {C,P}
Cette commande sert à examiner le contenu de la mémoire en affichant les octets en hexadécimal et en caractères ASCII. Il s'agit d'un outil de débogage.
```
DUMP $20000210,63
           00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F 
===============================================================================
$20000210  0A 00 11 17 0E 1A 09 52 57 06 0D 1B 3A 01 00 00   _______RW___:___
$20000220  00 14 00 13 17 3C 20 44 45 47 20 54 4F 20 52 41   _____< DEG TO RA
$20000230  44 20 00 00 1E 00 1D 17 37 1B B4 00 00 00 09 1B   D ______7_______
$20000240  02 00 00 00 09 1A 09 52 57 06 0A 1B A0 8C 00 00   _______RW_______
READY
```
[index](#index)
<a id="end"></a>
### END {C,P}
Cette commande arrête l'exécution d'un programme et retourne le contrôle à la ligne de commande. Cette commande peut-être placée à plusieurs endroits dans un programme. Elle peut aussi être utlisée sur la ligne de commande pour terminer un programme interrompu par la commande **STOP**. 
```
LIST
10 A =0 
20 A =A +1 
30 PRINT A ,IF A >100 END 
40 GOTO 20 
READY
RUN
1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 
READY
```
[index](#index)
<a id="erase"></a>
### ERASE adr {C,P}
Efface la plage **UFLASH**. Un espace de 1Ko est réservé dans la mémoire flash pour conservé des données persistantes. Les 16 premiers octets sont réservés pour le nom du programme **AUTORUN**. Les autres peuvent-être utilisés par les programmes BASIC. Cette commande supprime toutes les informations persistantes y compris le progamme **AUTORUN**. 
```
list
1 REM  exemple d'utilisation de la commande ERASE
2 REM  Sauvegarde d'une valeur dans user flash 
3 REM  tout en preservant les 16 premiers octets
10 FOR I =0 TO 15 STEP 4 
20 @(I )=PEEKW (UFLASH +I )
30 NEXT I 
40 ERASE 
50 ADC 1 
60 @(16 )=ANA (16 )REM temperature interne mcu 
70 FOR I =0 TO 16 STEP 4 
80 STORE UFLASH +I ,@(I )
90 NEXT I 
100 PRINT PEEKW (UFLASH +16 )
110 END 
READY
dump uflash,16
           00 01 02 03 04 05 0 07 08 09 0A 0B 0C 0D 0E 0F 
===============================================================================
$8004400   41 52 55 4E 74 65 73 74 00 FF FF FF FF FF FF FF   ARUNtest________
$8004410   3C 05 00 00 FF FF FF FF FF FF FF FF FF FF FF FF   <_______________
READY
```

[index](#index)
<a id="for"></a>
### FOR *var*=*expr1* [TO](#to) *expr2* [STEP](#step) *expr3*] {C,P}
Cette commande initialise une boucle avec compteur. La variable est initialisée avec la valeur de l'expression *expr1*. À chaque boucle la variable est incrémentée de la valeur indiquée par *expr3* qui suit le mot réservé **STEP**. Si **STEP** n'est pas indiqué la valeur par défaut **1** est utilisée. Une boucle **FOR** se termine par la commande **NEXT** tel qu'indiqué plus bas. Les instructions entre les comamndes **FOR** et **NEXT**
peuvent s'étaler sur plusieurs lignes à l'intérieur d'un programme. Mais sur la ligne de commande le bloc au complet doit-être sur la même ligne.

La boucle FOR...NEXT est excéutée au moins une fois même si la limite est déjà dépassée par la condition initiale de la variable de contrôle. Ceci est du au fait que l'incrément et la vérification de la limite est effectuée par la commande **NEXT** qui vient à la fin de la boucle.  

```
for a=1to10:? a,:next a
   1   2   3   4   5   6   7   8   9  10

``` 
Exemple de boucle FOR...NEXT dans un programme.
```
LLIST
5 PRINT #5 
10 FOR A =1 TO 12 
20 FOR B =1 TO 12 
30 PRINT A *B ;
40 NEXT B PRINT 
50 NEXT A 
READY
RUN

1    2    3    4    5    6    7    8    9    10   11   12   
2    4    6    8    10   12   14   16   18   20   22   24   
3    6    9    12   15   18   21   24   27   30   33   36   
4    8    12   16   20   24   28   32   36   40   44   48   
5    10   15   20   25   30   35   40   45   50   55   60   
6    12   18   24   30   36   42   48   54   60   66   72   
7    14   21   28   35   42   49   56   63   70   77   84   
8    16   24   32   40   48   56   64   72   80   88   96   
9    18   27   36   45   54   63   72   81   90   99   108  
10   20   30   40   50   60   70   80   90   100  110  120  
11   22   33   44   55   66   77   88   99   110  121  132  
12   24   36   48   60   72   84   96   108  120  132  144  
READY
```

[index](#index)
<a id="forget"></a>
### FORGET ["file"] {C,P}
Cette commande sert à supprimer un fichier sauvegardé dans la mémoire flash. 
**Tous les fichiers qui suivent celui nommé sont aussi supprimés. Si aucun fichier n'est nommé tous les fichiers sont supprimés.**
```
dir
table1   66
hello   21
blink   52
   3 files
READY 
forget "blink"
READY
dir
table1   66
hello   21
   2 files
READY
```
[index](#index)
<a id="free"></a>
### FREE {C,P}
 Cette commande retourne le nombre d'octets libres dans la mémoire RAM.
```
blue pill tiny BASIC, version 1.0
READY
? free
19360 
READY
load "servo-test"
file size: 362 bytes

READY
? free
18998 
READY

```
[index](#index)
<a id="get"></a>
### GET(expr) {C,P}
Cette fonction fait parti du groupe de commandes et fonctions qui manipules la pile des arguments. Elle retourne la valeur qui se trouve sur la pile à la position désignée par *expr*. Voir aussi [PUT](#put)
<a id="etiquette"></a>
```
list
10 REM  exemple d'utilisation de la pile 
20 INPUT "nombre "N IF N=0 END 
30 PUSH N GOSUB SQUARE PRINT POP 
40 GOTO 20 
50 SQUARE PUSH GET (0 )*POP 
60 RETURN 
READY
run
nombre =25
625 
nombre =64
4096 
nombre =256
65536 
nombre =-1024
1048576 
nombre =0
READY
```

[index](#index)
<a id="gosub"></a>
### GOSUB *expr*|étiquette {P}
Appel de sous-routine. *expr* doit résulté en un numéro de ligne existant sinon le programme arrête avec un message d'erreur. À la place d'une expression arithmétique on peut utiliser une étiquette comme cible comme dans l'exemple [ci-haut](#etiquette) où **SQAURE** est utilisé comme nom d'une fonction et utilisé par le **GOSUB** de la ligne 30. Les appels vers les étiquettes sont légèrement plus rapides que les appels par numéro de ligne.  Notez que la recherche de la cible se fait à partir du début du programme. Donc plus la sous-routine est loin du début plus la recherche est longue. Pour optimizer la vitesse d'exécution est avantageux de placer les sous-routines au début du programme et le code principal à la fin.

Voir aussi [RETURN](#return).
```
list
5 REM  Label test 
10 A =0 T =TICKS 
14 REM  GOSUB and GOTO by line # 
20 GOSUB 1000 
30 IF A >10000 GOTO 50 
40 GOTO 20 
50 PRINT CHAR (13 ),TICKS -T ,"MSEC"
54 REM  GOSUB and GOTO by label 
60 A =0 :T =TICKS 
70 LOOP GOSUB CNTR 
80 IF A >10000 PRINT CHAR (13 ),TICKS -T ,"MSEC":END 
90 GOTO LOOP 
1000 CNTR 
1010 A =A +1 
1020 RETURN 
READY
run

414 MSEC

366 MSEC
READY
```

[index](#index)
<a id="goto"></a>
### GOTO *expr*|étiquette {P}
Passe le contrôle à la ligne dont le numéro est déterminé par *expr*. *expr* doit résulté en un numéro de ligne existant sinon le programme s'arrête avec un message d'erreur. Comme pour les **GOSUB** une étiquette peut-être utilisée à la place d'un numéro de ligne. 
```
10 A =0 
20 GOTO INCR 
30 IF A >20 END 
999 ' L'Étiquette se place immédiatement après le numéro de ligne.
1000 INCR PRINT A ,
1010 A =A +1 
1020 GOTO 30 
READY
RUN
0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 
READY
```
[index](#index)

<a id="gpio"></a>
### GPIOx {C,P}
Il y a 3 constantes système de définies pour les adresses de base des GPIO disponibles sur les broches de la **blue pill**, **GPIOA**,**GPIOB** et **GPIOC**.
L'exemple suivant fait clignoter la LED verte de la carte.
```
LIST
5 REM  CLIGNOTE LED VERTE DE LA CARTE BLUE PILL 
10 BLINK 
20 OUT GPIOC ,13 ,0 
30 PAUSE 200 
40 OUT GPIOC ,13 ,1 
50 PAUSE 200 
60 GOTO BLINK 
READY
RUN
READY

``` 

[index](#index)
<a id="hex"></a>
### HEX {C,P}
Sélectionne la base numérique hexadécimale pour l'affichage des entiers.
Voir la commande **DEC**  pour revenir en décimale.
```
HEX:?-10:DEC:?-10
$FFFFF6
-10
READY 
```

[index](#index)
<a id="if"></a>
### IF *relation* [THEN] cmd [cmd]* {C,P}
Le **IF** permet d'exécuter les instructions qui suivent sur la même ligne si l'évalution de *relation* est vrai. Toute valeur différente de zéro est considérée comme vrai.  Si la résultat de *relation* est zéro les instructions qui suivent le **IF** sont ignorées.  Il n'y a pas de **ENDIF** ni de **ELSE**. Toutes les instructions à exécuter doivent-être sur la même ligne que le **IF**. 

```
A=5%2 IF A ?"vrai";a
vrai    1 
READY
IF NOT A>2 ?"faux";a
faux    1 
READY
```
[index](#index)
<a id="in"></a>

### IN(GPIOx,pin) {C,P}
Cette fonction retourne l'état d'une broche configurée en entrée niveau logique.
```
LIST
10 PMODE GPIOA ,0 ,INPUT_FLOAT 
20 PRINT "connect A0 to 3.3v,press a key when ready"
30 DO UNTIL QKEY K =ASC (KEY )
40 PRINT IN (GPIOA ,0 )
50 PRINT "connect A0 to 0v, press a key when ready"
60 DO UNTIL QKEY K =ASC (KEY )
70 PRINT IN (GPIOA ,0 )
READY
RUN
connect A0 to 3.3v,press a key when ready
1 
connect A0 to 0v, press a key when ready
0 
READY

```

[index](#index)
<a id="input"></a>
### INPUT [*string*]*var* [,[*string*]*var*]+  {C,P}
Cette commande permet de saisir un entier fourni par l'utilisateur. Cet entier est déposé dans la variable donnée en argument. Plusieurs variables peuvent-être saisies en une seule commande en les séparant par la virgule. 
Facultativement un message peut-être affiché à la place du nom de la variable. Cette chaîne précède le nom de la variable sans virgule de séparation entre les deux.

```
10 input "age? "a,"sexe(1=M,2=F)? "s 
READY
RUN
age? 24
sexe(1=M,2=F)? 1
READY
? a,s
  24   1
READY
```
[index](#index)
<a id="input-xxx"></a>
### INPUT_xxx  {C,P}
Les constantes système suivantes sont définies pour être utilisées avec la commande [PMODE](#pmode) 

* **INPUT_ANA**  broche configurée en entrée analogique.
* **INPUT_FLOAT** broche configurée en entrée logique flottante.
* **INPUT_PD** broche configurée en entrée logique avec *pull down*.
* **INPUT_PP** broche configurée en entrée logique avec *pull up*.

Il y a aussi 4 constantes systèmes [OUTPUT_xxx](#output-xxx) pour configurer les modes sortie logique. 

[index](#index)
<a id="invert"></a>
### INVERT(*expr*) {C,P}
Cette fonciton retourne l'inverse binaire de *expr*. C'est à dire que la valeur de chaque bit de l'entier est inversé. 
```
? invert(5)
-6
READY
hex: ? invert(&101)
$FFFA   
READY 
```
[index](#index)
<a id="key"></a>
### KEY {C,P}
Attend qu'un caractère soit reçu du terminal. Ce caractère est retourné sous la forme d'un char et peut-être affecté à une variable par la fonction [ASC](#asc)().
```
? "Press a key to continue...":k=asc(key)
Press a key to continue...
READY

```

[index](#index)
<a id="let"></a>
### LET *var*=*expr* {C,P}
Affecte une valeur à une variable. En Tiny BASIC il n'y a que 26 variables représentées par les lettres de l'alphabet. Il y a aussi une variable tableau unidimensionnelle nommée **@**. **Notez** que le premier indice du tableau est **1**. 

*expr* arithmétique indique l'indice du tableau. Le mot réservé **LET** est facultatif. 
```
LET A=24*2+3:?a
  51
READY   
b=3*(a>=51):?b
   3
READY   
c=-4*(a<51):?c
   0
READY   
@(3)=24*3
READY
?@(3)
  72
READY

```

[index](#index)
<a id="list"></a>
### LIST [*expr1*][[-] *expr2*] {C}
Affiche le programme contenu dans la mémoire RAM à l'écran du terminal. 
*  **list**&nbsp;&nbsp; Le texte au complet est affichée.
*  **list n**&nbsp;&nbsp; Seule la ligne *n* est affichée.
*  **list n -**&nbsp;&nbsp;  La liste débute à la ligne *n* et se termine à la dernière.
* **list -n**&nbsp;&nbsp; La liste commence à *n* et va jusqu'à la fin.    
```
list
   10 REM Fibonacci
   20 A =1:B =1
   30 IF B >100:END 
   40 PRINT B ,
   50 C =A +B :A =B :B =C 
   60 GOTO 30
READY
run
   1   2   3   5   8  13  21  34  55  89
READY
```
[index](#index)
<a id="locate"></a>
### LOCATE ligne,colonne {C,P}
Sert à déplacer le curseur du terminal à une position déterminée. Les numéro de ligne et colonnne débute à **1** et non **0**.

[index](#index)
<a id="load"></a>
### LOAD *string*  {C}
Charge un fichier sauvegardé dans la mémoire flash vers la mémoire RAM dans le but de l'exécuter. *string* est le nom du fichier à charger.
```
save "fibonacci"
  86 bytes
READY
new
READY
li
READY
load "fibonacci"
  86 bytes
READY 
li
   10 'Fibonacci
   20 A =1:B =1
   30 IF B >100:END 
   40 PRINT B ,
   50 C =A +B :A =B :B =C 
   60 GOTO 30
READY
run
   1   2   3   5   8  13  21  34  55  89
READY 
```

[index](#index)
<a id="lshift"></a>
### LSHIFT(*expr1*,*expr2*) {C,P}
Cette fonction retourne la valeur de *expr1* décalée vers la gauche de **expr2** bits.
```
for i=0 to 15 ? lshift(1,i), next i
1 2 4 8 16 32 64 128 256 512 1024 2048 4096 8192 16384 32768 
READY
```
[index](#index)
<a id="new"></a>
### NEW  {C}
Cette commande efface le contenu de la mémoire RAM et sert à préparer le système pour l'édition ou le chargement d'un autre programme.

[index](#index)
<a id="next"></a>
### NEXT {C,P}
Ce mot réservé indique la fin d'une boucle **FOR...NEXT** pour plus d'information voir [FOR](#for)

[index](#index)
<a id="not"></a>
### NOT *relation* {C,P}
Cette fonction retourne le complément logique de la valeur de la relation qui suit.
Autrement dit si *relation* est vrai **NOT** retourn faux et vice-versa.
Sert a inverser la valeur d'une relation après un [IF](#if) ou un [UNTIL](#until).
```
READY
a=1 if a>2 ? "vrai "
READY
if not a>2 ? "vrai "
vrai 
READY
```
[index](#index)
<a id="or"></a>
### OR(*expr1*,*expr2*) {C,P}
 Cette fonction applique une opération **OU** bit à bit entre les 2 arguments.
```
? or(14,1)
  15
READY
? or($AA,$55)
 255
READY
```

[index](#index)
<a id="out"></a>
### OUT *GPIOx*,pin,0|1* {C,P}
Cette commmande est utilisée pour déterminer l'état d'une broche configurée en sortie niveau logique. 

* **GPIOx** représente une des constante système **GPIOA**, **GPIOB** ou **GPIOC**.
* **pin** est le numéro de la broche {0..15}.
* **0|1** est l'état désiré à la sortie.
```
list
5 REM  GPIO test 
10 INPUT "gpio:a,b,c,d?"G ,"pin"P 
20 G =GPIOA +(G -65 )*1024 :P =AND (P ,15 )
30 PMODE G ,P ,OUTPUT_PP 
40 OUT G ,P ,1 
50 PAUSE 100 
60 OUT G ,P ,0 
70 PAUSE 100 
80 IF NOT QKEY THEN GOTO 30 
90 GOTO 10 
READY
run
gpio:a,b,c,d?=c
pin=13
gpio:a,b,c,d?=
READY
```
[index](#index)
<a id="output-xxx"></a>
### OUTPUT_xxx {C,P}
Quatre constantes système sont définies pour les modes sortie des broches GPIO.
Ces constantes sont utilisées avec [PMODE](#pmode).
* **OUTPUT_AFOD**&nbsp;&nbsp; Sortie alternative drain ouvert.
* **OUTPUT_AFPP**&nbsp;&nbsp; Sortie alternative push pull.
* **OUTPUT_OD**&nbsp;&nbsp; Sortie niveau logique drain ouvert.
* **OUTPUT_PP**&nbsp;&nbsp; Sortie niveau logique push pull.

Une sorte alternative est une sortie contrôlée par un périphérique plutôt que par la commande [OUT](#out). Pour un exemple voir la commande précédente [OUT](#out).

[index](#index)
<a id="pad"></a>
### PAD {C,P}
Retourne l'adresse du tampon de 128 octets utilisé pour la compilation et d'autres fonctions.
```
? pad
536890800 
READY
```
Ce tampon se trouve juste avant le tampon *tib* qui est un tampon de 80 octets utilisé entre autre pour la lecture des commandes. 

[index](#index)
<a id="pause"></a>
### PAUSE *expr* {C,P}
Cette commande suspend l'exécution pour un nombre de millisecondes équivalent à la valeur d'*epxr*. pendant la pause le CPU est en mode suspendu c'est à dire qu'aucune instruction n'est exécutée jusqu'à la prochaine interruption. La commande **PAUSE** utilise l'instruction machine *wfi* pour suspendre le processeur. Le TIMER4 génère une interruption à chaque milliseconde. Le compteur de **PAUSE** est alors décrémenté et lorsqu'il arrive à zéro l'exécution du programme reprend.
```
10 INPUT "pause en secondes?"P 
list
10 INPUT "pause en secondes?"P 
20 IF P =0 END 
30 PAUSE 1000 *P 
40 GOTO 10 
READY
run
pause en secondes?=2
pause en secondes?=1
pause en secondes?=5
pause en secondes?=0
READY
```
[index](#index)
<a id="peekx"></a>
### PEEKx(*expr*) {C,P}
Il y a 3 fonction PEEKx().
* **PEEKB**&nbsp;&nbsp; Retourne l'octet situé à l'adresse *expr*.
* **PEEKH**&nbsp;&nbsp; Retourne le mot de 16 bits situé à l'adresse *expr*.
* **PEEKW**&nbsp;&nbsp; Retourne le mot de 32 bits situé à l'adresse *expr*.
```
hex pokew pad,$11223344 ?peekb(pad),peekh(pad),peekw(pad)
$44 $3344 $11223344 
READY
```

[index](#index)
<a id="pinp"></a> 
### PINP pin  {C,P}
Constante utilisée par la commande [PMODE](#pmode) pour définir une broche en mode entrée logique.

[index](#index)
<a id="pmode"></a>
### PMODE *GPIOx*,*pin*,*mode*
Configure le mode entrée/sortie des broches GPIO. 
* *GPIOx*&nbsp;&nbsp; Est une des constantes système **GPIOA**, **GPIOB** ou **GPIOC**. 
* *pin* Est le numéro de la broche à configurer {0..15}.
* *mode* Est l'un des mode [entrée](#input-xxx) ou [sortie](#output-xxx) niveau logique.
```
5  REM clignote LED vers 10 fois/secondes.
10 PMODE GPIOC,13,OUTPUT_OD 
20 OUT GPIOC,13,1
30 PAUSE 100
40 OUT GPIOC,13,0
50 PAUSE 100
60 GOTO 20 
```
[index](#index)
<a id="pokex"></a>
### POKEx *expr1*,*expr2*
Dépose la valeur de *expr2* à l'adresse de *expr1*.Il y a 3 commandes POKEx.
* **POKEB**&nbsp;&nbsp; Pour déposer un octet. 
* **POKEH**&nbsp;&nbsp; Pour déposer un mot de 16 bits.
* **POKE2**&nbsp;&nbsp; Pour déposer un mot de 32 bits.
```
POKEB $20000400,$11 POKEH $20000401,$2233 POKEW $20000403,$44556677
READY
DUMP $20000400,15
           00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F 
===============================================================================
$20000400  11 33 22 77 66 55 44 00 00 00 00 00 00 00 00 00   _3"wfUD_________
READY
```
Vous remarquerez que la commande [DUMP](#dump) affiche l'ordre des octets en inverse car le système est *little indian*. 

[index](#index)
<a id="pop"></a>
### POP  {C,P} 
Il s'agit d'une des fonctions de manipulation de la pile des arguments. Cette fonction enlève l'élément au sommet de la pile et le retourne. Voir [PUSH](#push)
```
PUSH 12345 ? POP
12345 
READY
```

[index](#index)
<a id="print"></a>
### PRINT [*string*|*expr*|*char*][,*string*|*expr*|*char*][','|';'] {C,P}
La commande **PRINT** sans argument envoie le curseur du terminal sur la ligne suivante. Si la commande se termine par une virgule il n'y a pas de saut à la ligne suivante et la prochaine commande **PRINT** se fera sur  la même ligne. Les arguments sont séparés par la virgule.

* **#n**&nbsp;&nbsp; Détermine la largeur des colonnes pour la tabulation.
* **,**&nbsp;&nbsp; Sépare les éléments de la liste. Si c'est le dernier élément de la ligne annule le retour à la ligne automatique.
* **;**&nbsp;&nbsp; Déplace le curseur à la colonne suivante.


Le **'?'** peut-être utilisé à la place de **PRINT**.

**PRINT** accepte 3 types d'arguments: 

* *string*,  chaîne de caractère entre guillemets
* *expr*,   Toute expression arithmétique ou relationnelle qui retourne un entier.
* *char*,  Un caractère ASCII pécédé de **\\** ou tel que retourné par la fonction **CHAR()**.
```
? \a;"Hello world";2*56
a   Hello world 112 
READY
for a=1 to 10 for b=1 to 10 ?a*b; next b ? next a
1   2   3   4   5   6   7   8   9   10  
2   4   6   8   10  12  14  16  18  20  
3   6   9   12  15  18  21  24  27  30  
4   8   12  16  20  24  28  32  36  40  
5   10  15  20  25  30  35  40  45  50  
6   12  18  24  30  36  42  48  54  60  
7   14  21  28  35  42  49  56  63  70  
8   16  24  32  40  48  56  64  72  80  
9   18  27  36  45  54  63  72  81  90  
10  20  30  40  50  60  70  80  90  100     
READY
```
[index](#index)
<a id="push"></a>
### PUSH *expr* [,expr]* {C,P}
Cette commande empile une ou plusieurs arguments au sommet de la pile.
Voir aussi [POP](#pop).
```
PUSH 45,90 ? POP*POP
4050 
READY
```
[index](#index)
<a id="put"></a>
### PUT *position, expr* {C,P}
Insère sur la pile à la position donnée la valeur d'*expr*. Voir aussi [GET](#get).
```
list
10 REM  exemple d'utilisation de la pile 
20 INPUT "nombre "N IF N=0 END 
30 PUSH N GOSUB SQUARE PRINT POP 
40 GOTO 20 
50 SQUARE PUSH GET (0 )*POP 
60 RETURN 
READY
run
nombre =25
625 
nombre =64
4096 
nombre =256
65536 
nombre =-1024
1048576 
nombre =0
READY
```

[index](#index)
<a id="qkey"></a>
### QKEY {C,P}
Cette commande vérifie s'il y a un caractère en attente dans le tampon de réception du terminal. Retourne **1** si c'est le cas sinon retourne **0**.
```
DO ? "J'ATTEND UNE TOUCHE" UNTIL QKEY 
J'ATTEND UNE TOUCHE
J'ATTEND UNE TOUCHE
J'ATTEND UNE TOUCHE
J'ATTEND UNE TOUCHE
J'ATTEND UNE TOUCHE
READY
```

[index](#index)
<a id="read"></a>
### READ {P}
Cette fonction retourne l'entier pointé par le pointeur de donné initialisé avec les commandes **RESTORE**. À chaque appel de **READ** le pointeur est avancé à l'item suivant et s'il y a plusieurs lignes **DATA** dans le programme et que la ligne courante est épuisée, le pointeur passe à la ligne suivante. C'est une erreur fatale d'invoquer **READ** lorsque toutes les données ont étées lues. Cependant le pointeur peut-être réinitialisé avec la commande [RESTORE](#restore). 
Les lignes [DATA](#data) doivent-être consécutives, cependant plusieurs groupes de [DATA](#data) peuvent-être créés et la commande [RESTORE](#restore) permet de passe de l'un à l'autre. 
```
10 RESTORE
20 DATA 100,200
30 DATA 300
40 PRINT READ,READ,READ,READ
RUN
100 200 300 
Runtime error: No data found.
40 PRINT READ ,READ ,READ ,READ 
token offset: $10 
           00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F 
===============================================================================
$20000232  28 00 11 17 37 15 3B 02 15 3B 02 15 3B 02 15 3B   (___7_;__;__;__;
$20000242  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ________________
READY
```
Dans cet exemple il y a 3 données disponibles mais on essai dans lire 4. Donc à la quatrième invocation de **READ** le programme s'arrête et affiche l'erreur *No data found.*

[index](#index)
<a id="reboot"></a>
### REBOOT {C,P}
Réinitialise le MCU 
```
>reboot

Tiny BASIC for STM8
Copyright, Jacques Deschenes 2019,2020
version 1.0

>
```

[index](#index)
<a id="remark"></a>
### REM  *texte*
La commande **REM**  sert à insérer des commentaires (*remark*) dans un programme pour le documenter. Le mot réservé **REM** peut-être avantageusement remplacé par le caractère apostrophe (**'**). Un commentaire se termine avec la ligne et est ignoré par l'interpréteur.
```
>list
   10 REM ceci est un commentaire
   20 'ceci est aussi un commentaire
```
[index](#index)
<a id="restore"></a>
### RESTORE [*ligne*] {p}
Cette commande initialise le pointeur de [DATA](#data) au début de la première ligne de données. Il peut être invoqué à l'intérieur d'une boucle si on veut relire les même données plusieurs fois. Pour un exemple d'utilisation voir la fonction [READ](#read). On peut déplacer le pointeur de données à une *ligne* spécifique.
Voir aussi [DATA](#data).
```
LIST
10 RESTORE 30 
20 DATA 100 ,200 
30 DATA 300 ,400 
40 PRINT READ ,READ 
READY
run
300 400 
READY
```

[index](#index)
<a id="return"></a>
### RETURN {P}
La commande **RETURN**  indique la fin d'une sous-routine. Lorsque cette commande est rencontrée l'exécution se poursuit à la ligne qui suit le **GOSUB** qui a appellé cette sous-routine.
```
list
    5 ? #6,"Suite de Fibonacci,'q'uitter, autre suivant"
   10 a=1:b=1:f=1
   12 ? f,
   20 gosub 100
   30 r=key:if r=asc("q"):end
   40 goto 20
  100 'imprime terme, calcule suivant
  110 ?f,
  120 a=b:b=f:f=a+b
  130 return
READY
run
Suite de Fibonacci,'q'uitter, autre suivant
     1     1     2     3     5     8    13    21    34    55    89
READY
```
Dans cet exemple chaque fois qu'on presse une touche sur la console le terme suivant de la suite de Fibonacci est imprimé. La touche 'q' termine le programme. 

[index](#index)
<a id="rnd"></a>
### RND(*expr*) {C,P}
Cette fonction retourne un entier aléatoire dans l'intervalle {0..*expr*-1}.
*expr* doit-être un nombre positif sinon le programme s'arrête et affiche un message d'erreur.
```
?#6:r=32767:for a=1to 100:r=rnd(r):?r,:r=abs(r*113):next a

26708 2398462 3992313 62094558 1047456956 1404961041 82624343 11039876 879731728 440181042 340894422 115162637 94102159 67648478 708456947 1337733663 767618084 461191774 25599000 1134381505 532465591 34484486 161963765 160069694 83387822 689603438 238059097 455561372 14438395 793865 52903442 406393055 800048765 186978385 283980428 578331003 238015419 618795670 567960742 213551077 705961108 742416395 1076581459 728025280 193513687 303350928 22989376 73384150 146871593 237966286 903704398 165940979 836034027 11600184 246786862 407839083 722703445 30961426 734191795 1010737526 517861439 1535727073 1094661097 7625558 458474017 123172608 38113517 5724 220541 24466444 565933346 58031897 241000300 325655977 1508248153 1341126213 727233115 248527560 161447727 372760564 147722663 74777901 103910894 1132304415 696163036 917812709 619192523 972106264 510279929 1128802931 260625422 566311042 176861545 1285534561 16839213 175628 17729005 1338291976 642481850 115363788 
READY
```
[index](#index)
<a id="rshift"></a>
### RSHIFT(*expr1*,*expr2*) {C,P}
Cette fonction décale vers la droite *expr1* de *expr2* bits. Le bit le plus signficatif est remplacé par un **0**.
```
? rshift($80,7)
   1
READY
?rshift($40,4) 
   4
READY
```
[index](#index)
<a id="run"></a>
### RUN {C}
Lance l'exécution du programme qui est chargé en mémoire RAM. Si aucun programme n'est chargé il ne se passe rien.

[index](#index)
<a id="save"></a>
### SAVE *string* 
Sauvegarde le programme qui est en mémoire RAM dans un fichier. La mémoire FLASH étendue qui n'est pas utilisée par Tiny BASIC est utilisée comme mémoire permanente pour un système de fichier rudimentaire où les programmes sont sauvegardés. *string* est le nom du fichier. Si un fichier avec ce nom existe déjà un message d'erreur s'affiche. À la fin de  la commande la taille du programme sauvegardé est affichée.
```
list
5 REM  CLIGNOTE LED VERTE DE LA CARTE BLUE PILL 
10 BLINK 
20 OUT GPIOC ,13 ,0 
30 PAUSE 200 
40 OUT GPIOC ,13 ,1 
50 PAUSE 200 
60 GOTO BLINK 
READY
save "blink"
file size: 137 bytes

READY
dir
blink          137 

               1 files

READY
```
[index](#index)
<a id="servo-init"></a>
### SERVO_INIT *n* {C,P}
 Cette commande initialise l'une des 6 sorties de contrôle d'un servo-moteur.
 Les sorties sont sur A15,B3,B4,B5,B8 et B9. Les broches de sorties pour les servo-moteurs sont configurées en **open drain** et requière une résistance *pull up* externe branchée au même voltage d'alimentation que le servo-moteur. Voltage qui est habituellement de 5 volts pour les petits servo-moteurs.
 Voir aussi [SERVO_POS](#servo-pos) ainsi que [SERVO_OFF](#servo-off)
```
list
10 REM  servo test
12 REM  channel 1 on A15, channel 2 on B3
14 REM  channel 3 on B4, channel 4 on B5 
15 REM  channel 5 on B8, channel 6 on B9 
20 PRINT "select channel 1,2,3,4,5,6"
30 INPUT S 
40 IF S <1 THEN GOTO 20 
50 IF S >4 THEN GOTO 20 
80 SERVO_INIT S 
90 PRINT "set position 1000-2000"
100 INPUT P 
110 IF P =ASC (\N)THEN SERVO_OFF S GOTO 20 
120 IF P =ASC (\Q)THEN GOTO 150 
130 SERVO_POS S ,P 
140 GOTO 90 
150 SERVO_OFF S 
160 END 
READY
```
[index](#index)
<a id="servo-off"></a>
### SERVO_OFF *n* {C,P}
Cette commande sert à désactiver un canal servo-moteur. Voir [SERVO_INIT](#servo-init)

[index](#index)
<a id="servo-pos"></a>
### SERVO_POS *canal, position* {C,P}
Cette commande sert à contrôler la position d'un servo-moteur. Voir la commande [SERVO_INIT](#servo-init).

[index](#index)
<a id="sleep"></a>
### SLEEP {C,P}
Cette commande place le MCU en sommeil profond. En mode *sleep* le processeur est suspendu et dépense un minimum d'énergie. Pour redémarrer le processeur il faut  presser le bouton reset. 

[index](#index)
<a id="spien"></a>
### SPIEN *div*,*0|1*
Commande pour activer le périphérique SPI l'interface matérielle du SPI est sur les broches **D10**, **D11**, **D12** et **D13** du connecteur **CN8**. L'argument *div* détermine la fréquence d'horloge du SPI. C'est une nombre entre **0** et **7**. La fréquence Fspi=Fsys/2^(div+1). Donc pour zéro Fspi=Fsys/2 et pour 7 Fspi=Fsys/256. Le deuxième argument détermine s'il s'agit d'une activation **1** ou d'une désactivation **0** du périphérique.   

[index](#index)
<a id="spc"></a>
### SPC(n)  
Cette commande est utillisée à l'intérieur de la commande [PRINT](#print) pour faire avancer le curseur de *n* espaces. 
```
? \a,spc(5),\b
a     b
READY
```

[index](#index)
<a id="spird"></a>
### SPIRD 
Cette fonction lit un octet à partir du périphérique SPI. Cet octet est retourné comme entier.

[index](#index)
<a id="spiwr"></a>
### SPIWR *byte* [, byte] 
Cette commande permet d'envoyer un ou plusieurs octets vers le périphérique SPI. Le programme suivant illustre l'utilisation de l'interface SPI avec une mémoire externe EEPROM 25LC640. Le programme active l'interface SPI à la fréquence de 2Mhz (16Mhz/2^(2+1)). Ensuite doit activé le bit **WEL** du **25LC640** pour authorizer l'écriture dans l'EEPROM. Cette EEPROM est configurée en page de 32 octets. On écris donc 32 octets au hazard à partir de l'adresse zéro. pour ensuite refaire la lecture de ces 32 octets et les affichés à l'écran. 
```
>li 
   10 SPIEN 2,1' spi clock 2Mhz
   20 SPISEL 1:SPIWR 6:SPISEL 0 'active bit WEL dans l'EEPROM 
   22 SPISEL 1:SPIWR 5:IF NOT (AND (SPIRD ,2)):GOTO 200
   24 SPISEL 0
   30 SPISEL 1:SPIWR 2,0,0
   40 FOR I =0TO 31:SPIWR RND (256):NEXT I 
   42 SPISEL 0
   43 GOSUB 100' wait for write completed 
   44 SPISEL 1:SPIWR 3,0,0
   46 HEX :FOR I =0TO 31:PRINT SPIRD ,:NEXT I 
   50 SPISEL 0
   60 SPIEN 0,0
   70 END  
   90 ' wait for write completed 
  100 SPISEL 1:SPIWR 5:S =SPIRD :SPISEL 0
  110 IF AND (S ,1):GOTO 100
  120 RETURN 
  200 PRINT "Echec activation bit WEL dans l'EEPROM"
  210 SPISEL 0
  220 SPIEN 0,0

>run
 $3F $99 $19 $73 $4C $FE $B1 $66 $88 $7F $31 $FD $AD $BA $78 $1B $78 $2F $23 $59 $7D $C6 $2E $D0 $80 $7A $19 $E8 $53 $BC  $5 $AC
>run
 $A0 $AE $DD $32 $C5 $D6 $DB $43 $90 $CA $CF $60 $37 $B9 $D8 $C0  $7 $3B $AE $B2 $58 $5F $B5 $33 $8D $1D $7D $3F $94 $7D $FF $F3
>
```

[index](#index)
<a id="step"></a>
### STEP *expr* {C,P}
Ce mot réservé fait partie de la commande [FOR](#for) et indique l'incrément de la variable de contrôle de la boucle. Pour plus de détail voir la commande [FOR](#for). 

[index](#index)
<a id="stop"></a>
### STOP {P}
Outil d'aide au débogage. Cette commande interrompt l'exécution du programme au point où elle est insérée. L'utilisateur se retrouve donc sur la ligne de commande où il peut exécuter différentes commandes comme examiner le contenu des variables et de la mémoire avec commande [DUMP](#dump). Le programme est redémarré à son point d'arrêt avec la commande **RUN**.  La commande **END** interompt l'exécution.
```
10 for a=1 to 10 ? a, stop next a
run
1 
run
2 
run
3 
run
4 
end
READY
```
Dans cet exemple la commande **STOP** a été insérée à l'intérieur d'une boucle [FOR...NEXT](#for) donc le programme s'arrête à chaque itération.

[index](#index)
<a id="store"></a>
### STORE adr, *expr* {C,P}
Cette commande sert à écrire une valeur dans la mémoire flash utilisateur. 1Ko de mémoire flash est réservé pour la sauvegarde de données persistantes. *expr* est un l'entier de 32 bits sauvegardé à l'adresse *adr*.
Voir [UFLASH](#uflash) et [ERASE](#erase) pour plus d'information.

[index](#index)
<a id="tab"></a>
### TAB(n) {C,P}
Cette commande est utilisée à l'intérieur de la commande [PRINT](#print) pour déplacer le curseur à la colonne *n*. Voir aussi [SPC](#spc).
```
? "hello", tab(20),"world!"
hello              world!
READY
```
[index](#index)
<a id="ticks"></a>
### THEN 
Ce mot réservé est utilisé avec le [IF](#if) pour séparé la relation des commandes à exécuter si la relation est vrai. Son utilisation est facultative.

[index](#index)
<a id="ticks"></a>
### TICKS {C,P}
Le systême entretien un compteur de millisecondes.  Cette commande retourne la valeur de ce compteur. Le compteur est de 24 bits donc le *roll over* est de 16777216 millisecondes. Ce compteur peut-être utilisé pour chronométrer la durée d'exécution d'une routine. Par exemple ça prend combien de temps pour exécuter 100000 boucles FOR vide.
```
t=ticks for a=1 to 100000 next a ? ticks-t
257 
READY
```
Réponse: 257 millisecondes. 

[index](#index)
<a id="timeout"></a>
### TIMEOUT 
Cette fonction s'utilise avec la commande [TIMER](#timer) et retourne **-1** si la minuterie est expirée ou **0** autrement.

```
timer 10 do a=timeout ? a, until a
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 
READY
```

[index](#index)
<a id="timer"></a>
### TIMER *expr* {C,P}
Cette commande sert à initialiser une minuterie. *expr* doit résulté en un entier qui représente le nombre de millisecondes. Contrairement à **PAUSE** la commande **TIMER** ne bloque pas l'exécution. On doit vérifier l'expiration de la minuterie avec la fonction [TIMEOUT](#timeout).  

[index](#index)
<a id="to"></a>
### TO *expr* {C,P}
Ce mot réservé est utilisé lors de l'initialisation d'une boucle [FOR](#for). *expr* détermine la valeur limite de la variable de contrôle de la boucle. Voir la commande [FOR](#for) pour plus d'information. 

[index](#index)
<a id="tone"></a>
### TONE *expr1*,*expr2* {C,P}
Cette commande génère une tonalité de fréquence déterminée par *expr1* et de durée *expr2* en millisecondes. La sortie est sur **B6**. La minuterie **TIMER4** est utilisée et configurée en mode PWM avec un rapport cyclique de 50%. Voir [TONE_INIT](#tone-init).
```  
list
5 REM  ce programme joue la gamme.
7 TONE_INIT 
10 @(1 )=440 :@(2 )=466 :@(3 )=494 :@(4 )=523 :@(5 )=554 :@(6 )=587 
20 @(7 )=622 :@(8 )=659 :@(9 )=698 :@(10 )=740 :@(11 )=784 
24 @(12 )=831 
30 FOR I =1 TO 12 :TONE @(I ),200 :NEXT I 
READY
``` 
[index](#index)
<a id="tone-init"></a>
### TONE_INIT 
Initialise le générateur de tonalité. Voir [TONE](#tone).

[index](#index)
<a id="trace"></a>
### TRACE 0|1|2|3 {P}
Cette commande est un outil de débogage des programmes. 
* **0**&nbsp;&nbsp; Trace est désactivé. 
* **1**&nbsp;&nbsp; Trace affiche chaque numéro de ligne exécuté.
* **2**&nbsp;&nbsp; Trace affiche le numéro de ligne et le contenu de la pile des arguments. 
* **3**&nbsp;&nbsp; Trace affiche le numéro de ligne, le contenu de la pile des arguments et de la pile des retours.

Trace peut-être activé et désactivé n'importe où dans un programme.   

[index](#index)
<a id="ubound"></a>
### UBOUND {C,P}
Cette fonction retourne la taille de la variable tableau **@**. Comme expliqué plus haut cette variable utilise la mémoire RAM qui n'est pas utilisée par le programme BASIC. Donc plus le programme prend de place plus sa taille diminue. Un programme peut donc invoqué cette commande pour connaître la taille de **@** dont il dispose.
```
? ubound
4772 
READY
new 
READY
? ubound
4840 
READY
```
[index](#index)
### UFLASH (C,P)
<a id="uflash"></a>
Retourne l'adresse du début de la mémoire FLASH disponible à l'utilisateur. Il s'agit d'un espace de 1Ko réservé pour les programmes BASIC où ils peuvent sauvegarder des données persistantes. Cependant les 16 premiers octets sont réservés pour la commande [AUTORUN](#autorun).
```
DUMP UFLASH,32
           00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F 
===============================================================================
$8004400   FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF   ________________
$8004410   FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF   ________________
$8004420   FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF   ________________
READY
STORE UFLASH+16,$12345678
READY
DUMP UFLASH,32
           00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F 
===============================================================================
$8004400   FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF   ________________
$8004410   78 56 34 12 FF FF FF FF FF FF FF FF FF FF FF FF   xV4_____________
$8004420   FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF   ________________
READY
```
Voir aussi [ERASE](#erase) et [AUTORUN](#autorun).

[index](#index)
<a id="until"></a>
### UNTIL *expr* {C,P}
Mot réservé qui ferme une boucle [DO...UNTIL](#do).  Les instructions entre le [DO](#do) et le **UNTIL** s'exécutent en boucle aussi longtemps que **expr** est faux. Voir [DO](#do).
```
list
10 A =1 
20 DO 
30 PRINT A ,
40 A =A +1 
50 UNTIL A >10 
READY
run
1 2 3 4 5 6 7 8 9 10 
READY
```
[index](#index)
<a id="wait"></a>
### WAIT *expr1*,*expr2*[,*expr3] {C,P}
Cette commande sert à attendre un changement d'état sur un périphérique.
*expr1* indique l'adresse du registre de périphérique susceptible de changer d'état. *expr2*.
L'attente se poursuit tant que (*expr1* & *expr2*)^*epxr3* n'est pas nul. Si *eprx3* n'est pas fournie l'attente se poursuit tant que (*expr1* & *expr2*) est nul. 
```
list
10 PMODE GPIOA ,0 ,INPUT_FLOAT 
20 PRINT "put A0 to 0volt and press key"
30 DO UNTIL QKEY K =ASC (KEY )
40 PRINT "put A0 to 3.3volt"
50 WAIT GPIOA +8 ,1 ,0 
READY
run
put A0 to 0volt and press key
put A0 to 3.3volt
READY
```
Le programme se termine lorsque A0 est placé à 3.3 volt.

[index](#index)
<a id="words"></a>
### WORDS {C,P}
Affiche la liste de tous les mots qui sont dans le dictionnaire. Le dictionnaire est une liste chaînée des noms des commandes et fonctions de Tiny Basic en relation avec l'adresse d'exécution. 
```
words
ABS ANA ADC AND ASC AUTORUN AWU BIT BRES BSET BTEST BTOGL CHAR CLS CONST DATA 
DEC DIR DO DROP DUMP END ERASE FOR FORGET FREE GET GOSUB GOTO GPIOA GPIOB GPIOC 
HEX IF IN INPUT INPUT_ANA INPUT_FLOAT INPUT_PD INPUT_PU INVERT KEY LET LIST LOAD 
LOCATE LSHIFT NEW NEXT NOT OR OUT OUTPUT_AFOD OUTPUT_AFPP OUTPUT_OD OUTPUT_PP PAD 
PAUSE PEEKB PEEKH PEEKW PMODE POKEB POKEH POKEW POP PRINT PUSH PUT QKEY READ REM 
RESTORE RETURN RND RSHIFT RUN SAVE SERVO_INIT SERVO_OFF SERVO_POS SLEEP SPC STEP STOP 
STORE TAB THEN TICKS TIMEOUT TIMER TO TONE TONE_INIT TRACE UBOUND UFLASH UNTIL WAIT 
WORDS XOR XPOS YPOS 
103 words in dictionary
READY
```

[index](#index)
<a id="xor"></a>
### XOR(*expr1*,*expr2*) {C,P}
Cette fonction applique la fonction **ou exclusif** bit à bit entre les 2 epxressions.
```
? xor($aa,$55)
 255
READY 
hex:?xor($aa,$a)
 $A0
READY
```

[index](#index)
<a id="xpos"></a>
### XPOS {C,P}
Retourne la colonne où se trouve le curseur du terminal.

[index](#index)
<a id="ypos"></a>
### YPOS {C,P}
Retourne la ligne sur laquelle se trouve le curseur du terminal.

[index](#index)

[index principal](#index-princ)
<hr>

<a id="install"></a>
## Installation de Tiny BASIC sur la carte **blue pill**
À partir du répertoire racine du projet
. Lorsque la carte est branchée au programmeur STLINK-V2 et prête à être programmée faites la commande suivante:
```
picatout:~/github/stm32-tbi$ make build && make flash
arm-none-eabi-as  -a=build/stm32-tbi.lst stm32-tbi.s -g -obuild/stm32-tbi.o 
arm-none-eabi-as  -a=build/terminal.lst terminal.s -g -obuild/terminal.o 
arm-none-eabi-as  -a=build/tinyBasic.lst tinyBasic.s -g -obuild/tinyBasic.o 
arm-none-eabi-ld -T stm32f103c8t6.ld  -g build/stm32-tbi.o build/terminal.o build/tinyBasic.o  -o build/stm32-tbi.elf
arm-none-eabi-objcopy -O binary build/stm32-tbi.elf build/stm32-tbi.bin 
arm-none-eabi-objdump -D build/stm32-tbi.elf > build/stm32-tbi.dasm
st-flash --serial=483f6e066772574857351967 erase 
st-flash 1.6.0
2021-03-14T11:15:56 INFO usb.c: -- exit_dfu_mode
2021-03-14T11:15:56 INFO common.c: Loading device parameters....
2021-03-14T11:15:56 INFO common.c: Device connected is: F1 Medium-density device, id 0x20036410
2021-03-14T11:15:56 INFO common.c: SRAM size: 0x5000 bytes (20 KiB), Flash: 0x10000 bytes (64 KiB) in pages of 1024 bytes
Mass erasing
st-flash  --serial=483f6e066772574857351967  write build/stm32-tbi.bin 0x8000000
st-flash 1.6.0
2021-03-14T11:15:56 INFO common.c: Loading device parameters....
2021-03-14T11:15:56 INFO common.c: Device connected is: F1 Medium-density device, id 0x20036410
2021-03-14T11:15:56 INFO common.c: SRAM size: 0x5000 bytes (20 KiB), Flash: 0x10000 bytes (64 KiB) in pages of 1024 bytes
2021-03-14T11:15:56 INFO common.c: Ignoring 1024 bytes of 0xff at end of file
2021-03-14T11:15:56 INFO common.c: Attempting to write 17408 (0x4400) bytes to stm32 address: 134217728 (0x8000000)
Flash page at addr: 0x08004000 erased
2021-03-14T11:15:57 INFO common.c: Finished erasing 17 pages of 1024 (0x400) bytes
2021-03-14T11:15:57 INFO common.c: Starting Flash write for VL/F0/F3/F1_XL core id
2021-03-14T11:15:57 INFO flash_loader.c: Successfully loaded flash loader in sram
 17/17 pages written
2021-03-14T11:15:58 INFO common.c: Starting verification of write complete
2021-03-14T11:15:58 INFO common.c: Flash written and verified! jolly good!
picatout:~/github/stm32-tbi$ 
```
Si tout se passe comme prévue le système **blue pill tiny BASIC** est maintenant installé sur la carte et prêt à l'utilisation.

[index principal](#index-princ)

<a id="utilisation"></a>
# Utilisation de blue pill Tiny BASIC
Vous trouverez dans le manuel de l'[utilisateur de tiny BASIC](manuel_util_tb.md) des exemples d'utilisation. 

[index principal](#index-princ)

<a id="xmodem"></a>
# Transfert de fichiers
Le projet comprend le sous-module **sendFile**. Ansi que le shell script [send](../send) qui permet de transmettre des progammes basic à la carte. Il s'agit d'un utilitaire de ligne de commandes qu'on lance à partir du répertoire racine du projet. le dossier **tb_progs** contient des exemples de programmes. Pour transmettre un programme à la carte il suffit de faire:
```
picatout:~/github/stm32-tbi$ ./send gpio-test.bas
port=/dev/ttyS0, baud=115200,delay=50 
Sending file tb_progs/gpio-test.bas
12 lines sent
```
L'émulateur de terminal doit-être ouvert et branché à la carte avant de lancer cette commande. On voit alors les lignes du programme défilées sur l'écran du terminal. Une fois la transmission terminée le programme peut-être lancé avec la commande [RUN](#run) ou sauvegardé dans la mémoire flash avec la commande [SAVE](#save).

[index principal](#index-princ)

# Éditeur de texte de Tiny BASIC
Le système **blue pill tiny BASIC** est conçu pour fonctionner avec n'importe quel PC peut importe le système d'exploitation utilisé. Pour se faire l'édition et la compilation du texte BASIC s'effetuent entièrement sur la carte **blue pill**. 

Chaque ligne saisie au terminal est compilée et stockée en mémoire RAM dès que la touche &lt;ENTER&gt; est enfoncée. Si le texte saisie ne débute pas par un numéro de ligne il est considéré comme une commande immédiate et est exécuté plutôt que stocké. Les lignes de textes déjà saisie peuvent-être examinées à l'aide de la commande [LIST](#list). 
## Possibilité de l'éditeur de texte
* Modification d'une ligne déjà compilée, Numéro de ligne suivit de &lt;CTRL-E&gt;
* Suppression d'une ligne déjà compilée, Numéro de ligne suivit de &lt;ENTER&gt;
* Insertion d'une nouvelle ligne à n'importe quel point du programme. Les nouvelles lignes sont insérées à la bonne position selon l'ordre croissant des numuros de lignes.
## Touches de contrôles de l'éditeur
* **&lt;CTRL-D&gt;** Efface la ligne en cours d'édition au complet.
* **&lt;CTRL-E&gt;** Après la saisie d'un numéro de ligne affiche cette ligne pour édition. 
* **&lt;CTRL-I&gt;** L'éditeur passe en mode insertion, le curseur est une ligne verticale clognotante. 
* **&lt;CTRL-O&gt;** L'éditeur passe en mode écrasement, le curseur est un bloc clignotant. 
* **&lt;CTRL-R&gt;** Réaffiche la dernière ligne saisie. Permet de réexécuter une commande immédiate rapidement.
* **&lt;HOME&gt;** Déplace le curseur au début de la ligne de texte.
* **&lt;END&gt;** Déplace le curseur à la fin de la ligne de texte.
* **&lt;BS&gt;** Efface le caractère à gauche du curseur.
* **&lt;DEL&gt;** Efface le caractère sous le curseur.
* **&lt;LEFT-ARROW&gt;** Déplace le curseur un caractère vers la gauche.
* **&lt;RIGHT-ARROW&gt;** Déplace le curseur un caractère vers la droite. 

[index principal](#index-princ)

<a id="sources"></a>
# code source 
Le code source est entièrement écris en assembleur et comprend les fichiers suivants.
* [stm32-tbi.s](../stm32-tbi.s)  Initialisation matérielle et interfaces de bas niveaux.
* [tinyBasic.s](../tinyBasic.s) L'interpréteur BASIC.
* [terminal.s](../terminal.s) Communication avec l'émulateur de terminal sur le PC.
* [stm32f103.inc](../stm32f103.inc) Définitions matérielles spécifiques au MCU de la carte **blue pill**. 
* [tbi_macros.inc](../tbi_macros.inc) Définitions de macros et constantes.
* [cmd_index.inc](../cmd_index.inc) Constantes associés aux jetons des commandes et fonctions. 
* [ascii.inc](../ascii.inc) Constantes du jeu de caractères ASCII.
* [stm32f103c8t6.ld](../stm32f103c8t6.ld) Script du linker.
* [Makefile](../Makefile) Script pour la commande make.

[index principal](#index-princ)
