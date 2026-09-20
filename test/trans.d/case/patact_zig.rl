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

var comm: u8 = 0;
var top: i32 = 0;
var stack: [32]i32 = .{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
var ts: i32 = 0;
var te: i32 = 0;
var act: i32 = 0;
var value: i32 = 0;

%%{
	machine patact;

	other := |* 
		[a-z]+ => {_out( "{s}", .{ "word\n" } );
};
		[0-9]+ => {_out( "{s}", .{ "num\n" } );
};
		[\n ] => {_out( "{s}", .{ "space\n" } );
};
	*|;

	exec_test := |* 
		[a-z]+ => {_out( "{s}", .{ "word (w/lbh)\n" } );
fexec te-1;fgoto other;};
		[a-z]+ ' foil' => {_out( "{s}", .{ "word (c/lbh)\n" } );
};
		[\n ] => {_out( "{s}", .{ "space\n" } );
};
		'22' => {_out( "{s}", .{ "num (w/switch)\n" } );
};
		[0-9]+ => {_out( "{s}", .{ "num (w/switch)\n" } );
fexec te-1;fgoto other;};
		[0-9]+ ' foil' => {_out( "{s}", .{ "num (c/switch)\n" } );
};
		'!';# => { print_str "immdiate\n"; fgoto exec_test; };
	*|;

	semi := |* 
		';' => {_out( "{s}", .{ "in semi\n" } );
fgoto main;};
	*|;

	main := |* 
		[a-z]+ => {_out( "{s}", .{ "word (w/lbh)\n" } );
fhold;fgoto other;};
		[a-z]+ ' foil' => {_out( "{s}", .{ "word (c/lbh)\n" } );
};
		[\n ] => {_out( "{s}", .{ "space\n" } );
};
		'22' => {_out( "{s}", .{ "num (w/switch)\n" } );
};
		[0-9]+ => {_out( "{s}", .{ "num (w/switch)\n" } );
fhold;fgoto other;};
		[0-9]+ ' foil' => {_out( "{s}", .{ "num (c/switch)\n" } );
};
		';' => {_out( "{s}", .{ "going to semi\n" } );
fhold;fgoto semi;};
		'!' => {_out( "{s}", .{ "immdiate\n" } );
fgoto exec_test;};
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

	if ( cs >= patact_first_final ) {
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

	m( "abcd foix\n" );
	m( "abcd\nanother\n" );
	m( "123 foix\n" );
	m( "!abcd foix\n" );
	m( "!abcd\nanother\n" );
	m( "!123 foix\n" );
	m( ";" );
}

