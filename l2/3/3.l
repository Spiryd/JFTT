%{
    #include <stdio.h>
    int yywrap();
    int yylex();

    int DOC;
%}

%x INCLUDE
%x STRING
%x MULTI_LINE_COMMENT
%x DOCUMENTATION

ALL .|\n|\\\n

%%
    /*short documentation comments*/
((\/(\\\n)*\/(\\\n)*\/)|(\/(\\\n)*\/(\\\n)*!)).*(\\\n.*)*	{if(DOC) ECHO;};


    /*short comment*/
\/(\\\n)*\/.*(\\\n.*)* ;


    /*documentation mode*/
    (^[[:blank:]]*)?(\/\*\*)|(\/\*!)            {if(DOC) ECHO; BEGIN(DOCUMENTATION);};
    <DOCUMENTATION>{
        {ALL}   {if(DOC) ECHO;}
        "*/"    {if(DOC) ECHO; BEGIN(0);}
    }


    /*multi line comments*/
\/\*            {BEGIN(MULTI_LINE_COMMENT);};
<MULTI_LINE_COMMENT>{
    "*/"        BEGIN(0);
    {ALL}       ;
}


    /*string*/
\" ECHO; BEGIN(STRING);
<STRING>{
    /* (\\\") -> \n */
    \\\"        ECHO;
    \"          ECHO; BEGIN(0);
}

    
    /*includes*/
"#include"[ \t\n\\\n]+< ECHO; BEGIN(INCLUDE);
<INCLUDE>{
    ">"         ECHO; BEGIN(0);
}


%%

int yywrap(){};

int main(int argc, char** argv)
{
    if(argc > 1){
        DOC = 1;
    }
    return yylex();
}