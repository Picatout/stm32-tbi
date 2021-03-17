<!-- 
Copyright Jacques Deschênes, 2021
Ce document fait parti du projet stm32-tbi
https://github.com/picatout/stm32-tbi
-->
[-&GT;français](syntaxe-fr.md)
# language syntax description.

**Typography**
* Element between **()** are optionals.
* **'|'** character separate alternatives.
* **'+'** character means this element must be present 1 or more time.
* __'*'__ character means this element can be present 0 or more time.
* Character between single quote are literal.
* A label or constant symbol must have 2 characters minimun and 6 at most.

**notes**
* **func** is a sub-routine that return a value. 
* **sub** is a sub-routine that doesn't return a value.
* This version of tiny BASIC authorize label as GOTO|GOSUB target.
* This version of tiny BASIC authorize more than one statement per line. They may be separated by **':'** but this is optional except for ambiguous situations. 
* See [reference manual](docs/refman.md) for a complete list of commands, functions and system constants.

```
line ::= number (label) statement+ CR | statement+  CR

statement ::= DO (CR) statement* (CR) UNTIL relation (CR) 
              IF expr relop expr (THEN) statement+ CR 
              FOR var=expr TO expr (STEP exp) (CR) statement* (CR) NEXT var (CR)
              GOSUB expression|label 
              GOTO expression|label  
              (LET) var = expression
              RETURN
              NEW
              LIST (number (- number))
              RUN
              TRACE 0|1|2|3
              END
              STOP
              CONST label=expression (, label=expression)* 
              SAVE string 
              LOAD string 
              DIR 
              FORGET (string)
              sub  arg_list  

expr-list ::= (string|expr) (, (string|expr) )*

expr ::= (+|-|ε) term ((+|-) term)*

term ::= factor ((*|/) factor)*

factor ::= var | number | (expression) | func

var ::= 'A' | 'B' | 'C' ... | 'Y' | 'Z'

number ::= digit digit* | '$'hex_digit hex_digit* | '&'bin_digit bin_digit*

digit ::= '0' ... '9'

hex_digit ::= digit 'A'..'F'  

bin_digit ::= '0'|'1' 

relop ::= < (>|=|ε) | > (<|=|ε) | =

string ::= " ( |!|#|$ ... -|.|/|digit|: ... @|A|B|C ... |X|Y|Z)* "

label ::= letter|'_' (letter|'_')+ 

func ::= name '(' arg_list ')' 

sub ::= name arg_list 

arg_list ::= expression (,expression)* 

```
