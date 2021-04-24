%{
	#include <stdio.h>
	#include <stdlib.h>
	#include "nodes.h"
	#include "midentifier.h"

	extern int yylineno;

	Node *root;

	FunStack *funStack;
	NestingStack *nestingStack;

	FType ftype = F_VOID;
	int nesting = 0; //Count for nesting level (0 = global)
	char error = 0;  //Error detected  (0 = false)
	char first = 0;  //Boolean for liste_declarations: 0 is global, 1 is start inside-bloc, else is start function
	char inside = 0; //Boolean for functions' args
	int count = 0;   //Count for functions' parameters
	int count2 = 0;  //Count to verify the functions' numer of parameters
	int size = 0;    //Size to verify variables type (array or not, and array's dimensions); 0 for variables
	int sizeExp = 0; //Size for specific case of var inside array dimensions
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
	VarStack *varStack;
}
%type <str> binary_op binary_rel binary_comp type
%type <node> liste_declarations liste_fonctions declaration fonction liste_declarateurs declarateur liste_parms liste_instructions liste_parms_content parm instruction iteration selection saut affectation bloc appel condition expression variable variableTab liste_expressions liste_expressions_content entete
%type<varStack> declarateur_tab


%%
programme	:	
		liste_declarations liste_fonctions																{root = createBinNode("root", $2, NULL); freeFunStack(funStack); }
;
liste_declarations	:	
		liste_declarations declaration 																	{$$ = NULL;}
	|																									{if(first == 0) {nestingStack = addNesting(nestingStack, nesting, NULL); first = 1;} else if(first == 1) { nesting++; nestingStack = addNesting(nestingStack, nesting, NULL); } else first = 1; $$ = NULL;}
;
liste_fonctions	:	
		liste_fonctions fonction 																		{$$ = setBrother($2, $1);}
|               fonction 																				{$$ = $1;}
;
declaration	:	
		type liste_declarateurs ';' 																	{$$ = NULL;}
;
liste_declarateurs	:	
		liste_declarateurs ',' declarateur 																{$$ = NULL;}
	|	declarateur 																					{$$ = NULL;}
;
declarateur	:	
		IDENTIFICATEUR 																					{nestingStack = addVarToNesting(nestingStack, nesting, $1, 0); $$ = NULL;}
	|	declarateur_tab '[' CONSTANTE ']' 																{nestingStack = addFullVarToNesting(nestingStack, nesting, changeSize($1, size)); size = 0; $$ = NULL;}
;
declarateur_tab	:	
		IDENTIFICATEUR 																					{size++; $$ = createVar($1, 1, NULL);}
	|	declarateur_tab '[' CONSTANTE ']' 																{size++; $$ = $1;}
;
fonction	:	
		entete bloc 																					{first = 1; ftype = F_VOID; $$ = setSon($1, $2);}
	|	EXTERN type IDENTIFICATEUR '(' liste_parms ')' ';' 												{funStack = addFun(funStack, $3, count, ftypeFor($2)); count = 0; first = 1; freeLastNestingStack(nestingStack); nesting--; $$ = createTypedLeaf(buildStr($3, buildStr(", ", $2)), FUN_T);}
;
entete		:
		type IDENTIFICATEUR '(' liste_parms ')'															{funStack = addFun(funStack, $2, count, ftypeFor($1)); count = 0; ftype = ftypeFor($1); $$ = createTypedLeaf(buildStr($2, buildStr(", ", $1)), FUN_T);}
type	:	
		VOID 																							{$$ = "void";}
	|	INT 																							{$$ = "int";}
;
liste_parms	:	
		liste_parms_content 																			{inside = 0; $$ = NULL;}
	|																									{nesting++; nestingStack = addNesting(nestingStack, nesting, NULL); first = 2; $$ = NULL;}
;
liste_parms_content	:
		liste_parms_content ',' parm 																	{$$ = NULL;}
	|	parm 																							{$$ = NULL;}
