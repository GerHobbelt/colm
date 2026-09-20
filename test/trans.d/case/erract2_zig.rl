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




%%{
	machine erract;

	action err_start {_out( "{s}", .{ "err_start\n" } );
}
	action err_all {_out( "{s}", .{ "err_all\n" } );
}
	action err_middle {_out( "{s}", .{ "err_middle\n" } );
}
	action err_out {_out( "{s}", .{ "err_out\n" } );
}

	action eof_start {_out( "{s}", .{ "eof_start\n" } );
}
	action eof_all {_out( "{s}", .{ "eof_all\n" } );
}
	action eof_middle {_out( "{s}", .{ "eof_middle\n" } );
}
	action eof_out {_out( "{s}", .{ "eof_out\n" } );
}

	main := ( 'hello' 
			>err err_start $err err_all <>err err_middle %err err_out
			>eof eof_start $eof eof_all <>eof eof_middle %eof eof_out
		) '\n';
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

	if ( cs >= erract_first_final ) {
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

	m( "" );
	m( "h" );
	m( "x" );
	m( "he" );
	m( "hx" );
	m( "hel" );
	m( "hex" );
	m( "hell" );
	m( "helx" );
	m( "hello" );
	m( "hellx" );
	m( "hello\n" );
	m( "hellox" );
}

