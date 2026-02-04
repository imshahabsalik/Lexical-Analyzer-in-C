#include <stdio.h>
#include "lexer.h"

int main(int argc, char *argv[]) {

    if (argc != 2) {
        printf("Usage: lexer <input_file.c>\n");
        return 1;
    }

    if (runLexer(argv[1], "output/tokens.txt")) {
        printf("Lexical analysis completed successfully.\n");
        printf("Output written to output/tokens.txt\n");
    } else {
        printf("Lexical analysis failed.\n");
    }

    return 0;
}
