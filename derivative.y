%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex();

void yyerror(const char * s){
    fprintf(stderr,"%s\n",s);
};

%}

%union{
    struct{
        char * func;
        char * der;
        float number;
    }a;
}

%token <a> ADD SUB MUL DIV POW
%token <a> OPBR CLBR
%token <a> NUMBER VAR
%token <a> SIN COS EXP LN
%token <a> TAN SQRT ASIN ACOS ATAN
%token EOL

%left ADD SUB
%left MUL DIV
%left POW
%nonassoc OPBR CLBR

%type <a> expression number

%%

input:/*nothing*/
|input expression EOL {printf("%s\n",$2.der);free($2.der);free($2.func);}
;

expression:

VAR {$$.func = $1.func; $$.der=strdup("1");}

|expression ADD expression {
    int expr_memory = sizeof($1.func)+sizeof($3.func);
    $$.func = malloc(expr_memory);$$.der=malloc(expr_memory);
    sprintf($$.func,"(%s+%s)",$1.func,$3.func);
    sprintf($$.der,"(%s+%s)",$1.der,$3.der);}

|expression SUB expression {
    int expr_memory = sizeof($1.func)+sizeof($3.func);
    $$.func = malloc(expr_memory);$$.der=malloc(expr_memory);
    sprintf($$.func,"(%s-%s)",$1.func,$3.func);
    sprintf($$.der,"(%s-%s)",$1.der,$3.der);}

|expression MUL expression {
    int expr_memory = sizeof($1.func)+sizeof($3.func);
    $$.func = malloc(expr_memory);$$.der=malloc(expr_memory);
    sprintf($$.func,"(%s*%s)",$1.func,$3.func);
    sprintf($$.der,"((%s*%s)+(%s*%s))",$1.der,$3.func,$1.func,$3.der);}

|expression DIV expression {
    int expr_memory = sizeof($1.func)+sizeof($3.func);
    $$.func = malloc(expr_memory);$$.der=malloc(expr_memory);
    sprintf($$.func,"(%s/%s)",$1.func,$3.func);
    sprintf($$.der,"((%s*%s)-(%s*%s))/((%s)^2)",$1.der,$3.func,$1.func,$3.der,$3.func);}

|OPBR expression CLBR {$$.func = $2.func; $$.der = $2.der;}


|expression POW OPBR number CLBR {
    int expr_memory = sizeof($1.func)+sizeof($4.func);
    $$.func = malloc(expr_memory);
    sprintf($$.func,"%s^(%s)",$1.func,$4.func);
    $$.der = malloc(expr_memory);
    char* temp = malloc(sizeof(float));
    double value = $4.number;
    value--;
    sprintf(temp,"%.1f",value);
    sprintf($$.der,"(%s*%s^(%s))*(%s)",$4.func,$1.func,temp,$1.der);}

|SIN OPBR expression CLBR {
    int expr_memory = sizeof($3.func);
    $$.func = malloc(expr_memory);
    $$.der = malloc(expr_memory);
    sprintf($$.func,"sin(%s)",$3.func);
    sprintf($$.der,"cos(%s)*%s",$3.func,$3.der);}
|COS OPBR expression CLBR {
    int expr_memory = sizeof($3.func);
    $$.func = malloc(expr_memory);
    $$.der = malloc(expr_memory);
    sprintf($$.func,"cos(%s)",$3.func);
    sprintf($$.der,"-sin(%s)*%s",$3.func,$3.der);}   
|EXP OPBR expression CLBR {
    int expr_memory = sizeof($3.func);
    $$.func = malloc(expr_memory);
    $$.der = malloc(expr_memory);
    sprintf($$.func,"exp(%s)",$3.func);
    sprintf($$.der,"exp(%s)*%s",$3.func,$3.der);}                        
|LN OPBR expression CLBR {
    int expr_memory = sizeof($3.func);
    $$.func = malloc(expr_memory);
    $$.der = malloc(expr_memory);
    sprintf($$.func,"ln(%s)",$3.func);
    sprintf($$.der,"(1/%s)*%s",$3.func,$3.der);}
|TAN OPBR expression CLBR {
    int expr_memory = sizeof($3.func);
    $$.func = malloc(expr_memory);
    $$.der = malloc(expr_memory);
    sprintf($$.func,"tan(%s)",$3.func);
    sprintf($$.der,"(1/((cos(%s))^2))*%s",$3.func,$3.der);}
|ASIN OPBR expression CLBR {
    int expr_memory = sizeof($3.func);
    $$.func = malloc(expr_memory);
    $$.der = malloc(expr_memory);
    sprintf($$.func,"asin(%s)",$3.func);
    sprintf($$.der,"(1/sqrt(1-(%s)^2))*%s",$3.func,$3.der);}           
|ACOS OPBR expression CLBR {
    int expr_memory = sizeof($3.func);
    $$.func = malloc(expr_memory);
    $$.der = malloc(expr_memory);
    sprintf($$.func,"acos(%s)",$3.func);
    sprintf($$.der,"-(1/sqrt(1-(%s)^2))*%s",$3.func,$3.der);}
|ATAN OPBR expression CLBR {
    int expr_memory = sizeof($3.func);
    $$.func = malloc(expr_memory);
    $$.der = malloc(expr_memory);
    sprintf($$.func,"atan(%s)",$3.func);
    sprintf($$.der,"(1/(1+(%s)^2))*%s",$3.func,$3.der);}
|SQRT OPBR expression CLBR {
    int expr_memory = sizeof($3.func);
    $$.func = malloc(expr_memory);
    $$.der = malloc(expr_memory);
    sprintf($$.func,"sqrt(%s)",$3.func);
    sprintf($$.der,"(1/(2*sqrt(%s)))*%s",$3.func,$3.der);}

|number MUL expression {
    int expr_memory = sizeof($1.func)+sizeof($3.func);
    $$.func = malloc(expr_memory);
    $$.der = malloc(expr_memory);
    sprintf($$.func,"%s*%s",$1.func,$3.func);
    sprintf($$.der,"%s*%s",$1.func,$3.der);}

|number {$$.func = $1.func; $$.der = $1.der;}
;

number: NUMBER {$$.func = malloc(sizeof(float)); $$.der = malloc(sizeof(float)); sprintf($$.func,"%.1f",$1.number); sprintf($$.der,"%.1f",0);};

%%

int main(){
    yyparse();
    return 0;
}
