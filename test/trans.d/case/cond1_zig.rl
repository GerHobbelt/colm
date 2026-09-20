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

var i: i32 = 0;
var j: i32 = 0;
var k: i32 = 0;

%%{
	machine foo;

	action c1 {i != 0}
	action c2 {j != 0}
	action c3 {k != 0}
	action one {_out( "{s}", .{ "  one\n" } );
}
	action two {_out( "{s}", .{ "  two\n" } );
}
	action three {_out( "{s}", .{ "  three\n" } );
}

	action seti {if ( fc == 48 )
{
	i = 0;

}
else {
	i = 1;

}
}
	action setj {if ( fc == 48 )
{
	j = 0;

}
else {
	j = 1;

}
}
	action setk {if ( fc == 48 )
{
	k = 0;

}
else {
	k = 1;

}
}

	action break {fnbreak;}

	one = 'a' 'b' when c1 'c' @one;
	two = 'a'* 'b' when c2 'c' @two;
	three = 'a'+ 'b' when c3 'c' @three;

	main := 
		[01] @seti
		[01] @setj
		[01] @setk
		( one | two | three ) '\n' @break;
	
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

	if ( cs >= foo_first_final ) {
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

	m( "000abc\n" );
	m( "100abc\n" );
	m( "010abc\n" );
	m( "110abc\n" );
	m( "001abc\n" );
	m( "101abc\n" );
	m( "011abc\n" );
	m( "111abc\n" );
}

