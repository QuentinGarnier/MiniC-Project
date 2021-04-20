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

int searchFun(FunStack *fun, char *n, int nba);

void freeFunStack(FunStack *fst);


VarStack *createVar(char *n, VarStack *next);

VarStack *addVar(VarStack *stack, char *n);

int searchVar(VarStack *var, char *n);

void freeVarStack(VarStack *vst);


NestingStack *createNestingStack(int floor, VarStack *varStack, NestingStack *next);

NestingStack *addNesting(NestingStack *stack, int floor, VarStack *varStack);

NestingStack *addVarToNesting(NestingStack *stack, int floor, char *n);

int searchVarInNesting(NestingStack *nesting, char *n);

void freeLastNestingStack(NestingStack *nst);

void freeNestingStack(NestingStack *nst);