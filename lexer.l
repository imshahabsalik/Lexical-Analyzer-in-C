%{
#include <stdio.h>
#include <string.h>

FILE *yyout;
int line = 1;

#define MAX 100

struct symbol {
    char name[50];
    char type[20];
    char value[50];
};

struct symbol table[MAX];
int count = 0;
char current_type[20] = "";

int keyword_count = 0;
int identifier_count = 0;
int operator_count = 0;
int constant_count = 0;
int float_count = 0;
int string_count = 0;
int char_count = 0;
%}

%option noyywrap
%x COMMENT

%%
\n { line++; }

"//".* ;

"/*" { BEGIN(COMMENT); }
<COMMENT>[^*\n]* ;
<COMMENT>"*"+[^*/\n]* ;
<COMMENT>\n { line++; }
<COMMENT>"*"+"/" { BEGIN(INITIAL); }
<COMMENT><<EOF>> {
    fprintf(yyout,"%4d | %-15s | %-15s\n", line, "/*", "ERROR_UNTERMINATED_COMMENT");
    return 0;
}

"#"[a-zA-Z_]+ {
    fprintf(yyout,"%4d | %-15s | %-15s\n", line, yytext, "PREPROCESSOR");
}

"<"[a-zA-Z0-9\.]+">" {
    fprintf(yyout,"%4d | %-15s | %-15s\n", line, yytext, "HEADER");
}

auto|break|case|char|const|continue|default|do|double|else|enum|extern|float|for|goto|if|int|long|register|return|short|signed|sizeof|static|struct|switch|typedef|union|unsigned|void|volatile|while {
    keyword_count++;
    fprintf(yyout,"%4d | %-15s | %-15s\n", line, yytext, "KEYWORD");

    if(strcmp(yytext,"int")==0 || strcmp(yytext,"float")==0 || strcmp(yytext,"char")==0)
        strcpy(current_type,yytext);
}

[0-9]+[a-zA-Z_]+ {
    fprintf(yyout,"%4d | %-15s | %-15s\n", line, yytext, "ERROR_INVALID_IDENTIFIER");
}

0[xX][0-9a-fA-F]+ {
    constant_count++;
    fprintf(yyout,"%4d | %-15s | %-15s\n", line, yytext, "HEX_CONSTANT");
}

0[0-7]+ {
    constant_count++;
    fprintf(yyout,"%4d | %-15s | %-15s\n", line, yytext, "OCTAL_CONSTANT");
}

[0-9]+(\.[0-9]+)?[eE][+-]?[0-9]+ {
    float_count++;
    fprintf(yyout,"%4d | %-15s | %-15s\n", line, yytext, "SCIENTIFIC");
}

[0-9]+"."[0-9]+ {
    float_count++;
    fprintf(yyout,"%4d | %-15s | %-15s\n", line, yytext, "FLOAT");
    if(count>0) strcpy(table[count-1].value,yytext);
}

\'(\\.|[^\\\'])\' {
    char_count++;
    fprintf(yyout,"%4d | %-15s | %-15s\n", line, yytext, "CHAR");
}

\"(\\.|[^\"])*\" {
    string_count++;
    fprintf(yyout,"%4d | %-15s | %-15s\n", line, yytext, "STRING");
}

[0-9]+ {
    constant_count++;
    fprintf(yyout,"%4d | %-15s | %-15s\n", line, yytext, "CONSTANT");
    if(count>0) strcpy(table[count-1].value,yytext);
}

"=="|"!="|"<="|">="|"++"|"--"|"&&"|"||"|"+="|"-="|"*="|"/="|"%="|"<<"|">>"|"->"|"&"|"|"|"^"|"~"|"!"|"?"|":" {
    operator_count++;
    fprintf(yyout,"%4d | %-15s | %-15s\n", line, yytext, "OPERATOR");
}

"="|"+"|"-"|"*"|"/"|"%"|"<"|">" {
    operator_count++;
    fprintf(yyout,"%4d | %-15s | %-15s\n", line, yytext, "OPERATOR");
}

";" {
    fprintf(yyout,"%4d | %-15s | %-15s\n", line, yytext, "SEPARATOR");
    strcpy(current_type,"");
}

","|"("|")"|"{"|"}" {
    fprintf(yyout,"%4d | %-15s | %-15s\n", line, yytext, "SEPARATOR");
}

[a-zA-Z_][a-zA-Z0-9_]* {
    identifier_count++;
    fprintf(yyout,"%4d | %-15s | %-15s\n", line, yytext, "IDENTIFIER");

    if(strlen(current_type)>0){
        strcpy(table[count].name,yytext);
        strcpy(table[count].type,current_type);
        strcpy(table[count].value,"");
        count++;
    }
}

[ \t\r]+ ;

. {
    fprintf(yyout,"%4d | %-15s | %-15s\n", line, yytext, "ERROR_UNKNOWN");
}
%%

int main(){
    yyin = fopen("input.c", "r");
    yyout = fopen("tokens.txt","w");

    if(!yyin) return 1;

    fprintf(yyout,"LINE | LEXEME         | TOKEN\n");
    fprintf(yyout,"----------------------------------------\n");

    yylex();

    fprintf(yyout,"\n=========== SYMBOL TABLE ===========\n");
    fprintf(yyout,"%-15s %-15s %-15s\n","Name","Type","Value");

    for(int i=0;i<count;i++){
        fprintf(yyout,"%-15s %-15s %-15s\n",
                table[i].name,
                table[i].type,
                table[i].value);
    }

    fprintf(yyout,"\n=========== TOKEN STATISTICS ===========\n");
    fprintf(yyout,"KEYWORD: %d\n",keyword_count);
    fprintf(yyout,"IDENTIFIER: %d\n",identifier_count);
    fprintf(yyout,"OPERATOR: %d\n",operator_count);
    fprintf(yyout,"CONSTANT: %d\n",constant_count);
    fprintf(yyout,"FLOAT: %d\n",float_count);
    fprintf(yyout,"STRING: %d\n",string_count);
    fprintf(yyout,"CHAR: %d\n",char_count);

    fclose(yyout);
    fclose(yyin);
    return 0;
}
