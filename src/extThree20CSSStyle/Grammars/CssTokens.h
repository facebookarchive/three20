
#include <stdio.h>

typedef enum {
  CSSFIRST_TOKEN = 0x100,
  CSSSTRING = CSSFIRST_TOKEN,
  CSSIDENT,
  CSSHASH,
  CSSEMS,
  CSSEXS,
  CSSLENGTH,
  CSSANGLE,
  CSSTIME,
  CSSFREQ,
  CSSDIMEN,
  CSSPERCENTAGE,
  CSSNUMBER,
  CSSURI,
  CSSFUNCTION,
  CSSUNICODERANGE,
  CSSUNKNOWN,

} CssParserCodes;

extern const char* cssnames[];

#ifndef YY_TYPEDEF_YY_SCANNER_T
#define YY_TYPEDEF_YY_SCANNER_T
typedef void* yyscan_t;
#endif

extern FILE *cssin;

int csslex(void);
int cssConsume(char* text, int token);
