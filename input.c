#include <stdio.h>
#define MAX 100

int main() {
    int a = 10;
    float b = 3.14;
    char c = 'x';

    double d = 1.2e10;
    int hex = 0x1A;
    int oct = 077;

    char newline = '\n';
    char tab = '\t';

    printf("Hello World\n");
    printf("Value: %d\n", a);

    if (a == 10 && b >= 3.0) {
        a++;
    } else {
        a--;
    }

    a += 5;
    b *= 2;
    a = a << 2;
    a = a >> 1;

    // This is a single-line comment

    /*
       This is a multi-line comment
       spanning multiple lines
    */

    int invalid1 = 123abc;
    char invalid2 = 'ab;
    "unclosed string

    @ $ #

    return 0;
}
