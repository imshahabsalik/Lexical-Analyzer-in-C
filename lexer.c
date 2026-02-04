#include <stdio.h>
#include <ctype.h>
#include "lexer.h"

int runLexer(const char *inputFile, const char *outputFile) {
    FILE *in, *out;
    char ch, buffer[50];
    int i = 0;

    in = fopen(inputFile, "r");
    out = fopen(outputFile, "w");

    if (in == NULL || out == NULL) {
        printf("File error\n");
        if (in) fclose(in);
        if (out) fclose(out);
        return 0;
    }

    while ((ch = fgetc(in)) != EOF) {
        if (isalnum(ch)) {
            buffer[i++] = ch;
        } else {
            if (i != 0) {
                buffer[i] = '\0';
                i = 0;

                if (isKeyword(buffer))
                    fprintf(out, "(KEYWORD, %s)\n", buffer);
                else if (isdigit(buffer[0]))
                    fprintf(out, "(CONSTANT, %s)\n", buffer);
                else
                    fprintf(out, "(IDENTIFIER, %s)\n", buffer);
            }

            if (isOperator(ch))
                fprintf(out, "(OPERATOR, %c)\n", ch);
            else if (isSeparator(ch))
                fprintf(out, "(SEPARATOR, %c)\n", ch);
        }
    }

    if (i != 0) {
        buffer[i] = '\0';
        if (isKeyword(buffer))
            fprintf(out, "(KEYWORD, %s)\n", buffer);
        else if (isdigit(buffer[0]))
            fprintf(out, "(CONSTANT, %s)\n", buffer);
        else
            fprintf(out, "(IDENTIFIER, %s)\n", buffer);
    }

    fclose(in);
    fclose(out);
    return 1;
}
