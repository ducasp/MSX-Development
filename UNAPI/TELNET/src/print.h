// Just some functions to abstract screen printing routines

void print(char* s) __z88dk_fastcall;
void printChar(char c) __z88dk_fastcall;
void StartPrintBuffer();
void EndPrintBuffer();
void initPrint();
void initAnsi(unsigned int uiCallBackFunction);
void endAnsi();
