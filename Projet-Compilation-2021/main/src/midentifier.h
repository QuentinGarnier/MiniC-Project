typedef struct FunStack
{
	char *name;
	int args;
	struct FunStack *nextFun;
} FunStack;

typedef struct VarStack
{
	char *name;
	struct VarStack *nextVar;
} VarStack;

typedef struct NestingStack
{
	int nesting;
	VarStack *varStack;
	struct NestingStack *nextStack;
} NestingStack;



FunStack *createFunStack(char *n, int nba, FunStack *next);

FunStack *addFun(FunStack *stack, char *n, int nba);

void addVar(VarStack *var, char *n);

int searchFun(FunStack *fun, char *n, int nba);

int searchVar(VarStack *var, char *n);

void freeVarStack(VarStack *fst);

void freeFunStack(FunStack *fst);