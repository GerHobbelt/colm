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

	# Warning: changing the patterns or the input string will affect the
	# coverage of the scanner action types.
	main := |*
		'a' => {_out( "{s}", .{ "pat1\n" } );
};
		'b' => {_out( "{s}", .{ "pat2\n" } );
};
        [ab] any*  => {_out( "{s}", .{ "pat3\n" } );
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

	m( "ab89" );
}

