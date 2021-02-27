#### 2021-02-26

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
 