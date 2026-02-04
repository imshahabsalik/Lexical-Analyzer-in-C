#include "lexer.h"

int isOperator(char ch) {
    char operators[] = "+-*/=<>";
    for (int i = 0; operators[i] != '\0'; i++) {
        if (ch == operators[i])
            return 1;
    }
    return 0;
}
