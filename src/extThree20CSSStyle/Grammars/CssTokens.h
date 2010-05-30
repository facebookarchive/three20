
#include <stdio.h>

typedef enum {
  FIRST_TOKEN = 0x100,
  STRING = FIRST_TOKEN,
  IDENT,
  HASH,
  EMS,
  EXS,
  LENGTH,
  ANGLE,
  TIME,
  FREQ,
  DIMEN,
  PERCENTAGE,
  NUMBER,
  URI,
  FUNCTION,
  UNICODERANGE,
  UNKNOWN,

} ParserCodes;

extern const char* names[];

#ifndef YY_TYPEDEF_YY_SCANNER_T
#define YY_TYPEDEF_YY_SCANNER_T
typedef void* yyscan_t;
#endif

extern FILE *cssin;

int csslex(void);
int cssConsume(char* text, int token);
