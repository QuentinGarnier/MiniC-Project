#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef enum
{
    CLASSIC_T, RETURN_T, IF_T, FUN_T, CALL_FUN_T, BREAK_T
} NodeType;

typedef struct Node
{
	char *value;
	struct Node *nodeSon;
	struct Node *nodeBrother;
    NodeType nodeType;
} Node;

Node *createNode(char *v, Node *s, Node *b);

Node *createNodeTyped(char *v, Node *s, Node *b, NodeType nt);

Node *createBinNode(char *v, Node *s, Node *b);

Node *createLeaf(char *v);

Node *setBrother(Node *n, Node *b);

Node *addNewSon(Node *n, Node *s);

char *buildStr(char *str1, char *str2);

void nodeToDot(FILE* file, Node *n, int *id, int fatherID);

void buildTree(Node *root);