;
parm	:	
		INT IDENTIFICATEUR 																				{count++; if(inside == 0) {nesting++; nestingStack = addNesting(nestingStack, nesting, NULL); first = 2; inside = 1;} nestingStack = addVarToNesting(nestingStack, nesting, $2, 0); $$ = NULL;}
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
	|	RETURN ';' 																						{if(ftype != F_VOID) { fprintf(stderr, "Error on 'return' instruction"); yyerror("a value is expected"); } $$ = createTypedLeaf("RETURN", RETURN_T);}
	|	RETURN expression ';' 																			{if(ftype == F_VOID) { fprintf(stderr, "Error on 'return' instruction"); yyerror("no value is expected in a void function"); } $$ = createTypedNode("RETURN", $2, NULL, RETURN_T);}
;
affectation	:	
		variable '=' expression 																		{$$ = createBinNode(":=", $3, $1);}
;
bloc	:	
		'{' liste_declarations liste_instructions '}' 													{freeLastNestingStack(nestingStack); nesting--; $$ = createNode("BLOC", $3, NULL);}
;
appel	:	
		IDENTIFICATEUR '(' liste_expressions ')' ';'  													{if(searchFun(funStack, $1, count2) < 0) { fprintf(stderr, "Error on %s", $1); yyerror("function undefined or has wrong number of arguments"); } count2 = 0; $$ = createTypedNode($1, $3, NULL, CALL_FUN_T);}
;
variable	:	
		IDENTIFICATEUR 																					{switch(searchVar(nestingStack, $1, 0)) {case -1: fprintf(stderr, "Error on %s", $1); yyerror("variable undefined or called with wrong dimensions"); break; case 1: fprintf(stderr, "Error on %s", $1); yyerror("a value was expected, found an array"); break; default: break;} $$ = createLeaf($1);}
	|	variableTab '[' expression ']' 																	{switch(searchVar(nestingStack, nameLastBrother($1), sizeExp > 0 ? sizeExp : size)) {case -1: fprintf(stderr, "Error on %s", nameLastBrother($1)); yyerror("variable undefined or called with wrong dimensions"); break; case 1: fprintf(stderr, "Error on %s", nameLastBrother($1)); yyerror("a value was expected, found an array"); break; default: break;} if(sizeExp == 0) size = 0; sizeExp = 0; $$ = createNode("TAB", setBrother($3, $1), NULL);}
;
variableTab	:	
		IDENTIFICATEUR 																					{size > 0 ? sizeExp++ : size++; $$ = createLeaf($1);}
	|	variableTab '[' expression ']' 																	{sizeExp > 0 ? sizeExp++ : size++; $$ = setBrother($3,  $1);}
;
expression	:	
		'(' expression ')' 																				{$$ = $2;}
	|	expression binary_op expression %prec OP 														{$$ = createBinNode($2, $3, $1);}
	|	MOINS expression 																				{$$ = createNode("-", $2, NULL);}
	|	CONSTANTE 																						{char s[10]; sprintf(s, "%d", $1); $$ = createLeaf(s);}
	|	variable 																						{$$ = $1;}
	|	IDENTIFICATEUR '(' liste_expressions ')' 														{switch(searchFun(funStack, $1, count2)) {case 1: fprintf(stderr, "Error on %s", $1); yyerror("not a number"); break; case -1: fprintf(stderr, "Error on %s", $1); yyerror("function undefined or has wrong number of arguments"); break; default: break;} count2 = 0; $$ = createTypedNode($1, $3, NULL, CALL_FUN_T);}
;
liste_expressions	:	
		liste_expressions_content 																		{$$ = $1;}
	| 																									{$$ = NULL;}
;
liste_expressions_content	:
		liste_expressions_content ',' expression 														{count2++; $$ = setBrother($3, $1);}
	|	expression 																						{count2++; $$ = $1;}
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
	if(strcmp(s, "syntax error") == 0) fprintf(stderr, "Error");
	fprintf(stderr, ": %s (line %d)\n", s, yylineno);
	error = 1;
}


int main() {
	yyparse();
	if(error == 0) buildTree(root);
	else exit(EXIT_FAILURE);
	return 0;
}
