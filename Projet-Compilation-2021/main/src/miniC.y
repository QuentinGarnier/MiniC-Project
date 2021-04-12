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
		type IDENTIFICATEUR '(' liste_parms ')' '{' liste_declarations liste_instructions '}' 			{$$ = createTypedNode(buildStr($2, buildStr(", ", $1)), createNode("BLOC", $8, NULL), NULL, FUN_T);}
	|	EXTERN type IDENTIFICATEUR '(' liste_parms ')' ';' 												{$$ = createTypedLeaf(buildStr($3, buildStr(", ", $2)), FUN_T);}
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
		FOR '(' affectation ';' condition ';' affectation ')' instruction 								{$$ = createBinNode("FOR", $9, setBrother($7, setBrother($5, $3)));}
	|	WHILE '(' condition ')' instruction 															{$$ = createBinNode("WHILE", $5, $3);}
;
selection	:	
		IF '(' condition ')' instruction %prec THEN 													{$$ = createTypedBinNode("IF", $5, $3, IF_T);}
	|	IF '(' condition ')' instruction ELSE instruction 												{$$ = createTypedBinNode("IF", $7, setBrother($5, $3), IF_T);}
	|	SWITCH '(' expression ')' instruction 															{$$ = specialSwitchNode($3, $5);}
	|	CASE CONSTANTE ':' instruction 																	{char s[10]; sprintf(s, "%d", $2); $$ = createBinNode("CASE", createLeaf(s), $4);}
	|	DEFAULT ':' instruction 																		{$$ = createNode("DEFAULT", $3, NULL);}
;
saut	:	
		BREAK ';' 																						{$$ = createTypedLeaf("BREAK", BREAK_T);}
	|	RETURN ';' 																						{$$ = createTypedLeaf("RETURN", RETURN_T);}
	|	RETURN expression ';' 																			{$$ = createTypedNode("RETURN", $2, NULL, RETURN_T);}
;
affectation	:	
		variable '=' expression 																		{$$ = createBinNode(":=", $3, $1);}
;
bloc	:	
		'{' liste_declarations liste_instructions '}' 													{$$ = createNode("BLOC", $3, NULL);}
;
appel	:	
		IDENTIFICATEUR '(' liste_expressions ')' ';'  													{$$ = createTypedNode($1, $3, NULL, CALL_FUN_T);}
;
variable	:	
		IDENTIFICATEUR 																					{$$ = createLeaf($1);}
	|	variableTab '[' expression ']' 																	{$$ = createNode("TAB", setBrother($3, $1), NULL);}
;
variableTab	:	
		IDENTIFICATEUR 																					{$$ = createLeaf($1);}
	|	variableTab '[' expression ']' 																	{$$ = setBrother($3,  $1);}
;
expression	:	
		'(' expression ')' 																				{$$ = $2;}
	|	expression binary_op expression %prec OP 														{$$ = createBinNode($2, $3, $1);}
	|	MOINS expression 																				{$$ = createNode("-", $2, NULL);}
	|	CONSTANTE 																						{char s[10]; sprintf(s, "%d", $1); $$ = createLeaf(s);}
	|	variable 																						{$$ = $1;}
	|	IDENTIFICATEUR '(' liste_expressions ')' 														{$$ = createTypedNode($1, $3, NULL, CALL_FUN_T);}
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
	|	condition binary_rel condition %prec REL 														{$$ = createBinNode($2, $3, $1);}
	|	'(' condition ')' 																				{$$ = $2;}
	|	expression binary_comp expression 																{$$ = createBinNode($2, $3, $1);}
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
