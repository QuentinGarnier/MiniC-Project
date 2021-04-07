%{
	#include <stdio.h>
	#include <stdlib.h>
	#include "nodes.h"

	Node *root;
%}


%token <str> IDENTIFICATEUR VOID INT FOR WHILE IF ELSE SWITCH CASE DEFAULT
%token <integer> CONSTANTE
%token <str> BREAK RETURN PLUS MOINS MUL DIV LSHIFT RSHIFT BAND BOR LAND LOR LT GT 
%token <str> GEQ LEQ EQ NEQ NOT EXTERN
%left PLUS MOINS
%left MUL DIV
%left LSHIFT RSHIFT
%left BOR BAND
%left LAND LOR
%nonassoc THEN
%nonassoc ELSE
%left OP
%left REL
%start programme

%union{
	int integer;
	char *str;
	Node *node;
}
%type <str> binary_op binary_rel binary_comp type
%type <node> liste_declarations liste_fonctions declaration fonction liste_declarateurs declarateur liste_parms liste_instructions liste_parms_content parm instruction iteration selection saut affectation bloc appel condition expression variable variableTab liste_expressions liste_expressions_content


%%
programme	:	
		liste_declarations liste_fonctions																{root = createBinNode("root", $2, $1);}
;
liste_declarations	:	
		liste_declarations declaration 																	{$$ = NULL; /* === TODO! === */}
	|																									{$$ = NULL; /* === TODO! === */}
;
liste_fonctions	:	
		liste_fonctions fonction 																		{$$ = setBrother($2, $1);}
|               fonction 																				{$$ = $1;}
;
declaration	:	
		type liste_declarateurs ';' 																	{$$ = NULL; /* === TODO! === */}
;
liste_declarateurs	:	
		liste_declarateurs ',' declarateur 																{$$ = NULL; /* === TODO! === */}
	|	declarateur 																					{$$ = NULL; /* === TODO! === */}
;
declarateur	:	
		IDENTIFICATEUR 																					{$$ = NULL; /* === TODO! === */}
	|	declarateur '[' CONSTANTE ']' 																	{$$ = NULL; /* === TODO! === */}
;
fonction	:	
		type IDENTIFICATEUR '(' liste_parms ')' '{' liste_declarations liste_instructions '}' 			{$$ = createNode(buildStr($2, buildStr(", ", $1)), $8, NULL);}
	|	EXTERN type IDENTIFICATEUR '(' liste_parms ')' ';' 												{$$ = createNode("", NULL, NULL);}
;
type	:	
		VOID 																							{$$ = "void";}
	|	INT 																							{$$ = "int";}
;
liste_parms	:	
		liste_parms_content 																			{$$ = NULL; /* === TODO! === */}
	|																									{$$ = NULL; /* === TODO! === */}
;
liste_parms_content	:
		liste_parms_content ',' parm 																	{$$ = NULL; /* === TODO! === */}
	|	parm 																							{$$ = NULL; /* === TODO! === */}
;
parm	:	
		INT IDENTIFICATEUR 																				{$$ = NULL; /* === TODO! === */}
;
liste_instructions :	
		liste_instructions instruction 																	{$$ = setBrother($2, $1);}
	| 																									{$$ = NULL;}
;
instruction	:	
		iteration 																						{$$ = $1;}
	|	selection 																						{$$ = $1;}
	|	saut 																							{$$ = $1;}
	|	affectation ';' 																				{$$ = $1;}
	|	bloc 																							{$$ = $1;}
	|	appel 																							{$$ = $1;}
;
iteration	:	
		FOR '(' affectation ';' condition ';' affectation ')' instruction 								{$$ = createBinNode("FOR", $3, setBrother($5, setBrother($7, $9)));}
	|	WHILE '(' condition ')' instruction 															{$$ = createBinNode("WHILE", $3, $5);}
;
selection	:	
		IF '(' condition ')' instruction %prec THEN 													{$$ = createBinNode("IF", $3, $5);}
	|	IF '(' condition ')' instruction ELSE instruction 												{$$ = createBinNode("IF", $3, setBrother($5, $7));}
	|	SWITCH '(' expression ')' instruction 															{$$ = createBinNode("SWITCH", $3, $5);}
	|	CASE CONSTANTE ':' instruction 																	{$$ = $4;}
	|	DEFAULT ':' instruction 																		{$$ = $3;}
;
saut	:	
		BREAK ';' 																						{$$ = createLeaf("BREAK");}
	|	RETURN ';' 																						{$$ = createLeaf("RETURN");}
	|	RETURN expression ';' 																			{$$ = createNode("RETURN", $2, NULL);}
;
affectation	:	
		variable '=' expression 																		{$$ = createBinNode(":=", $1, $3);}
;
bloc	:	
		'{' liste_declarations liste_instructions '}' 													{$$ = createNode("BLOC", $3, NULL);}
;
appel	:	
		IDENTIFICATEUR '(' liste_expressions ')' ';'  													{$$ = createNode($1, $3, NULL);}
;
variable	:	
		IDENTIFICATEUR 																					{$$ = createLeaf($1);}
	|	variableTab '[' expression ']' 																	{$$ = addNewSon($1, $3);}
;
variableTab	:	
		IDENTIFICATEUR 																					{$$ = createNode("TAB", createLeaf($1), NULL);}
	|	variableTab '[' expression ']' 																	{$$ = addNewSon($1, $3);}
;
expression	:	
		'(' expression ')' 																				{$$ = $2;}
	|	expression binary_op expression %prec OP 														{$$ = createBinNode($2, $1, $3);}
	|	MOINS expression 																				{$$ = createNode("-", $2, NULL);}
	|	CONSTANTE 																						{char s[10]; sprintf(s, "%d", $1); $$ = createLeaf(s);}
	|	variable 																						{$$ = $1;}
	|	IDENTIFICATEUR '(' liste_expressions ')' 														{$$ = createNode($1, $3, NULL);}
;
liste_expressions	:	
		liste_expressions_content 																		{$$ = $1;}
	| 																									{$$ = NULL;}
;
liste_expressions_content	:
		liste_expressions_content ',' expression 														{$$ = setBrother($3, $1);}
	|	expression 																						{$$ = $1;}
;
condition	:	
		NOT '(' condition ')' 																			{$$ = createNode("!", $3, NULL);}
	|	condition binary_rel condition %prec REL 														{$$ = createBinNode($2, $1, $3);}
	|	'(' condition ')' 																				{$$ = $2;}
	|	expression binary_comp expression 																{$$ = createBinNode($2, $1, $3);}
;
binary_op	:	
		PLUS 																							{$$ = "+";}
	|       MOINS 																						{$$ = "-";}
	|	MUL 																							{$$ = "*";}
	|	DIV 																							{$$ = "/";}
	|       LSHIFT 																						{$$ = "<<";}
	|       RSHIFT 																						{$$ = ">>";}
	|	BAND 																							{$$ = "&";}
	|	BOR 																							{$$ = "|";}
;
binary_rel	:	
		LAND 																							{$$ = "&&";}
	|	LOR 																							{$$ = "||";}
;
binary_comp	:	
		LT 																								{$$ = "<";}
	|	GT 																								{$$ = ">";}
	|	GEQ 																							{$$ = ">=";}
	|	LEQ 																							{$$ = "<=";}
	|	EQ 																								{$$ = "==";}
	|	NEQ 																							{$$ = "!=";}
;
%%



int yyerror(char *s) {
	fprintf(stderr, "%s\n", s);
	exit(1);
}


int main() {
	yyparse();
	buildTree(root);
	return 0;
}
