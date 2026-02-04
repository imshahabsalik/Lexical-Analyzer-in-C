#include "lexer.h"

int isSeparator(char ch) {
    char separators[] = ";,(){}";
    for (int i = 0; separators[i] != '\0'; i++) {
        if (ch == separators[i])
            return 1;
    }
    return 0;
}
