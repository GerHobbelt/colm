# @LANG: julia
#
# Host text with the adjoint, the left division operator, a command literal, a
# triple-quoted string and unicode names and operators, which the julia output
# grammar once took for unpaired quotes or rejected outright.

A = [1 2; 3 4]
B = A' * A
c = A \ [4; 10]
cmd = `echo hi`
s = """it's a "quoted" {string}"""
α = 1

%%{
	machine hosttext;
	main := 'a'+ @{ println( "a" ) };
}%%

%% write data;

function test( data_string::AbstractString )
	data = Vector{UInt8}( data_string )
	p = 0
	pe = length(data)
	eof = length(data)
	cs = 0
	%% write init;
	%% write exec;
	if cs >= hosttext_first_final
		println( "accept" )
	end
end

test( "aaa" )
println( B[1,1] )
println( round( Int, c[1] ) )
println( typeof( cmd ) )
println( s )
println( α ≤ 2 )

######## OUTPUT #######
a
a
a
accept
10
2
Cmd
it's a "quoted" {string}
true
