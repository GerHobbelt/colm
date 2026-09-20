/*
 * @LANG: go
 *
 * Host text with a raw string that holds a brace and quotes, and a non-ASCII
 * identifier, which the go output grammar once rejected.
 */

package main
import "fmt"

var raw string = `a "raw" string with { in it`

%%{
	machine hosttext;
	main := 'a'+ @{ fmt.Println( "a" ) };
}%%

%% write data;

func café( data string ) {
	var cs int = 0
	var p int = 0
	var pe int = len(data)
	%% write init;
	%% write exec;
	if cs >= hosttext_first_final {
		fmt.Println( "accept" )
	}
}

func main() {
	café( "aaa" )
	fmt.Println( raw )
}

##### OUTPUT #####
a
a
a
accept
a "raw" string with { in it
