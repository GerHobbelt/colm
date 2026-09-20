(*
 * @LANG: ocaml
 *
 * Host text with type variables, primes inside identifiers and the char
 * literal escapes, which the ocaml output grammar once took for strings that
 * ran to the next prime on the line, or for unpaired quotes.
 *)

let id (x : 'a) : 'a = x
let pair (x : 'a) (y : 'b) : 'a * 'b = ( x, y )
let x' = 'a' and x'' = '\n' and q = '\'' and d = '\065' and h = '\x42'

%% machine hosttext;
%% write data;

let run data =
	let cs = ref 0 in
	let p = ref 0 in
	let pe = ref (String.length data) in
	%%{
		main := 'a'+ @{ print_string "a\n" };
		write init;
		write exec;
	}%%
	if !cs >= hosttext_first_final then
		print_string "accept\n"
	else
		print_string "fail\n"

let () =
	run "aaa";
	let ( c, nl ) = pair x' x'' in
	print_char c; print_char q; print_char d; print_char h; print_char nl;
	print_string (id "id\n")

##### OUTPUT #####
a
a
a
accept
a'AB
id
