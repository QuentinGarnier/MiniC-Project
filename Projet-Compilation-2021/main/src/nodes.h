#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct Node
{
	char *value;
	struct Node *nodeSon;
	struct Node *nodeBrother;
} Node;

Node *createNode(char *v, Node *s, Node *b)
{
	Node *n = malloc(sizeof(Node));
	n->value = strdup(v);
	n->nodeSon = s;
	n->nodeBrother = b;
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

void printNames(Node *n)
{
    Node *tmp = n;
    while(tmp->nodeBrother != NULL) {
        printf("%s\n", tmp->value);
        tmp = tmp->nodeBrother;
    }
    printf("%s\n", tmp->value);
}