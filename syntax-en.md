<!-- 
Copyright Jacques Deschênes, 2021
Ce document fait parti du projet stm32-tbi
https://github.com/picatout/stm32-tbi
-->
[-&GT;version française](syntaxe-fr.md)
# language syntax description.

**Typography**
* Element between **()** are optionals.
* **'|'** character separate alternatives.
* Character between single quote are literal.
* A label or constant symbol must have 2 characters minimun and 6 at most.

**notes**
* **func** is a sub-routine that return a value. 
* **sub** is a sub-routine that doesn't return a value.
* This version of tiny BASIC authorize label as GOTO|GOSUB target.
* This version of tiny BASIC authorize more than one statement per line. They may be separated by **':'** but this is optional except for ambiguous situations. 
* See [reference manual](docs/refman.md) for a complete list of commands, functions and systm constants.

```
line ::= number (label) statement  ((:) statement) CR | statement  ((:) statement) CR
 
    statement ::= PRINT expr-list
                  IF expression relop expression (THEN) statement ((:) statement) CR 
                  GOTO expression|label
                  INPUT var-list
                  (LET) var = expression
                  GOSUB expression|label
                  FOR var=expr to expr (STEP exp) (CR) statement ((:)statement) (CR) NEXT var (CR) 
                  DO (CR) statement ((:) statement) UNTIL relation 
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
