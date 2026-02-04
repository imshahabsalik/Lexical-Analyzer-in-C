#ifndef LEXER_H
#define LEXER_H

int runLexer(const char *inputFile, const char *outputFile);

int isKeyword(char buffer[]);
int isOperator(char ch);
int isSeparator(char ch);

#endif
