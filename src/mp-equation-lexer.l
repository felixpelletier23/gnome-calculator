%option 8bit reentrant bison-locations
%option never-interactive
%option noyywrap noinput nounput
%option prefix="_mp_equation_"
%option extra-type="MPEquationParserState *"
%option outfile="mp-equation-lexer.c" header-file="mp-equation-lexer.h"

%{

/*  $Header: /cvs/gnome/gcalctool/gcalctool/ce_tokeniser.l,v 1.16 2006/12/15 15:27:37 richb Exp $
 *
 *  Copyright (C) 2004-2008 Sami Pietila
 *  Copyright (C) 2008-2009 Robert Ancell
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2, or (at your option)
 *  any later version.
 *           
 *  This program is distributed in the hope that it will be useful, but 
 *  WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU 
 *  General Public License for more details.
 *           
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
 *  02111-1307, USA.
 */

#include <stdlib.h>
#include <locale.h>
#include <string.h>
#include <sys/types.h>

#include "calctool.h"
#include "mp-equation.h"
#include "mp-equation-parser.h"

static int super_atoi(const char *data)
{
   int i, value = 0;
   const char *digits[11] = {"⁰", "¹", "²", "³", "⁴", "⁵", "⁶", "⁷", "⁸", "⁹", NULL};
   
   while(*data != '\0') {
      for(i = 0; digits[i] != NULL && strncmp(data, digits[i], strlen(digits[i])) != 0; i++);
      if(digits[i] == NULL)
         return 0;
      value = value * 10 + i;
      data += strlen(digits[i]);
   }
   
   return value;
}

static int sub_atoi(const char *data)
{
   int i, value = 0;
   const char *digits[11] = {"₀", "₁", "₂", "₃", "₄", "₅", "₆", "₇", "₈", "₉", NULL};

   while(*data != '\0') {
      for(i = 0; digits[i] != NULL && strncmp(data, digits[i], strlen(digits[i])) != 0; i++);
      if(digits[i] == NULL)
         return 0;
      data += strlen(digits[i]);
      value = value * 10 + i;
   }
   
   return value;
}
%}

DECIMAL	     "."|","
BIN          [0-1]
OCT          [0-7]
DEC          [0-9]
HEX          [0-9]|[A-F]|[a-f]
EXP          "e"|"e+"|"e-"|"E"|"E+"|"E-"
SUPER_DIGITS "⁰"|"¹"|"²"|"³"|"⁴"|"⁵"|"⁶"|"⁷"|"⁸"|"⁹"
SUB_DIGITS   "₀"|"₁"|"₂"|"₃"|"₄"|"₅"|"₆"|"₇"|"₈"|"₉"
FRACTION     "½"|"⅓"|"⅔"|"¼"|"¾"|"⅕"|"⅖"|"⅗"|"⅘"|"⅙"|"⅚"|"⅛"|"⅜"|"⅝"|"⅞"

HEX_NUM {HEX}+|{HEX}*{DECIMAL}{HEX}+
DEC_NUM {DEC}+|{DEC}*{DECIMAL}{DEC}+|{FRACTION}|{DEC}{FRACTION}
OCT_NUM {OCT}+|{OCT}*{DECIMAL}{OCT}+
BIN_NUM {BIN}+|{BIN}*{DECIMAL}{BIN}+
SUP_NUM {SUPER_DIGITS}+
SUB_NUM {SUB_DIGITS}+

%%

