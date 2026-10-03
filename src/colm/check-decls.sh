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
libs=`sed -n "s/^old_library='\(..*\)'$/\1/p; s/^dlname='\(..*\)'$/\1/p" "$la"`
test -n "$libs" || { echo "check-decls: no library in $la"; exit 1; }
for l in $libs; do
	nm "`dirname "$la"`/.libs/$l" || exit 1
done | awk 'NF == 3 && $2 ~ /^[TDBRWV]$/ { print $3 }' > "$tmp/defs.txt"

# Lines look like: /* path/colm/tree.h:222:NC */ extern void f (tree_t *);
# Mach-O names carry a leading underscore, so accept either form.
awk -v prog=check-decls '
	NR == FNR { def[$1] = 1; next }
	/^\/\* .*colm\/[a-z_]*\.h:[0-9]*:[NO]C \*\/ extern / {
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
	END { exit bad }
' "$tmp/defs.txt" "$tmp/aux.txt"
