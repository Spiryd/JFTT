%{
#include <stdio.h>

int words = 0;
int lines = 1;
%}

%%

^[[:blank:]]*\n*   ;
[[:blank:]]+$\n*   ;
[[:blank:]]+       { fprintf(yyout, " "); }
[a-zA-Z]+          { words++; ECHO; }
\n                 { lines++; ECHO; }

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