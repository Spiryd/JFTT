%{
#define YYSTYPE int
#include <iostream>
#include <string>
#define P 1234577

using namespace std;

extern int yylex();
extern int yyparse();
int yyerror(string s);

int gp_sub(int a, int b);
int gp_sub_exp(int a, int b);

int extended_euclid(int a, int b, int *x, int *y);
int gp_inv(int a);
int gp_div(long int a, int b);

int gp_inv_exp(int a);
int gp_div_exp(long int a, int b);

int gp_pow(long int a, int pow);

string error_msg = "";
string rpn = "";
%}

%token NUM
%token ERR
%token EXTD
%left '+' '-'
%left '*' '/'
%precedence NEG
%nonassoc '^'

%%

input:
    %empty
    | input line
;
line: 
    expr '\n' { 
            cout << rpn << endl;
            cout << "Wynik: " << $1 << endl; 
            rpn = "";
        }
    | error '\n' { 
            if (error_msg == "") 
                error_msg = "zła składnia";
            cout << "Błąd: " << error_msg << endl; 
            rpn = ""; 
            error_msg = "";
        }
;
expr: 
    number                          { rpn += to_string($1) + " "; $$ = $1; }
    | '(' expr ')'                  { $$ = $2; }
    | '-' '(' expr ')' %prec NEG    { rpn += "~ "; $$ = ((-$3 % P) + P) % P; }
    | expr '+' expr                 { rpn += "+ "; $$ = ($1 + $3) % P; }
    | expr '-' expr                 { rpn += "- "; $$ = gp_sub($1, $3); }
    | expr '*' expr                 { rpn += "* "; $$ = ($1 * $3) % P; }
    | expr '^' exponent             { rpn += "^ "; $$ = gp_pow($1, ($3 + P) % P); }
    | expr '/' expr { 
            rpn += "/ "; 
            if ($3 == 0) { 
                error_msg = "dzielenie przez 0"; 
                YYERROR; 
            } 
            else
                $$ = gp_div($1, $3); 
        }
;
exponent:
    exp_number                              { rpn += to_string($1) + " "; $$ = $1; }
    | '(' exponent ')'                      { $$ = $2; }
    | '-' '(' exponent ')' %prec NEG        { rpn += "~ "; $$ = ((-$3 % (P - 1)) + (P - 1)) % (P - 1); }
    | exponent '+' exponent                 { rpn += "+ "; $$ = ($1 + $3) % (P - 1); }
    | exponent '-' exponent                 { rpn += "- "; $$ = gp_sub_exp($1, $3); }
    | exponent '*' exponent                 { rpn += "* "; $$ = ($1 * $3) % (P - 1); }
    | exponent '/' exponent { 
            rpn += "/ "; 
            if ($3 == 0) { 
                error_msg = "dzielenie wykładnika przez 0"; 
                YYERROR; 
            } 
            else {
                int x,y;
                extended_euclid($1, $3, &x, &y);
                if(y != 1) {
                    error_msg = "element nie jest odwracalny.";
                    YYERROR;
                } else 
                    $$ = gp_div_exp($1, $3); 
            }
        }
;
number:
    NUM                     { $$ = $1; }
    | '-' number %prec NEG  { $$ = ((-$2 % P) + P) % P; }
;
exp_number:
    NUM                         { $$ = $1; }
    | '-' exp_number %prec NEG  { $$ = ((-$2 % (P - 1)) + (P - 1)) % (P - 1); }

%%

int gp_sub(int a, int b) {
    int val = (a-b) % P;
    if (val < 0)
        val += P;
    return val;
}

int gp_sub_exp(int a, int b) {
    int val = (a-b) % (P - 1);
    if (val < 0)
        val += (P - 1);
    return val;
}

int extended_euclid(int a, int b, int *x, int *y) {
    if (a == 0) {
        *x = 0;
        *y = 1;
        return b;
    }
    int x1, y1;
    int d = extended_euclid(b%a, a, &x1, &y1);
    *x = y1 - (b/a)*x1;
    *y = x1;
    return d;
}

int gp_inv(int a) {
    int x, y;
    extended_euclid(a, P, &x, &y);
    return (x%P + P) % P;
}

int gp_div(long int a, int b) {
    long int inv = gp_inv(b);
    return (int)((a*inv) % P);
}

int gp_inv_exp(int a) {
    int x, y;
    extended_euclid(a, P - 1, &x, &y);
    return (x%(P - 1) + (P - 1)) % (P - 1);
}

int gp_div_exp(long int a, int b) {
    long int inv = gp_inv_exp(b);
    return (int)((a*inv) % (P - 1));
}

int gp_pow(long int a, int pow) {
    if (pow == 0)
        return 1;
    long int b = gp_pow(a, pow/2);
    if (pow % 2 == 0)
        return (int)((b*b) % P);
    else
        return (int)((a * b*b) % P);
}

int yyerror(string s) {	
    return 0;
}

int main()
{
    yyparse();
    return 0;
}
