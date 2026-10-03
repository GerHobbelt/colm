#!/bin/sh
#
# Checks that libcolm defines every function the runtime headers declare. A
# declaration nothing defines compiles, but a program that calls it doesn't
# link.
#
# usage: check-decls.sh <libcolm.la> <compile command> <header>...
#
# GCC's -aux-info lists the functions the headers declare and nm lists the
# ones the library defines. Compilers without -aux-info skip the check.
#

la=$1
compile=$2
shift 2

tmp=`mktemp -d "${TMPDIR:-/tmp}/check-decls.XXXXXX"` || exit 1
trap 'rm -rf "$tmp"' 0

echo 'void check_decls_probe( void );' > "$tmp/probe.c"
$compile -fsyntax-only -aux-info "$tmp/probe.txt" "$tmp/probe.c" >/dev/null 2>&1
if ! grep -q check_decls_probe "$tmp/probe.txt" 2>/dev/null; then
	echo "check-decls: no -aux-info in the compiler, skipping"
	exit 0
fi

for h in "$@"; do
	echo "#include <colm/$h>"
done > "$tmp/headers.c"

$compile -fsyntax-only -aux-info "$tmp/aux.txt" "$tmp/headers.c" || exit 1

# The libtool library's static archive and shared object, whichever were built.
# A library nm can't read, or one it finds no symbols in, such as a stripped
# shared object, fails the check instead of passing it unchecked.
libs=`sed -n "s/^old_library='\(..*\)'$/\1/p; s/^dlname='\(..*\)'$/\1/p" "$la"`
test -n "$libs" || { echo "check-decls: no library in $la"; exit 1; }
for l in $libs; do
	nm "`dirname "$la"`/.libs/$l" > "$tmp/nm.txt" || exit 1
	awk 'NF == 3 && $2 ~ /^[TDBRWV]$/ { print $3 }' "$tmp/nm.txt" >> "$tmp/defs.txt"
done
test -s "$tmp/defs.txt" || { echo "check-decls: nm lists no symbols for $la"; exit 1; }

# Lines look like: /* path/colm/tree.h:222:NC */ extern void f (tree_t *);
# Mach-O names carry a leading underscore, so accept either form. No matching
# lines at all means the pattern has stopped matching, which fails too.
awk '
	FILENAME == ARGV[1] { def[$1] = 1; next }
	/^\/\* .*colm\/[a-z_]*\.h:[0-9]*:[NO]C \*\/ extern / {
		decls += 1
		loc = $2
		sub( /^.*colm\//, "colm/", loc )
		sub( /:[NO]C$/, "", loc )
		decl = $0
		sub( /^.*\*\/ extern /, "", decl )
		sub( / \(.*$/, "", decl )
		n = split( decl, words, /[ *]+/ )
		name = words[n]
		if ( !( name in def ) && !( ( "_" name ) in def ) ) {
			print loc ": " name " is declared but libcolm does not define it"
			bad = 1
		}
	}
	END {
		if ( decls == 0 ) {
			print "check-decls: found no function declarations in the headers"
			bad = 1
		}
		exit bad
	}
' "$tmp/defs.txt" "$tmp/aux.txt"
