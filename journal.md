<!-- 
Copyright Jacques Deschênes, 2021
Ce document fait parti du projet stm32-tbi
https://github.com/picatout/stm32-tbi
-->
#### 2021-03-18

* Ajout de la commande **RANDOMIZE** et de sa docmentation. 

* Ajout de la documentation pour les commandes **SPI_xxx** dans [tbi_reference.md](tbi_reference.md).

* Réécriture de [spi-test.bas](tb_progs/spi-test.bas).

* Complété et testé les commandes du groupes **SPI_xxx**. 

* Added constants for GPIO modes in [stm32f103.inc](stm32f103.inc). 

#### 2021-03-17

* Travail sur commande **SPI_xxxx**. 

* Travail sur [refman.md](docs/refman.md) 

* Modifié **LOAD*** et *create_gap* qui ne mettait pas à jour la variable **HERE**.

#### 2021-03-16

* Travail sur [refman.md](docs/refman.md).

* Le mode GPIO pour les servo-moteur est maintenant **OUTPUT_AFOD** et requiert donc un résistance pull up externe branché à 5 volts. Ce changement est pour tenir compte de la différence de voltage d'alimentation entre MCU de la blue pill (3.3volts) et celui d'un petit servo-moteur qui est de 5 volts. 

* Modifié [servo-test.bas](tb_progs/servo-test.bas) pour tenir compte des 2 nouveaux canneaux. 

* Ajout des canneaux servo-moteurs 5 et 6. Modifié code et tester code. Note les canaux 5 et 6 ne peuvent-être utilisé en même temps que *TONE** est activé.  

#### 2021-03-15

* Création de **pwm_dc**.

* Création de la sous-routine **pwm_config**, facteur commun a **SERVO_INIT** et **TONE_INIT**.

* Corrigé bogue dans commande **AWU**.

* Travail sur [refman.md](docs/refman.md)

#### 2021-03-14

* Complété le manuel de référence.

#### 2021-03-13

* Travail sur le manuel de référence.

* Modifié fonction **RANDOM** pour refuser les entiers négatif.

#### 2021-03-12

* Travail sur manuel de référence.

* Corrigé bogue dand **readln**.

* Modification à la commande **AWU** contrôle de limite. 

* Modification à **ADC** pour ajouter délais après activation et calibration.

#### 2021-03-11

* Modifié *prt_chars* pour que les caractères ASCII>126 s'affiche comme un **'_'**. 

* Écris et testé commande  **AUTORUN**.

#### 2021-03-09

* Travail sur manuel de référence. 

* Corrigé bogue dans **term**. 

#### 2021-03-07

* Corrigé bogue dans **gpio_config**. 

* Ajout de **SERVO_OFF** pour désactiver un canal servo-moteur.

* Supprimer constantes **SERVO_x** maintenant **SERVO_INIT** et **SERVO_POS** prennent pour argument entiers {1..4}.

* Supprimer les constantes **ON** et **OFF**  maintenant les arguments {1|0} doivent-être utilisés.

#### 2021-03-06

* Modifié **SERVO_INIT** la configuration du GPIO utilisé est maintenant faite par cette commande.

* Ajout des mots **TONE_INIT**, **TONE**.

* Modifié **uart_init** pour ajouter verouillage de broches PA9,PA10.

#### 2021-03-05

* Corrigé erreur erronées pour les constantes système **OUTPUT_AFPP** et **OUTPUT_AFOD**.

* Ajout du programme [servo-tes.bas](tb_progs/servo-test.bas).

* Testé **SERVO_INIT** et **SERVO_POS**.

* Ajout du programme [gpio-tes.bas](tb_progs/gpio-test.bas)

* Désactivation de signaux **JTDI,JTDO,JTRST** qui empêchaient l'utilisation des **GPIOA:15,GPIOB:3,GPIOB:4**.

#### 2021-03-04

* Ajout des constantes système **SERVO_A**, **SERVO_B**, **SERVO_C** et **SERVO_D**.

* Ajout des mots **SERVO_INIT** et **SERVO_POS**. 


#### 2021-03-03

* Corrigé bogue dans fonction **READ** qui n'acceptait pas les entiers négatifs. 

* Supprimer la commande **DATALN** et remplacé par un argument de la commande **RESTORE**.

* Ajout des mots **ADC**,**ANA** 

* Ajout des constantes système: **ON**,**OFF**

* Ajout du programme [pmode-test.bas](tb_progs/pmode-test.bas).

#### 2021-03-02

