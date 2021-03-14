<!-- 
Copyright Jacques Deschênes, 2021
Ce document fait parti du projet stm32-tbi
https://github.com/picatout/stm32-tbi
-->
[-&GT;English version](syntax-en.md)
# syntaxe du langage

**Typographie**
* Ce qui est entre parenthèse est optionnel
* Le caractère **'|'** signfie une alternative
* Un caractère entre apostrophes indique un caractère litéral.
* A label a un minimum de 2 caractères et un maximum de 6.

**notes**
* **func** est une procédure invoquée lors de l'exécution d'un programme et qui retourne une valeur. 
* **sub** est une procédure invoquée lors de l'exécution d'un programme qui ne retourne pas de valeur.
* Les **func** et **sub** sont des extensions du **tiny BASIC** original.
* Cette version de tiny BASIC permet plusieurs commandes sur la même ligne. Ces commandes peuvent-être séparées optionnellement par le caractère **':'**. 
* Pour la liste complète des **func** et **sub** consultez le [manuel de référence](docs/tib_refrence.md).

```
line ::= number (label) statement  ((:) statement) CR | statement  ((:) statement) CR
 
    statement ::= PRINT expr-list
                  IF expression relop expression THEN statement
                  GOTO expression|label
                  INPUT var-list
                  (LET) var = expression
                  GOSUB expression|label 
                  RETURN
                  NEW
                  LIST (number (- number))
                  RUN
                  TRACE 0|1|2|3
                  STOP
                  CONST label=expression (, label=expression)* 
                  SAVE string 
                  LOAD string 
                  DIR 
                  FORGET (string)
                  END
                  func func_args 
                  sub  arg_list  
 
    expr-list ::= (string|expression) (, (string|expression) )*
 
    var-list ::= var (, var)*
 
    expression ::= (+|-|ε) term ((+|-) term)*
 
    term ::= factor ((*|/) factor)*
 
    factor ::= var | number | (expression)
 
    var ::= 'A' | 'B' | 'C' ... | 'Y' | 'Z'
 
    number ::= digit digit* | '$'hex_digit hex_digit* | '&'bin_digit bin_digit*
 
    digit ::= '0' ... '9'

    hex_digit ::= digit 'A'..'F'  

    bin_digit ::= '0'|'1' 
 
    relop ::= < (>|=|ε) | > (<|=|ε) | =

    string ::= " ( |!|#|$ ... -|.|/|digit|: ... @|A|B|C ... |X|Y|Z)* "

    label ::= letter letter (letter)* 

    func ::= name '(' arg_list ')' 

    sub ::= name arg_list 

    arg_list ::= expression (,expression)* 

```
