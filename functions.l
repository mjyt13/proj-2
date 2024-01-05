%{

#include "derivative.tab.h"
    
%}

%%

[0-9]+ {yylval.a.num = atof(yytext); return NUMBER;}

x {yylval.a.der = strdup(yytext); return VAR;}

sin {yylval.a.func = strdup(yytext); return SIN;}
cos {yylval.a.func = strdup(yytext); return COS;}
exp {yylval.a.func = strdup(yytext); return EXP;}
ln {yylval.a.func = strdup(yytext); return LN;}

tan {yylval.a.func = strdup(yytext); return TAN;}
sqrt {yylval.a.func = strdup(yytext); return SQRT;}
asin {yylval.a.func = strdup(yytext); return ASIN;}
acos {yylval.a.func = strdup(yytext); return ACOS;}

"+" {yylval.a.func = strdup(yytext); return ADD;}
"-" {yylval.a.func = strdup(yytext); return SUB;}
"*" {yylval.a.func = strdup(yytext); return MUL;}
"/" {yylval.a.func = strdup(yytext); return DIV;}
"^" {yylval.a.func = strdup(yytext); return POW;}

"(" {yylval.a.func = strdup(yytext); return LPR;}
")" {yylval.a.func = strdup(yytext); return RPR;}

"\n" return NEXTLINE;

[ \t] ;

%%

int yywrap(){
    return 1;
}