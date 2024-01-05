%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex();

void yyerror(const char * s){
    fprintf(stderr,"%s\n",s);
};

//"[" {yylval.a.func = strdup(yytext); return SBR;}
//"]" {yylval.a.func = strdup(yytext); return EBR;}
%}

%union{
    struct{
        char * func;
        char * der;
        double num;
    }a;
}

%token <a> ADD SUB MUL DIV POW
%token <a> LPR RPR
%token <a> NUMBER VAR
%token <a> SIN COS EXP LN
%token <a> TAN SQRT ASIN ACOS ATAN
%token NEXTLINE

%left ADD SUB
%left MUL DIV
%left POW
%nonassoc LPR RPR

%type <a> node num

%%

input:/*nothing*/
|input node NEXTLINE {printf("%s\n",$2.der);free($2.der);free($2.func);}
;

node:

VAR {$$.func = $1.der; $$.der=strdup("1");}

|node ADD node {$$.func = malloc(1024);$$.der=malloc(1024);
                sprintf($$.func,"(%s+%s)",$1.func,$3.func);
                sprintf($$.der,"(%s+%s)",$1.der,$3.der);}
|node SUB node {$$.func = malloc(1024);$$.der=malloc(1024);
                sprintf($$.func,"(%s-%s)",$1.func,$3.func);
                sprintf($$.der,"(%s-%s)",$1.der,$3.der);}
|node MUL node {$$.func = malloc(1024);$$.der=malloc(1024);
                sprintf($$.func,"(%s*%s)",$1.func,$3.func);
                sprintf($$.der,"(%s*%s)+(%s*%s)",$1.der,$3.func,$1.func,$3.der);}
|node DIV node {$$.func = malloc(1024);$$.der=malloc(1024);
                sprintf($$.func,"(%s+%s)",$1.func,$3.func);
                sprintf($$.der,"((%s*%s)-(%s*%s))/((%s)^2)",$1.der,$3.func,$1.func,$3.der,$3.func);}

|LPR node RPR {$$.func = $2.func; $$.der = $2.der;}


|node POW LPR num RPR {$$.func = malloc(1024);
                       sprintf($$.func,"%s^(%s)",$1.func,$4.func);
                       $$.der = malloc(1024);
                       char * temp = malloc(8);
                       double value = $4.num;
                       value--;
                       sprintf(temp,"%.2f",value);
                       sprintf($$.der,"(%s*%s^(%s))*(%s)",$4.func,$1.func,temp,$1.der);}
|SIN LPR node RPR {$$.func = malloc(1024);
                   $$.der = malloc(1024);
                   sprintf($$.func,"sin(%s)",$3.func);
                   sprintf($$.der,"cos(%s)*%s",$3.func,$3.der);}
|COS LPR node RPR {$$.func = malloc(1024);
                   $$.der = malloc(1024);
                   sprintf($$.func,"cos(%s)",$3.func);
                   sprintf($$.der,"-sin(%s)*%s",$3.func,$3.der);}   
|EXP LPR node RPR {$$.func = malloc(1024);
                   $$.der = malloc(1024);
                   sprintf($$.func,"exp(%s)",$3.func);
                   sprintf($$.der,"exp(%s)*%s",$3.func,$3.der);}     
|LN LPR node RPR {$$.func = malloc(1024);
                   $$.der = malloc(1024);
                   sprintf($$.func,"ln(%s)",$3.func);
                   sprintf($$.der,"(1/%s)*%s",$3.func,$3.der);}
|TAN LPR node RPR {$$.func = malloc(1024);
                   $$.der = malloc(1024);
                   sprintf($$.func,"tan(%s)",$3.func);
                   sprintf($$.der,"(1/((cos(%s))^2))*%s",$3.func,$3.der);}
|ASIN LPR node RPR {$$.func = malloc(1024);
                    $$.der = malloc(1024);
                    sprintf($$.func,"asin(%s)",$3.func);
                    sprintf($$.der,"(1/sqrt(1-(%s)^2))*%s",$3.func,$3.der);}
|ACOS LPR node RPR {$$.func = malloc(1024);
                    $$.der = malloc(1024);
                    sprintf($$.func,"acos(%s)",$3.func);
                    sprintf($$.der,"-(1/sqrt(1-(%s)^2))*%s",$3.func,$3.der);}
|ATAN LPR node RPR {$$.func = malloc(1024);
                    $$.der = malloc(1024);
                    sprintf($$.func,"atan(%s)",$3.func);
                    sprintf($$.der,"(1/(1+(%s)^2))*%s",$3.func,$3.der);}
|SQRT LPR node RPR {$$.func = malloc(1024);
                   $$.der = malloc(1024);
                   sprintf($$.func,"sqrt(%s)",$3.func);
                   sprintf($$.der,"(1/(2*sqrt(%s)))*%s",$3.func,$3.der);}

|num MUL node {$$.func = malloc(1024);
               $$.der = malloc(1024);
               sprintf($$.func,"%s*%s",$1.func,$3.func);
               sprintf($$.der,"%s*%s",$1.func,$3.der);}
|num {$$.func = $1.func; $$.der = $1.der;}
;

num: NUMBER {$$.func = malloc(16); sprintf($$.func,"%.2f",$1.num); sprintf($$.der,"%.2f",0.0);};

%%

int main(){
    yyparse();
    return 0;
}