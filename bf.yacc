%{
#include <stdio.h>
#include <stdbool.h>
int yylex(void);
int yyerror(char *s);

// used for interp
char tape[30000] = {0};
char *ptr = tape;
FILE *file_ptr;

struct node {
	int data;
	struct node *next;
};
void push(int loc, struct node** stack) {
	struct node* to_push = (struct element*)malloc(sizeof(struct node));
	to_push -> data = loc;
	to_push -> next = *stack;
	(*stack) = to_push;
}
void pop(struct node** stack) {
	if (*stack != NULL) {
		struct node* tmp = *stack;
		*stack = (*stack) -> next;
		free(tmp);
	}
}
int peek(struct node* stack) {
	if (stack != NULL) {
		return (stack -> data);
	}
}

// used for "semantics"
int position = 0;
%}
%token MV_RIGHT;
%token MV_LEFT;
%token INC;
%token DEC;
%token PUT;
%token GET;
%token START;
%token END;
%%
Expr :
	MV_RIGHT 
		{
			position++;
			if (position >= 30000) {
				printf("\nWill exceed tape length! Max length: 30000\n");
				YYABORT;
			}
		} 
	Expr
	| MV_LEFT 
		{
			position--;
			if (position < 0) {
				printf("\nWill go below index 0 on tape!\n");
				YYABORT;
			}
		}  
	  Expr
	| INC Expr
	| DEC Expr
	| PUT Expr
	| GET Expr
	| START Expr END Expr
	|
	;

%%
int main(int argc, char **argv) {
	file_ptr = fopen(argv[1], "r+");	
	bool valid = 0 == yyparse();
	if (!valid) {
		return 1;
	}
	struct node* location_stack = (struct node*)malloc(sizeof(struct node));
	int stack_size = 0;
	char current;

	while(!feof(file_ptr)) {
		current = fgetc(file_ptr);
		//printf("%c", current);
		switch (current) {
			case '>':
				position++; // Incremement current position in file
				++ptr; // Move forward in Tape
				break;
			case '<':
				position++; // Incremement current position in file
				--ptr; // Move backwards in Tape
				break;
			case '+':
				position++; // Increment current position in file
				++*ptr; // Incremement element pointed to in tape
				break;
			case '-':
				position++; // you know the drill by now
				--*ptr; // Decrement element pointed to in tape
				break;
			case '.':
				position++; // yup
				putchar(*ptr); // output char at this position in tape
				break;
			case ',':
				position++; // yea
				*ptr = getchar(); // get user input, put in tape
				break;
			case '[':
				position++;
				// If stack empty, push position of [ onto stack
				if (stack_size == 0) {
					location_stack -> data = position;
					location_stack -> next = NULL;
					stack_size++;
				}
				else {
					stack_size++;
					push(position, &location_stack);
				}
				break;
			case ']':
				if (*ptr == 0) {
					position++;
					stack_size--;
					pop(&location_stack);
				}
				else {
					int jump_to = peek(location_stack);
					long move_back = jump_to - position - 1;
					//printf("%d", jump_to);
					//printf("%c", ' ');
					//printf("%d", position);
					fseek(file_ptr, move_back, SEEK_CUR);
					position = jump_to;
				}
				break;
		}
	}
	printf("\n");

	return 0;
}
int yyerror(char *s) {
	fprintf(stderr, "%s\n", s);
}

