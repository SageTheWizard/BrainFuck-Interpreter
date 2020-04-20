%{
#include "y.tab.h"
%}

%%
">" {
	return MV_RIGHT;
}

"<" {
	return MV_LEFT;
}

"+" {
	return INC;
}

"-" {
	return DEC;
}

"." {
	return PUT;
}

"," {
	return GET;
}

"[" {
	return START;
}

"]" {
	return END;
}

[ \n\t\r]+ { 
	// skip 
}

%%
int yywrap(void) {
	return 1;
}

