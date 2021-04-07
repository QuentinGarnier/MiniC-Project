D                       [0-9]
L                       [a-zA-Z_]
H                       [a-fA-F0-9]
E                       [Ee][+-]?{D}+
FS                      (f|F|l|L)
IS                      (u|U|l|L)*

%s                      COMMENT


%{
#include <stdio.h>
#include "nodes.h"
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

{L}({L}|{D})*           { yylval.str = strdup(yytext); return IDENTIFICATEUR; /* printf("%s\n", yytext); */ }

{D}+                    { yylval.integer = atoi(yytext); return CONSTANTE; }

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

Node *createNode(char *v, Node *s, Node *b)
{
    Node *n = malloc(sizeof(Node));
    n->value = strdup(v);
    n->nodeSon = s;
    n->nodeBrother = b;
    n->nodeType = CLASSIC_T;
    return n;
}

Node *createNodeTyped(char *v, Node *s, Node *b, NodeType nt)
{
    Node *n = malloc(sizeof(Node));
    n->value = strdup(v);
    n->nodeSon = s;
    n->nodeBrother = b;
    n->nodeType = nt;
    return n;
}

Node *createBinNode(char *v, Node *s, Node *b)
{
    Node *n = malloc(sizeof(Node));
    n->value = strdup(v);
    n->nodeSon = s;
    n->nodeBrother = NULL;
    n->nodeSon->nodeBrother = b;
    return n;
}

Node *createLeaf(char *v)
{
    return createNode(v, NULL, NULL);
}

Node *setBrother(Node *n, Node *b)
{
    n->nodeBrother = b;
    return n;
}

Node *addNewSon(Node *n, Node *s)
{
    n->nodeSon->nodeBrother = s;
    return n;
}

char *buildStr(char *str1, char *str2)
{
    char *res = (char *)malloc(strlen(str1) + strlen(str2) + 1);
    strcpy(res,str1);
    strcat(res,str2);
    return res;
}

void nodeToDot(FILE* file, Node *n, int *id, int fatherID)
{
    int tmp = *id;
    if(fatherID >= 0) fprintf(file, "\tn_%d [label=\"%s\" shape=ellipse color=black];\n", *id, n->value);
    if(fatherID > 0) fprintf(file, "\tn_%d -> n_%d;\n", fatherID, *id);
    *id = *id + 1;
    if(n->nodeBrother != NULL) {
        nodeToDot(file, n->nodeBrother, id, fatherID);
    }
    if(n->nodeSon != NULL) {
        nodeToDot(file, n->nodeSon, id, tmp);
    }
}

void buildTree(Node *root)
{
    FILE* file = NULL;
    file = fopen("graph.dot", "w");
    if(file == NULL) printf("Failed to open the file 'graph.dot'.");
    else {
        int id = 0;
        fprintf(file, "digraph G {\n");
        nodeToDot(file, root, &id, -1);
        fprintf(file, "}");
        fclose(file);
    }
}
