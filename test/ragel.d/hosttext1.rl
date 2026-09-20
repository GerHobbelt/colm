/*
 * @LANG: c
 *
 * Host text with the characters the C output grammar once rejected: a
 * backslash continuation, an unpaired quote in a directive, a macro that holds
 * half of a brace pair, a form feed and a non-ASCII identifier.
 */

#include <stdio.h>

#define PRINT(s) \
	printf( "%s\n", s )

#define BEGIN {
#define END }

#if 0
#error can't happen
#endif

%%{
	machine hosttext;
	main := 'a'+ @{ PRINT( "a" ); };
}%%

%% write data;

int café( const char *data, int len )
BEGIN
	int cs;
	const char *p = data, *pe = data + len;
	%% write init;
	%% write exec;
	return cs >= hosttext_first_final;
END

int main()
{
	if ( café( "aaa", 3 ) )
		PRINT( "accept" );
	return 0;
}

##### OUTPUT #####
a
a
a
accept
