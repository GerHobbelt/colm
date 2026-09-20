//
// @LANG: zig
// @GENERATED: true
//

const std = @import("std");

// The test harness diffs stdout; std.debug.print is stderr only.
var _thr: std.Io.Threaded = .init_single_threaded;
var _obuf: [4096]u8 = undefined;
var _ow: *std.Io.Writer = undefined;

fn _out( comptime fmt: []const u8, args: anytype ) void
{
	_ow.print( fmt, args ) catch {};
}

var ts: i32 = 0;
var te: i32 = 0;
var act: i32 = 0;
var token: i32 = 0;

%%{
	machine scanner;

	action comment {token = 242;
_out( "{s}", .{ "<" } );
_out( "{d}", .{ token } );
_out( "{s}", .{ "> " } );
_out( "{s}", .{ data[@intCast(ts)..@intCast(te)] } );
_out( "{s}", .{ "\n" } );
}


	main := |*

	# Single and double literals.
	( 'L'? "'" ( [^'\\\n] | '\\' any )* "'" ) 
		=> {token = 193;
_out( "{s}", .{ "<" } );
_out( "{d}", .{ token } );
_out( "{s}", .{ "> " } );
_out( "{s}", .{ data[@intCast(ts)..@intCast(te)] } );
_out( "{s}", .{ "\n" } );
};
	( 'L'? '"' ( [^"\\\n] | '\\' any )* '"' ) 
		=> {token = 192;
_out( "{s}", .{ "<" } );
_out( "{d}", .{ token } );
_out( "{s}", .{ "> " } );
_out( "{s}", .{ data[@intCast(ts)..@intCast(te)] } );
_out( "{s}", .{ "\n" } );
};

	# Identifiers
	( [a-zA-Z_] [a-zA-Z0-9_]* ) 
		=>{token = 195;
_out( "{s}", .{ "<" } );
_out( "{d}", .{ token } );
_out( "{s}", .{ "> " } );
_out( "{s}", .{ data[@intCast(ts)..@intCast(te)] } );
_out( "{s}", .{ "\n" } );
};

	# Floating literals.
	fract_const = digit* '.' digit+ | digit+ '.';
	exponent = [eE] [+\-]? digit+;
	float_suffix = [flFL];

	( fract_const exponent? float_suffix? |
		digit+ exponent float_suffix? ) 
		=> {token = 194;
_out( "{s}", .{ "<" } );
_out( "{d}", .{ token } );
_out( "{s}", .{ "> " } );
_out( "{s}", .{ data[@intCast(ts)..@intCast(te)] } );
_out( "{s}", .{ "\n" } );
};
	
	# Integer decimal. Leading part buffered by float.
	( ( '0' | [1-9] [0-9]* ) [ulUL]? ) 
		=> {token = 218;
_out( "{s}", .{ "<" } );
_out( "{d}", .{ token } );
_out( "{s}", .{ "> " } );
_out( "{s}", .{ data[@intCast(ts)..@intCast(te)] } );
_out( "{s}", .{ "\n" } );
};

	# Integer octal. Leading part buffered by float.
	( '0' [0-9]+ [ulUL]? ) 
		=> {token = 219;
_out( "{s}", .{ "<" } );
_out( "{d}", .{ token } );
_out( "{s}", .{ "> " } );
_out( "{s}", .{ data[@intCast(ts)..@intCast(te)] } );
_out( "{s}", .{ "\n" } );
};

	# Integer hex. Leading 0 buffered by float.
	( '0' ( 'x' [0-9a-fA-F]+ [ulUL]? ) ) 
		=> {token = 220;
_out( "{s}", .{ "<" } );
_out( "{d}", .{ token } );
_out( "{s}", .{ "> " } );
_out( "{s}", .{ data[@intCast(ts)..@intCast(te)] } );
_out( "{s}", .{ "\n" } );
};

	# Only buffer the second item, first buffered by symbol.
	'::' => {token = 197;
_out( "{s}", .{ "<" } );
_out( "{d}", .{ token } );
_out( "{s}", .{ "> " } );
_out( "{s}", .{ data[@intCast(ts)..@intCast(te)] } );
_out( "{s}", .{ "\n" } );
};
	'==' => {token = 223;
_out( "{s}", .{ "<" } );
_out( "{d}", .{ token } );
_out( "{s}", .{ "> " } );
_out( "{s}", .{ data[@intCast(ts)..@intCast(te)] } );
_out( "{s}", .{ "\n" } );
};
	'!=' => {token = 224;
_out( "{s}", .{ "<" } );
_out( "{d}", .{ token } );
_out( "{s}", .{ "> " } );
_out( "{s}", .{ data[@intCast(ts)..@intCast(te)] } );
_out( "{s}", .{ "\n" } );
};
	'&&' => {token = 225;
_out( "{s}", .{ "<" } );
_out( "{d}", .{ token } );
_out( "{s}", .{ "> " } );
_out( "{s}", .{ data[@intCast(ts)..@intCast(te)] } );
_out( "{s}", .{ "\n" } );
};
	'||' => {token = 226;
_out( "{s}", .{ "<" } );
_out( "{d}", .{ token } );
_out( "{s}", .{ "> " } );
_out( "{s}", .{ data[@intCast(ts)..@intCast(te)] } );
_out( "{s}", .{ "\n" } );
};
	'*=' => {token = 227;
_out( "{s}", .{ "<" } );
_out( "{d}", .{ token } );
_out( "{s}", .{ "> " } );
_out( "{s}", .{ data[@intCast(ts)..@intCast(te)] } );
_out( "{s}", .{ "\n" } );
};
	'/=' => {token = 228;
_out( "{s}", .{ "<" } );
_out( "{d}", .{ token } );
_out( "{s}", .{ "> " } );
_out( "{s}", .{ data[@intCast(ts)..@intCast(te)] } );
_out( "{s}", .{ "\n" } );
};
	'%=' => {token = 229;
_out( "{s}", .{ "<" } );
_out( "{d}", .{ token } );
_out( "{s}", .{ "> " } );
_out( "{s}", .{ data[@intCast(ts)..@intCast(te)] } );
_out( "{s}", .{ "\n" } );
};
	'+=' => {token = 230;
_out( "{s}", .{ "<" } );
_out( "{d}", .{ token } );
_out( "{s}", .{ "> " } );
_out( "{s}", .{ data[@intCast(ts)..@intCast(te)] } );
_out( "{s}", .{ "\n" } );
};
	'-=' => {token = 231;
_out( "{s}", .{ "<" } );
_out( "{d}", .{ token } );
_out( "{s}", .{ "> " } );
_out( "{s}", .{ data[@intCast(ts)..@intCast(te)] } );
_out( "{s}", .{ "\n" } );
};
	'&=' => {token = 232;
_out( "{s}", .{ "<" } );
_out( "{d}", .{ token } );
_out( "{s}", .{ "> " } );
_out( "{s}", .{ data[@intCast(ts)..@intCast(te)] } );
_out( "{s}", .{ "\n" } );
};
	'^=' => {token = 233;
_out( "{s}", .{ "<" } );
_out( "{d}", .{ token } );
_out( "{s}", .{ "> " } );
_out( "{s}", .{ data[@intCast(ts)..@intCast(te)] } );
_out( "{s}", .{ "\n" } );
};
	'|=' => {token = 234;
_out( "{s}", .{ "<" } );
_out( "{d}", .{ token } );
_out( "{s}", .{ "> " } );
_out( "{s}", .{ data[@intCast(ts)..@intCast(te)] } );
_out( "{s}", .{ "\n" } );
};
	'++' => {token = 212;
_out( "{s}", .{ "<" } );
_out( "{d}", .{ token } );
_out( "{s}", .{ "> " } );
_out( "{s}", .{ data[@intCast(ts)..@intCast(te)] } );
_out( "{s}", .{ "\n" } );
};
	'--' => {token = 213;
_out( "{s}", .{ "<" } );
_out( "{d}", .{ token } );
_out( "{s}", .{ "> " } );
_out( "{s}", .{ data[@intCast(ts)..@intCast(te)] } );
_out( "{s}", .{ "\n" } );
};
	'->' => {token = 211;
_out( "{s}", .{ "<" } );
_out( "{d}", .{ token } );
_out( "{s}", .{ "> " } );
_out( "{s}", .{ data[@intCast(ts)..@intCast(te)] } );
_out( "{s}", .{ "\n" } );
};
	'->*' => {token = 214;
_out( "{s}", .{ "<" } );
_out( "{d}", .{ token } );
_out( "{s}", .{ "> " } );
_out( "{s}", .{ data[@intCast(ts)..@intCast(te)] } );
_out( "{s}", .{ "\n" } );
};
	'.*' => {token = 215;
_out( "{s}", .{ "<" } );
_out( "{d}", .{ token } );
_out( "{s}", .{ "> " } );
_out( "{s}", .{ data[@intCast(ts)..@intCast(te)] } );
_out( "{s}", .{ "\n" } );
};

	# Three char compounds, first item already buffered.
	'...' => {token = 240;
_out( "{s}", .{ "<" } );
_out( "{d}", .{ token } );
_out( "{s}", .{ "> " } );
_out( "{s}", .{ data[@intCast(ts)..@intCast(te)] } );
_out( "{s}", .{ "\n" } );
};

	# Single char symbols.
	( punct - [_"'] ) => {token = @as( i32, @intCast( data[@intCast(ts)] ) )
;
_out( "{s}", .{ "<" } );
_out( "{d}", .{ token } );
_out( "{s}", .{ "> " } );
_out( "{s}", .{ data[@intCast(ts)..@intCast(te)] } );
_out( "{s}", .{ "\n" } );
};

	# Comments and whitespace.
	'/!' ( any* $0 '!/' @1 ) => comment;
	'//' ( any* $0 '\n' @1 ) => comment;
	( any - 33..126 )+ => {token = 241;
_out( "{s}", .{ "<" } );
_out( "{d}", .{ token } );
_out( "{s}", .{ "> " } );
_out( "{s}", .{ data[@intCast(ts)..@intCast(te)] } );
_out( "{s}", .{ "\n" } );
};
	*|;
}%%



%% write data;

fn m( s: []const u8 ) void
{
	const data = s;
	var p: i32 = 0;
	var pe: i32 = @intCast( s.len );
	var eof: i32 = @intCast( s.len );
	var cs: i32 = 0;
	var buffer: [1024]u8 = undefined;
	var blen: usize = 0;

	_ = &data; _ = &p; _ = &pe; _ = &eof; _ = &cs;
	_ = &buffer; _ = &blen;

	%% write init;
	%% write exec;

	if ( cs >= scanner_first_final ) {
		_out( "ACCEPT\n", .{} );
	}
	else {
		_out( "FAIL\n", .{} );
	}
}

pub fn main() void
{
	var _w = std.Io.File.stdout().writer( _thr.io(), &_obuf );
	_ow = &_w.interface;
	defer _w.interface.flush() catch {};

	m( "\"\\\"hi\" /!\n!/\n44 .44\n44. 44\n44 . 44\n44.44\n_hithere22" );
	m( "'\\''\"\\n\\d'\\\"\"\nhi\n99\n.99\n99e-4\n->*\n||\n0x98\n0x\n//\n/! * !/" );
	m( "'\n'\n" );
}

