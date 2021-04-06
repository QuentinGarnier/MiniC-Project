%{
	#include <stdio.h>
	#include <stdlib.h>
	#include "nodes.h"

	Node *root;
%}


%token IDENTIFICATEUR CONSTANTE VOID INT FOR WHILE IF ELSE SWITCH CASE DEFAULT
%token BREAK RETURN PLUS MOINS MUL DIV LSHIFT RSHIFT BAND BOR LAND LOR LT GT 
%token GEQ LEQ EQ NEQ NOT EXTERN
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


%%
programme	:	
		liste_declarations liste_fonctions																{/*root = createNode("root", $2, NULL);*/}
;
liste_declarations	:	
		liste_declarations declaration 																	{}
	|																									{}
;
liste_fonctions	:	
		liste_fonctions fonction 																		{/*$$ = setBrother($2, $1);*/}
|               fonction 																				{/*$$ = $1;*/}
;
declaration	:	
		type liste_declarateurs ';' 																	{}
;
liste_declarateurs	:	
		liste_declarateurs ',' declarateur 																{}
	|	declarateur 																					{}
;
declarateur	:	
		IDENTIFICATEUR 																					{}
	|	declarateur '[' CONSTANTE ']' 																	{}
;
fonction	:	
		type IDENTIFICATEUR '(' liste_parms ')' '{' liste_declarations liste_instructions '}' 			{/*$$ = createNode(buildStr($2, buildStr(", ", $1)), $8, NULL);*/}
	|	EXTERN type IDENTIFICATEUR '(' liste_parms ')' ';' 												{/*$$ = createNode("", NULL, NULL);*/}
;
type	:	
		VOID 																							{/*$$ = "void";*/}
	|	INT 																							{/*$$ = "int";*/}
;
liste_parms	:	
		liste_parms_content 																			{}
	|																									{}
;
liste_parms_content	:
		liste_parms_content ',' parm 																	{}
	|	parm 																							{}
;
parm	:	
		INT IDENTIFICATEUR 																				{}
;
liste_instructions :	
		liste_instructions instruction 																	{}
	| 																									{}
;
instruction	:	
		iteration 																						{}
	|	selection 																						{}
	|	saut 																							{}
	|	affectation ';' 																				{}
	|	bloc 																							{}
	|	appel 																							{}
;
iteration	:	
		FOR '(' affectation ';' condition ';' affectation ')' instruction 								{}
	|	WHILE '(' condition ')' instruction 															{}
;
selection	:	
		IF '(' condition ')' instruction %prec THEN 													{}
	|	IF '(' condition ')' instruction ELSE instruction 												{}
	|	SWITCH '(' expression ')' instruction 															{}
	|	CASE CONSTANTE ':' instruction 																	{}
	|	DEFAULT ':' instruction 																		{}
;
saut	:	
		BREAK ';' 																						{}
	|	RETURN ';' 																						{}
	|	RETURN expression ';' 																			{}
;
affectation	:	
		variable '=' expression 																		{/*$$ = createBinNode(":=", $1, $3);*/}
;
bloc	:	
		'{' liste_declarations liste_instructions '}' 													{}
;
appel	:	
		IDENTIFICATEUR '(' liste_expressions ')' ';'  													{}
;
variable	:	
		IDENTIFICATEUR 																					{/*$$ = createNode($1, NULL, NULL);*/}
	|	variableTab '[' expression ']' 																	{/*$$ = addNewSon($1, $3);*/}
;
variableTab	:	
		IDENTIFICATEUR 																					{/*$$ = createNode("tab", $1, NULL);*/}
	|	variableTab '[' expression ']' 																	{/*$$ = addNewSon($1, $3);*/}
;
expression	:	
		'(' expression ')' 																				{}
	|	expression binary_op expression %prec OP 														{}
	|	MOINS expression 																				{}
	|	CONSTANTE 																						{}
	|	variable 																						{}
	|	IDENTIFICATEUR '(' liste_expressions ')' 														{}
;
liste_expressions	:	
		liste_expressions_content 																		{}
	| 																									{}
;
liste_expressions_content	:
		liste_expressions_content ',' expression 														{}
	|	expression 																						{}
;
condition	:	
		NOT '(' condition ')' 																			{}
	|	condition binary_rel condition %prec REL 														{}
	|	'(' condition ')' 																				{}
	|	expression binary_comp expression 																{}
;
binary_op	:	
		PLUS 																							{}
	|       MOINS 																						{}
	|	MUL 																							{}
	|	DIV 																							{}
	|       LSHIFT 																						{}
	|       RSHIFT 																						{}
	|	BAND 																							{}
	|	BOR 																							{}
;
binary_rel	:	
		LAND 																							{}
	|	LOR 																							{}
;
binary_comp	:	
		LT 																								{}
	|	GT 																								{}
	|	GEQ 																							{}
	|	LEQ 																							{}
	|	EQ 																								{}
	|	NEQ 																							{}
;
%%



int yyerror(char *s) {
	fprintf(stderr, "%s\n", s);
	exit(1);
}


int main() {
	yyparse();



	/* MAIN autrefois dans le.l :
	 * while(1) yylex();
	 * printf("END OF FILE!\n");
	 */

	/* Rappel : CTRL - D pour quitter quand on écrit */
}
