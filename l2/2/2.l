%{
    #include <stdio.h>
%}

%x TAG
%x COM
%x STR

%%
    /*tags*/
"<"                {ECHO; BEGIN(TAG);}
<TAG>{
    \".*\"|.|\n	    ECHO;
    .> {ECHO; BEGIN(0);}
}

    /*comment*/
"<!--"          BEGIN(COM);
<COM>{
.|\n            ;
"-->"           BEGIN(0);
}
    /*string*/

<STR>{
    \"          ECHO; BEGIN(0);
}

    /*invalid comment - leave it!*/
"<!--".*"--".*"-->" {ECHO;}

%%

int yywrap() {
    return 1; 
}
int main() {
    yyout = fopen("result.xml", "w");
    yylex();
    return 0;
}