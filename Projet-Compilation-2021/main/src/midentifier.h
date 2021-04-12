typedef struct MFun
{
	char *name;
	int args;
	struct MFun *nextFun;
} MFun;


typedef struct MVar
{
	char *name;
	struct MVar *nextVar;
} MVar;


void addFun(MFun *fun, char *n, int nba);

void addVar(MVar *var, char *n);

int searchFun(MFun *fun, char *n, int nba);

int searchVar(MVar *var, char *n);

void freeMVar(MVar *fst);

void freeMFun(MFun *fst);