#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct Node
{
	char *value;
	struct Node *nodeSon;
	struct Node *nodeBrother;
} Node;

Node *createNode(char *v, Node *s, Node *b);

Node *createBinNode(char *v, Node *s, Node *b);

Node *createLeaf(char *v);

Node *setBrother(Node *n, Node *b);

Node *addNewSon(Node *n, Node *s);

char *buildStr(char *str1, char *str2);
