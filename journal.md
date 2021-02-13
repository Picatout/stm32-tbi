#### 2021-02-13

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
 