"+"     {return tADD;}
"-"|"−" {return tSUBTRACT;}
"*"|"×" {return tMULTIPLY;}
"/"|"÷" {return tDIVIDE;}
"abs"|"Abs"|"ABS" {return tABS_FUNC;}
"|" {return tABS;}
"sin"|"Sin"|"SIN" {return tSIN;}
"cos"|"Cos"|"COS" {return tCOS;}
"tan"|"Tan"|"TAN" {return tTAN;}
"sin⁻¹"|"asin"|"Asin"|"ASIN" {return tASIN;}
"cos⁻¹"|"acos"|"Acos"|"ACOS" {return tACOS;}
"tan⁻¹"|"atan"|"Atan"|"ATAN" {return tATAN;}
"sinh"|"Sinh"|"SINH" {return tSINH;}
"cosh"|"Cosh"|"COSH" {return tCOSH;}
"tanh"|"Tanh"|"TANH" {return tTANH;}
"sinh⁻¹"|"asinh"|"Asinh"|"ASINH" {return tASINH;}
"cosh⁻¹"|"acosh"|"Acosh"|"ACOSH" {return tACOSH;}
"tanh⁻¹"|"atanh"|"Atanh"|"ATANH" {return tATANH;}
"∧"|"and"|"And"|"AND" {return tAND;}
"ans"|"Ans"|"ANS" {return tANS;}
"chs"|"Chs"|"CHS" {return tCHS;}
"clr"|"Clr"|"CLR" {return tCLR;}
"eng"|"Eng"|"ENG" {return tEXP;}
"frac"|"Frac"|"FRAC" {return tFRAC;}
"int"|"Int"|"INT" {return tINT;}
"ln"|"Ln"|"LN" {return tLN;}
"log"|"Log"|"LOG" {return tLOG;}
"mod"|"Mod"|"MOD" {return tMOD;}
"¬"|"~" {return tNOT;}
"∨"|"or"|"Or"|"OR" {return tOR;}
"π"|"pi"|"Pi"|"PI" {return tPI;}
"rand"|"Rand"|"RAND" {return tRAND;}
"rcl"|"Rcl"|"RCL" {return tRCL;}
"√"|"sqrt"|"Sqrt"|"SQRT" {return tROOT;}
"∛"|"cbrt"|"Cbrt"|"CBRT" {return tROOT3;}
"∜" {return tROOT4;}
"sto"|"Sto"|"STO" {return tSTO;}
"trunc"|"Trunc"|"TRUNC" {return tTRUNC;}
"ones" {return t1S;}
"twos" {return t2S;}
"xnor"|"Xnor"|"XNOR" {return tXNOR;}
"⊕"|"xor"|"Xor"|"XOR" {return tXOR;}

"R"{DEC}+ {
yylval->integer = atoi(yytext+1);  
return tREG;
}

{SUP_NUM} { yylval->integer = super_atoi(yytext); return tSUPNUM; }
{SUB_NUM} { yylval->integer = sub_atoi(yytext); return tSUBNUM; }

{DEC_NUM}{EXP}{DEC_NUM} {
if (_mp_equation_get_extra(yyscanner)->base == 16) REJECT;
if (strlen(yytext) > MAX_DIGITS) yyextra->error = -PARSER_ERR_TOO_LONG_NUMBER;
mp_set_from_string(yytext, _mp_equation_get_extra(yyscanner)->base, &yylval->int_t);
return tNUMBER;
}

{BIN_NUM} {
if (_mp_equation_get_extra(yyscanner)->base != 2) REJECT;
if (strlen(yytext) > MAX_DIGITS) yyextra->error = -PARSER_ERR_TOO_LONG_NUMBER;
mp_set_from_string(yytext, _mp_equation_get_extra(yyscanner)->base, &yylval->int_t);
return tNUMBER;
}

{OCT_NUM} {
if (_mp_equation_get_extra(yyscanner)->base != 8) REJECT;
if (strlen(yytext) > MAX_DIGITS) yyextra->error = -PARSER_ERR_TOO_LONG_NUMBER;
mp_set_from_string(yytext, _mp_equation_get_extra(yyscanner)->base, &yylval->int_t);
return tNUMBER;
}

{DEC_NUM} {
if (_mp_equation_get_extra(yyscanner)->base != 10) REJECT;
if (strlen(yytext) > MAX_DIGITS) yyextra->error = -PARSER_ERR_TOO_LONG_NUMBER;
mp_set_from_string(yytext, _mp_equation_get_extra(yyscanner)->base, &yylval->int_t);
return tNUMBER;
}

{HEX_NUM} {
if (_mp_equation_get_extra(yyscanner)->base != 16) REJECT;
if (strlen(yytext) > MAX_DIGITS) yyextra->error = -PARSER_ERR_TOO_LONG_NUMBER;
mp_set_from_string(yytext, _mp_equation_get_extra(yyscanner)->base, &yylval->int_t);
return tNUMBER;
}


[ \t\n]
.        {return *yytext; }

%% 