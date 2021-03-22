D                       [0-9]
L                       [a-zA-Z_]
H                       [a-fA-F0-9]
E                       [Ee][+-]?{D}+
FS                      (f|F|l|L)
IS                      (u|U|l|L)*

%{
#include <stdio.h>
#include "y.tab.h"


/* Supprimer les lignes dont vous n'avez pas besoin. */

%}

%%
\/\*([^*]|[\n]|(\*+([^*/]|[\n])))*\*+\/    { printf("Comment...\n"); }

"break"                 { printf("break\n"); /* Plus tard : return(BREAK) avec BREAK un token de miniC.y */ }
"case"                  { printf("case\n"); }
"default"               { printf("default\n"); }
"else"                  { printf("else\n"); }
"extern"                { printf("extern\n"); }
"for"                   { printf("for\n"); }
"if"                    { printf("if\n"); }
"int"                   { printf("int\n"); }
"return"                { printf("return\n"); }
"switch"                { printf("switch\n"); }
"void"                  { printf("void\n"); }
"while"                 { printf("while\n"); }

{L}({L}|{D})*           { printf("IDENTIFIER\n"); }

0[xX]{H}+{IS}?          { printf("test1?\n"); }
0{D}+{IS}?              { printf("test2?\n"); }
{D}+{IS}?               { printf("NUMBER?\n"); }
L?'(\\.|[^\\'])+'       { printf("test4?\n"); }

{D}+{E}{FS}?            { printf("test5?\n"); }

L?\"(\\.|[^\\"])*\"     { printf("test8?\n"); }

"..."                   { printf("test??\n"); }
">>="                   { /* A completer */ }
"<<="                   { /* A completer */ }
"+="                    { /* A completer */ }
"-="                    { /* A completer */ }
"*="                    { /* A completer */ }
"/="                    { /* A completer */ }
"%="                    { /* A completer */ }
"&="                    { /* A completer */ }
"^="                    { /* A completer */ }
"|="                    { /* A completer */ }
">>"                    { printf("Bit op\n"); }
"<<"                    { printf("Bit op\n"); }
"++"                    { /* A completer */ }
"--"                    { /* A completer */ }
"->"                    { /* A completer */ }

"&&"                    { /* A completer */ }
"||"                    { /* A completer */ }
"<="                    { printf("Inferior, or equal\n"); }
">="                    { printf("Superior, or equal\n"); }
"=="                    { /* A completer */ }
"!="                    { /* A completer */ }

[ \t\v\n\f]             { /* A completer */ }
.                       { return yytext[0]; }
%%

int main()
{
	while(1) yylex();
	printf("END OF FILE!\n"); /* CTRL - D pour quitter quand on écrit */
}