* Corrigé bogue dans **decompile_line**,  lable were not decompressed properly. 

* Now accept underscore in label and keywords. 

* Ajout des constantes système **OUTPUT_OD**,**OUTPUT_PP**,**OUTPUT_AFOD**,**OUTPUT_AFPP**,**INPUT_FLOT**,**INPUT_PD**,**INPUT_PU** et **INPUT_ANA**

#### 2021-03-01

* Modifié **INPUT** pour accepter les entiers négatifs. 

* Modifié **ASC()** pour accepter les **TK_CFUNC** comme argument. 

* Modifié le type de la fonction **KEY** dans le dictionnaire de **TK_INTGR**  à **TK_CHAR**.

* Corrigé bogue dans **next_token** qui ne retournait pas **TK_QSTR** dans r0.

* Retravaillé  **relation** et **expression** ainsi que code dépendant. 

#### 2021-02-28

* Modifié **décompile_line** pour insérer espace après variable et fonction.

* Optimisé **next_token**. 

* Trouver bogue dans **decompile_line** qui m'a obligé à créer **TK_SCONST** pour distinguer les constantes système de celles-créées par l'utilisateur. Ajustement de code nécessaire.

* Création branche **interpreter** pour travaillé la performance de l'interpréteur.  


* Corrigé bogue dans **readln**  la commande **CTRL_E** ne fonctionnait plus, c'était un bogue régressif. 

#### 2021-02-27

* Débogué **DUMP**,  la pile était débalancée lorsque l'entrée se faisait au point **dump01**. 

* Ajout de **XPOS** et **YPOS** pour connaître la position actuelle du curseur à l'écran du terminal. 

* Renommé **SIZE** en **FREE** 

* Déboguage **relation**, **decompile_line**, **comp_token**. 

#### 2021-02-26

* Modification identifiants tokens et tout le code impliqué. 
* Modififié **GOSUB** et **RETURN** maintenant sauvegarde adresse retour sur pile principale au lieu de la pile des arguments. 
```
list
10  INPUT A,B
20  PUSH A,B GOSUB PROD
30  PRINT  POP
40  GOTO 10 
50 PROD PUSH  POP* POP  RETURN 
READY
RUN
A=23
B=67
1541 
A=
READY
```

* Débogué **readln**  **CTRL_R** ne fonctionnait plus. 

* Renommé les mots suivants: **PEEK8** en **PEEKB**, **PEEK16** en **PEEKH**  et **PEEK32** en **PEEKW**

* Renommé les mots suivants: **POKE8** en **POKEB**, **POKE16** en **POKEH** et **POKE32** en **POKEW** 

* Renommé le mot **FLASH** en **STORE** 

* Modifié **pasre_label**  le compilateur convertie les symboles qui représente des constantes dans le dictionaire comme des **TK_INTGER** maintenant. Exécution plus rapide.

#### 2021-02-25

* Ajout de **GPIOA**,**GPIOB**,**GPIOC**

* Renommé **INP** à **IN** 

* Ajout de **CLS** et **LOCATE** 

* Racourci **REMARK** à **REM**.

* Renommé  **PICK** **GET** et **STORE** **PUT** 

* nettoyage du code. 

* correction bogue dans **decompile_line**. 

* changer limite no de ligne pour 65535.

#### 2021-02-24

* exemple utiliation du mot **CONST** 
```
LIST
10  CONST CA=2 *3 ,CB=2 *CA
20  ? CA,CB
30  END 
READY
RUN
6 12 
READY
```

* exemple utilisant les mots de gestion de la pile des arguments ainsi que les étiquettes. 
```
list
10  FOR I=1  TO 10  PUSH I GOSUB SQUARE ?  POP , NEXT I
20  END 
30 SQUARE PUT  GET (2 )* GET (2 ),2  RETURN 
READY
run
1 4 9 16 25 36 49 64 81 100 
READY
```

* **TK_LBL**  Les étiquettes cibles pour les **GOTO** et **GOSUB** débute par le caractère **!** suivit d'un maximum de 6 lettres.

* Ajout de **CONST** et d'étiquettes cibles.

#### 2021-02-23

* Ajout de la variable système **HERE** dans le but d'ajouter le mot BASIC **CONST**. Le système va permettre de créer des constantes symboliques dans l'espace libre après le code BASIC.

* Ajout des mots BASIC **PUSH**,**POP**,**PICK**,**STORE** et **DROP**. 

```
a=ticks:for i=0 to 100000: next i:? ticks-a
433 

```

