%{
#include <stdio.h>

int words = 0;
int lines = 1;
%}
    /* But I've got a blank space, baby And I'll write your name */
WHITESPACE [[:blank:]]
    /* states */
%s NEWLINE
%x WORD
%x BLANKS
%%
    /* discard all whitespaces and new lines at the start file/new line */
{WHITESPACE}|\n
<NEWLINE>. {
    fprintf(yyout, "\n");
    /* call the second best rule:
    ABOVE -> you have encountered whitespaces;
    BELOW -> you have encountered a WORD */
    BEGIN(0);
}
. {
        /* if you read something that isn't a white space */
    ECHO;
    words++;
    lines++;
    BEGIN(WORD);
}

<WORD>{
        /* encountered a blank after word*/
    [[:blank:]] BEGIN(BLANKS);
        /* encountered a newline after word*/
    \n BEGIN(NEWLINE);
}

<BLANKS>{
        /* delete all the whitespaces */
    {WHITESPACE}
    
    \n BEGIN(NEWLINE);
        /*encounter something else than whitespace? print space than print the byte*/
    . {
        fprintf(yyout, " ");;
        ECHO;
        BEGIN(WORD);
        words++;
    }
}
%%

int yywrap() {
    return 1; 
}
int main() {
    yyout = fopen("result.txt", "w");
    yylex();
    printf("words: %d lines: %d", words, lines);
    return 0;
}