/*
 * Copyright 2001-2018 Adrian Thurston <thurston@colm.net>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to
 * deal in the Software without restriction, including without limitation the
 * rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 * sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#include "inputdata.h"
#include "nragel.h"

extern struct colm_sections rlparseZig;
extern struct colm_sections rlhcZig;

/*
 * Zig
 */

const char *defaultOutFnZig( const char *inputFileName )
{
	return fileNameFromStem( inputFileName, ".zig" );
}

HostType hostTypesZig[] =
{
	{ "u8",  0, "uint8",  false, true, false, 0, 0,                  U8BIT_MIN,  U8BIT_MAX,  1 },
	{ "i8",  0, "int8",   true,  true, false, S8BIT_MIN,  S8BIT_MAX,  0, 0,                  1 },
	{ "u16", 0, "uint16", false, true, false, 0, 0,                  U16BIT_MIN, U16BIT_MAX, 2 },
	{ "i16", 0, "int16",  true,  true, false, S16BIT_MIN, S16BIT_MAX, 0, 0,                  2 },
	{ "u32", 0, "uint32", false, true, false, 0, 0,                  U32BIT_MIN, U32BIT_MAX, 4 },
	{ "i32", 0, "int32",  true,  true, false, S32BIT_MIN, S32BIT_MAX, 0, 0,                  4 },
	{ "u64", 0, "uint64", false, true, false, 0, 0,                  U64BIT_MIN, U64BIT_MAX, 8 },
	{ "i64", 0, "int64",  true,  true, false, S64BIT_MIN, S64BIT_MAX, 0, 0,                  8 },
};

/* Zig uses labeled switch for goto emulation. Supports -G0/-G1/-G2 styles. */
const HostLang hostLangZig =
{
	hostTypesZig,
	8,
	0,
	false,
	false,    /* loopLabels */
	Translated,
	GotoFeature,
	&makeCodeGen,
	&defaultOutFnZig,
	&genLineDirectiveTrans
};


int main( int argc, const char **argv )
{
	InputData id( &hostLangZig, &rlparseZig, &rlhcZig );
	return id.rlhcMain( argc, argv );
}