* Ajout des mots **FLASH** et **ERASE** 

#### 2021-02-22

* Modifié **uart_rx_handler** pour pour que **CTRL_B** branche directement sur **warm_start** à la sortie de l'isr.

#### 2021-02-20

* Ajout des commandes **DIR** et **LOAD** 

#### 2021-02-19

* Ajout de **SAVE** et **FORGET** 

* Corrigé bogue dans **readln** 

* Ajouté constantes pour **IWDG** et **WWDG** dans [stm32f103.inc](stm32f103.inc)

#### 2021-02-18

* Débogué **GOTO**, la variable **COUNT** n'était pas initialisée. 

* Remplacé **SHOW** par **TRACE** 

* Ajout des commandes **TAB** et **SPC** 

#### 2021-02-17

* Ajout de **SHOW** 

* Modifié **tb_error** maintenant rt_error affiche ligne décompilée. 

#### 2021-02-16

* Débuté travail sur **PMODE** 

* Modifié **PRINT** pour accepté le **;** comme séprateur de liste. Ce caractère sera utilisé pour engendré une tabulation. 

* Modifié **INPUT** pour accepter une lettre comme réponse. La lettre est convertie en majuscule et la valeur ASCII affectée à la variable.

#### 2021-02-15

* Ajout de **WAIT** ,**DREAD**,**DWRITE**,**OUT**,**INP** 

#### 2021-02-14

* Ajout de **SLEEP** et **STOP**, supprimer **BYE**
 
* Ajouter **KEY**, **RSHIFT**, **LSHIFT**,**PEEK8**,**PEEK16**,**PEEK32**,**POKE8**,**POKE16**,**POKE32**  

* Modifié **INPUT** pour afficher soit la chaîne, soit le nom de la variable mais pas les 2.

* Modifier readln, home ne doit pas retourner à gauche de l'écran mais au début de la ligne de texte qui ne débute pas forcément à la colonne 1.

#### 2021-02-13

* Ajout de **INPUT** et **INVERT**

* Améliorer **DUMP** ainsi que l'affichage des erreurs run time.

* Ajout de **CTRL_B** dans le gestionnaire **uart_rx_handler** pour stopper un programme bloqué dans une boucle indéfinie.

* Déboguer **decompile_line** et **readln**. 

#### 2021-02-12

* créer routine decompile reste à déboguer.

* Corrigé bogue dans **readln** 

* Ajout de **THEN**, **BIT** , **DO** , **UNTIL**

* Ajout de **CHAR** 

* Améliorer commmande **DUMP** pour aligner la colonne des octetes à la position 11.

* Améliorer **PRINT** pour tenir compte de la largeur des colonnes **TAB_WIDTH**.

#### 2021-02-11

* Ajout des fonctions BASIC **AND**,**OR**,**XOR**,**ASC** 

* Déboguer commande **PRINT** qui ne fesait le CR lorsque le dernier argument éait une expression.

* Ajout des mots BASIC  **DATA**,**DATALN**,**READ** et **RESTORE**.

* Déboguer fonctions d'éditions, **inster_line**, **create_gap**, **delete_line** 

* Corrigé **compile** qui ne traitait pas les commentaires correctement.

* Corrigé commande **LIST** qui n'affichait pas les commentaires.


#### 2021-02-10

* Déboguer **next_token** et **interpreter**.

* Écris et testé mots BASIC **TICKS**,**TIMER**,**TIMEOUT**,**PAUSE**,**NOT**

* Écris et testé mots BASIC **FOR**,**TO**,**STEP** et **NEXT**. 

* Écris et testé mots BASIC **GOSUB** et **RETURN**.

* Ajout de la commande BASIC **NEW**.

* Travail sur commande BASIC **LIST**. 

#### 2021-02-09

* Corrigé bogue dans **is_digit** 

* Modifié **next_token** et **interpreter**

#### 2021-02-08

* Tester et déboguer **relation**

* Écrire code pour commande **IF**. 

* Ajouter **DUMP** au vocabulaire BASIC 

* Compléter et tester commande **LET**.


#### 2021-02-05

* Modification de *parse_keyword* pour accepter les variables.
* Déboguer *expression* et *search_dict*
**À faire** 
* déboguer @(expr)

#### 2021-02-04

* Corrigé bogue dans *is_special* qui retournait la mauvaise la valeur.
* Corrigé bogue dans *skip* ne préservait pas **r1** et avancait **r3** avant vérification.
* Écriture de la commande BASIC **PRINT** 
 