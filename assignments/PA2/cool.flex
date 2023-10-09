/*
 *  The scanner definition for COOL.
 */

/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 * to the code in the file.  Don't remove anything that was here initially
 */
%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>

/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex

/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;

/*
 *  Add Your own definitions here
 */
int comment = 0;
%}

/*
 * 关键字
 */

DARROW          =>
CLASS           [c|C][l|L][a|A][s|S][s|S]
ELSE            [e|E][l|L][s|S][e|E]
FI              [f|F][i|I]
IF              [i|I][f|F]
IN              [i|I][n|N]
INHERITS        [i|I][n|N][h|H][e|E][r|R][i|I][t|T][s|S]
LET             [l|L][e|E][t|T]
LOOP            [l|L][o|O][o|O][p|P]
POOL            [p|P][o|O][o|O][l|L]
THEN            [t|T][h|H][e|E][n|N]
WHILE           [w|W][h|H][i|I][l|L][e|E]
CASE            [c|C][a|A][s|S][e|E]
ESAC            [e|E][s|S][a|A][c|C]
OF              [o|O][f|F]
NEW             [n|N][e|E][w|W]
ISVOID          [i|I][s|S][v|V][o|O][i|I][d|D]
ASSIGN          <-
NOT             [n|N][o|O][t|T]
LE              <=

/*
 * 合法字符
 */

CHAR            [\.\:\{\}\(\)\;\,\~\@\+\-\*\/\=\<]

/*
 * 标识符
 */

INT_CONST       [0-9][0-9]*
BOOL_CONST      [t][r|R][u|U][e|E]|[f][a|A][l|L][s|S][e|E]
TYPEID          [A-Z][a-zA-Z0-9_]*
OBJECTID        [a-z][a-zA-Z0-9_]*

/*
 * 空格
 */

WHITE_SPACE     [ \t\r\f\v]+

%x COMMENT

%x STRING
%x STRING_ESCAPE
/* COMMENT */

/* ERROR
LET_STMT */

%%


 /*
  * 关键词直接输出
  */

{DARROW}		        { return (DARROW); }
{CLASS}			        { return (CLASS); }
{ELSE}			        { return (ELSE); }
{FI}			        { return (FI); }
{IF}			        { return (IF); }
{IN}			        { return (IN); }
{INHERITS}		        { return (INHERITS); }
{LET}			        { return (LET); }
{LOOP}			        { return (LOOP); }
{POOL}			        { return (POOL); }
{THEN}			        { return (THEN); }
{WHILE}			        { return (WHILE); }
{CASE}			        { return (CASE); }
{ESAC}			        { return (ESAC); }
{OF}			        { return (OF); }
{NEW}			        { return (NEW); }
{ISVOID}		        { return (ISVOID); }
{NOT}			        { return (NOT); }
{ASSIGN}		        { return (ASSIGN); }
{LE}			        { return (LE); }

{CHAR}                  { return (yytext[0]); }


 /*
  * 换行符
  */

\n                      { curr_lineno++;}

 /*
  *  Nested comments
  */
\(\*                    {
                            comment += 1; // 遇到开放注释
                            BEGIN(COMMENT); // 切换到COMMENT状态
                        }

<COMMENT>\*\)           {
                            comment -= 1; // 遇到关闭注释
                            if (comment == 0) BEGIN(INITIAL); // 切换回INITIAL状态
                        }

<COMMENT>[\n\r]         { curr_lineno++; }

<COMMENT><<EOF>>        {
                            BEGIN(INITIAL);
                            cool_yylval.error_msg = "EOF in comment";
                            return (ERROR);
                        }

<COMMENT>.              { }

 /*
  * 非 COMMENT 情况遇到另一半注释
  */

\*\)                    {
                            cool_yylval.error_msg = "Unmatched *)";
                            return (ERROR);
                        }

 /*
  * 单行注释
  */

--.*$                   { }


 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */


{INT_CONST}             {
                            cool_yylval.symbol = inttable.add_string(yytext);
                            return (INT_CONST);
                        }

{BOOL_CONST}            {
                            cool_yylval.boolean = (yytext[0] == 't');
                            return (BOOL_CONST);
                        }

{TYPEID}                {
                            cool_yylval.symbol = idtable.add_string(yytext);
                            return (TYPEID);
                        }

{OBJECTID}              {
                            cool_yylval.symbol = idtable.add_string(yytext);
                            return (OBJECTID);
                        }

{WHITE_SPACE}           {
                            // 忽略空格
                        }


 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for
  *  \n \t \b \f, the result is c.
  *
  */
\"                      {
                            BEGIN(STRING);
                            string_buf_ptr = string_buf;
                        }

<STRING>\\              { BEGIN(STRING_ESCAPE); }

<STRING_ESCAPE>\\       {
                            *string_buf_ptr++ = '\\';
                            BEGIN(STRING);
                        }

<STRING_ESCAPE>n        {
                            *string_buf_ptr++ = '\n';
                            BEGIN(STRING);
                        }

<STRING_ESCAPE>b        {
                            *string_buf_ptr++ = '\b';
                            BEGIN(STRING);
                        }

<STRING_ESCAPE>t        {
                            *string_buf_ptr++ = '\t';
                            BEGIN(STRING);
                        }

<STRING_ESCAPE>f        {
                            *string_buf_ptr++ = '\f';
                            BEGIN(STRING);
                        }

<STRING_ESCAPE>.        {
                            *string_buf_ptr++ = yytext[0];
                            BEGIN(STRING);
                        }

<STRING_ESCAPE>\n       {
                            *string_buf_ptr++ = '\n';
                            BEGIN(STRING);
                        }

<STRING_ESCAPE>0        {
                            cool_yylval.error_msg = "String contains null character";
                            BEGIN(STRING);
                            return (ERROR);
                        }

<STRING_ESCAPE><<EOF>>  {
                            BEGIN(STRING);
                            cool_yylval.error_msg = "EOF in comment";
                            return (ERROR);
                        }

<STRING><<EOF>>         {
                            BEGIN(INITIAL);
                            cool_yylval.error_msg = "EOF in comment";
                            return (ERROR);
                        }

<STRING>[\r\n]          {
                            cool_yylval.error_msg = "Unterminated string constant";
                            BEGIN(INITIAL);
                            ++curr_lineno;
                            return (ERROR);
                        }

<STRING>\"              {
                            *string_buf_ptr = '\0';
                            cool_yylval.symbol = stringtable.add_string(string_buf);
                            BEGIN(INITIAL);
                            return (STR_CONST);
                        }

<STRING>.               { *string_buf_ptr++ = yytext[0]; }

.                       {
                            cool_yylval.error_msg = yytext;
                            return (ERROR);
                        }
%%
