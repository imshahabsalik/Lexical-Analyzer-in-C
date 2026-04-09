%{
#include <stdio.h>
FILE *yyout;
%}

%option noyywrap

DIGIT      [0-9]
LETTER     [a-zA-Z_]
ID         {LETTER}({LETTER}|{DIGIT})*
NUM        {DIGIT}+
FLOAT      {DIGIT}+"."{DIGIT}+
CHAR       \'[^\'\n]\'
STRING     \"[^\"]*\"

%%
"#include"   { fprintf(yyout, "%-15s | %-15s\n", yytext, "PREPROCESSOR"); }
"<"[a-zA-Z0-9\.]+">"   { fprintf(yyout, "%-15s | %-15s\n", yytext, "HEADER"); }

int        { fprintf(yyout, "%-15s | %-15s\n", yytext, "KEYWORD"); }
float      { fprintf(yyout, "%-15s | %-15s\n", yytext, "KEYWORD"); }
char       { fprintf(yyout, "%-15s | %-15s\n", yytext, "KEYWORD"); }
if         { fprintf(yyout, "%-15s | %-15s\n", yytext, "KEYWORD"); }
else       { fprintf(yyout, "%-15s | %-15s\n", yytext, "KEYWORD"); }
return     { fprintf(yyout, "%-15s | %-15s\n", yytext, "KEYWORD"); }
while      { fprintf(yyout, "%-15s | %-15s\n", yytext, "KEYWORD"); }

{FLOAT}    { fprintf(yyout, "%-15s | %-15s\n", yytext, "FLOAT"); }
{NUM}      { fprintf(yyout, "%-15s | %-15s\n", yytext, "CONSTANT"); }

{CHAR}     { fprintf(yyout, "%-15s | %-15s\n", yytext, "CHAR"); }
{STRING}   { fprintf(yyout, "%-15s | %-15s\n", yytext, "STRING"); }

"=="       { fprintf(yyout, "%-15s | %-15s\n", yytext, "OPERATOR"); }
"!="       { fprintf(yyout, "%-15s | %-15s\n", yytext, "OPERATOR"); }
"<="       { fprintf(yyout, "%-15s | %-15s\n", yytext, "OPERATOR"); }
">="       { fprintf(yyout, "%-15s | %-15s\n", yytext, "OPERATOR"); }
"++"       { fprintf(yyout, "%-15s | %-15s\n", yytext, "OPERATOR"); }
"--"       { fprintf(yyout, "%-15s | %-15s\n", yytext, "OPERATOR"); }
"&&"       { fprintf(yyout, "%-15s | %-15s\n", yytext, "OPERATOR"); }
"||"       { fprintf(yyout, "%-15s | %-15s\n", yytext, "OPERATOR"); }

[+\-*/=<>] { fprintf(yyout, "%-15s | %-15s\n", yytext, "OPERATOR"); }

[;,(){}]   { fprintf(yyout, "%-15s | %-15s\n", yytext, "SEPARATOR"); }

{ID}       { fprintf(yyout, "%-15s | %-15s\n", yytext, "IDENTIFIER"); }

[ \t\n]+   ;

%%

int main() {
    yyout = fopen("tokens.txt", "w");

    fprintf(yyout, "========================================\n");
    fprintf(yyout, "%-15s | %-15s\n", "LEXEME", "TOKEN TYPE");
    fprintf(yyout, "========================================\n");

    yylex();

    fprintf(yyout, "========================================\n");

    fclose(yyout);
    return 0;
}