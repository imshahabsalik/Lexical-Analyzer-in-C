#include <string.h>
#include "lexer.h"

int isKeyword(char buffer[]) {
    char keywords[7][10] = {
        "int", "float", "char",
        "if", "else", "return", "while"
    };

    for (int i = 0; i < 7; i++) {
        if (strcmp(buffer, keywords[i]) == 0)
            return 1;
    }
    return 0;
}
