D                       [0-9]
L                       [a-zA-Z_]
H                       [a-fA-F0-9]
E                       [Ee][+-]?{D}+
FS                      (f|F|l|L)
IS                      (u|U|l|L)*

%s                      COMMENT


%{
#include <stdio.h>
#include "y.tab.h"
%}


%%
"/*"                    { BEGIN COMMENT; }
<COMMENT>(.|\n)         ;
<COMMENT>"*/"           { BEGIN 0; }


<INITIAL>{
"break"                 { return BREAK; }
"case"                  { return CASE; }
"default"               { return DEFAULT; }
"else"                  { return ELSE; }
"extern"                { return EXTERN; }
"for"                   { return FOR; }
"if"                    { return IF; }
"int"                   { return INT; }
"return"                { return RETURN; }
"switch"                { return SWITCH; }
"then"                  { return THEN; }
"void"                  { return VOID; }
"while"                 { return WHILE; }

{L}({L}|{D})*           { return IDENTIFICATEUR; /* printf("%s\n", yytext); */ }

{D}+                    { return CONSTANTE; }

"<="                    { return LEQ; }
">="                    { return GEQ; }
"=="                    { return EQ; }
"!="                    { return NEQ; }
"<"                     { return LT; }
">"                     { return GT; }
"!"                     { return NOT; }
"&&"                    { return LAND;  /* Logical AND */ }
"||"                    { return LOR;   /* Logical OR */  }

"+"                     { return PLUS; }
"-"                     { return MOINS; }
"*"                     { return MUL; }
"/"                     { return DIV; }
"&"                     { return BAND;  /* Bitwise AND */ }
"|"                     { return BOR;   /* Bitwise OR */  }
">>"                    { return RSHIFT; }
"<<"                    { return LSHIFT; }

[ \t\v\n\f]             ;
.                       { return yytext[0]; }
}

%%
