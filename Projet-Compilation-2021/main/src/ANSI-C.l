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
#include "midentifier.h"
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

Node *createTypedNode(char *v, Node *s, Node *b, NodeType nt)
{
    Node *n = malloc(sizeof(Node));
    n->value = strdup(v);
    n->nodeSon = s;
    n->nodeBrother = b;
    n->nodeType = nt;
    return n;
}

Node *createNode(char *v, Node *s, Node *b)
{
    return createTypedNode(v, s, b, CLASSIC_T);
}

Node *createTypedBinNode(char *v, Node *s, Node *b, NodeType nt)
{
    Node *n = malloc(sizeof(Node));
    n->value = strdup(v);
    n->nodeSon = s;
    n->nodeBrother = NULL;
    setLastBrother(n->nodeSon, b);
    n->nodeType = nt;
    return n;
}

Node *createBinNode(char *v, Node *s, Node *b)
{
    return createTypedBinNode(v, s, b, CLASSIC_T);
}

Node *createLeaf(char *v)
{
    return createNode(v, NULL, NULL);
}

Node *createTypedLeaf(char *v, NodeType nt)
{
    return createTypedNode(v, NULL, NULL, nt);
}

Node *setBrother(Node *n, Node *b)
{
    n->nodeBrother = b;
    return n;
}

void *setLastBrother(Node *n, Node *b)
{
    if(n->nodeBrother == NULL) n->nodeBrother = b;
    else setLastBrother(n->nodeBrother, b);
}

void buildCasesNodes(Node *n, Node *chaine)
{
    if(strcmp(n->value, "CASE") == 0 || strcmp(n->value, "DEFAULT") == 0) {
        if(chaine != NULL) {
            setLastBrother(chaine, n->nodeSon->nodeBrother);
            n->nodeSon = chaine;
        }
        else if(strcmp(n->value, "CASE") == 0) n->nodeSon = n->nodeSon->nodeBrother;
        if(n->nodeBrother != NULL) buildCasesNodes(n->nodeBrother, NULL);
    } else if(n->nodeBrother != NULL) {
        if(chaine == NULL) buildCasesNodes(n->nodeBrother, createTypedNode(n->value, n->nodeSon, NULL, n->nodeType));
        else {
            setLastBrother(chaine, createNode(n->value, n->nodeSon, NULL));
            buildCasesNodes(n->nodeBrother, chaine);
        }
    }

}

void epureSwitchTree(Node *switchSon)
{
    if(switchSon->nodeBrother != NULL) {
        if(strcmp(switchSon->nodeBrother->value, "CASE") == 0 || strcmp(switchSon->nodeBrother->value, "DEFAULT") == 0) epureSwitchTree(switchSon->nodeBrother);
        else {
            switchSon->nodeBrother = switchSon->nodeBrother->nodeBrother;
            if(switchSon->nodeBrother != NULL) epureSwitchTree(switchSon->nodeBrother);
        }
    }
}

Node *specialSwitchNode(Node *expr, Node *bloc)
{
    if(expr == NULL || bloc == NULL) return NULL;
    if(strcmp(bloc->value, "BLOC") == 0) {
        buildCasesNodes(bloc->nodeSon, NULL);
        epureSwitchTree(bloc->nodeSon);
        setLastBrother(bloc->nodeSon, expr);
        return createNode("SWITCH", bloc->nodeSon, NULL);
    }
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
    *id = *id + 1;
    if(n->nodeBrother != NULL) {
        nodeToDot(file, n->nodeBrother, id, fatherID);
    }
    if(fatherID >= 0) {
        fprintf(file, "\tn_%d [label=\"%s\" shape=", tmp, n->value);
        switch(n->nodeType) {
            case BREAK_T: fprintf(file, "box color=black"); break;
            case RETURN_T: fprintf(file, "trapezium color=blue"); break;
            case IF_T: fprintf(file, "diamond color=black"); break;
            case FUN_T: fprintf(file, "invtrapezium color=blue"); break;
            case CALL_FUN_T: fprintf(file, "septagon color=black"); break;
            default: fprintf(file, "ellipse color=black"); break;
        }
        fprintf(file, "];\n");
    }
    if(fatherID > 0) fprintf(file, "\tn_%d -> n_%d;\n", fatherID, tmp);
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




MFun *createMFun(char *n, int nba)
{
    MFun *f = malloc(sizeof(MFun));
    f->name = strdup(n);
    f->args = nba;
    f->nextFun = NULL;
    return f;
}

void addLastFun(MFun *stack, MFun *fun)
{
    if(stack->nextFun != NULL) addLastFun(stack->nextFun, fun);
    else stack->nextFun = fun;
}

void addFun(MFun *fun, char *n, int nba)
{
    if(fun != NULL) addLastFun(fun, createMFun(n, nba));
    else fun = createMFun(n, nba);
}

int searchFun(MFun *fun, char *n, int nba)
{
    if(fun->nextFun == NULL) return -1;
    if(strcmp(fun->name, n) == 0 && fun->args == nba) return 0;
    else searchFun(fun->nextFun, n, nba);
}

void freeMFun(MFun *fst)
{
    MFun *tmp;
    while(fst != NULL)
    {
        tmp = fst;
        fst = fst->nextFun;
        free(tmp);
    }
}



MVar *createMVar(char *n)
{
    MVar *v = malloc(sizeof(MVar));
    v->name = strdup(n);
    v->nextVar = NULL;
    return v;
}

void addLastVar(MVar *stack, MVar *var)
{
    if(stack->nextVar != NULL) addLastVar(stack->nextVar, var);
    else stack->nextVar = var;
}

void addVar(MVar *var, char *n)
{
    if(var != NULL) addLastVar(var, createMVar(n));
    else var = createMVar(n);
}

int searchVar(MVar *var, char *n)
{
    if(var->nextVar == NULL) return -1;
    if(strcmp(var->name, n) == 0) return 0;
    else searchVar(var->nextVar, n);
}

void freeMVar(MVar *fst)
{
    MVar *tmp;
    while(fst != NULL)
    {
        tmp = fst;
        fst = fst->nextVar;
        free(tmp);
    }
}