#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef enum
{
	BREAK_T, CLASSIC_T, RETURN_T, IF_T, FUN_T, CALL_FUN_T
} NodeType;

typedef struct Node
{
	char *value;
	struct Node *nodeSon;
	struct Node *nodeBrother;
    NodeType nodeType;
} Node;

Node *createNode(char *v, Node *s, Node *b);

Node *createTypedNode(char *v, Node *s, Node *b, NodeType nt);

Node *createBinNode(char *v, Node *s, Node *b);

Node *createTypedBinNode(char *v, Node *s, Node *b, NodeType nt);

Node *createLeaf(char *v);

Node *createTypedLeaf(char *v, NodeType nt);

Node *setBrother(Node *n, Node *b);

Node *setSon(Node *n, Node *s);

void *setLastBrother(Node *n, Node *b);

Node *specialSwitchNode(Node *expr, Node *bloc);

char *nameLastBrother(Node *n);

char *buildStr(char *str1, char *str2);

void nodeToDot(FILE* file, Node *n, int *id, int fatherID);

void buildTree(Node *root);