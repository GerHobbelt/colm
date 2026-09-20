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
	machine state_act;

	action a1 {_out( "{s}", .{ "a1\n" } );
}
	action a2 {_out( "{s}", .{ "a2\n" } );
}
	action b1 {_out( "{s}", .{ "b1\n" } );
}
	action b2 {_out( "{s}", .{ "b2\n" } );
}
	action c1 {_out( "{s}", .{ "c1\n" } );
}
	action c2 {_out( "{s}", .{ "c2\n" } );
}
	action next_again {fnext again;}

	hi = 'hi';
	line = again: 
			hi 
				>to b1 
				>from b2 
			'\n' 
				>to c1 
				>from c2 
				@next_again;
		 
	main := line*
			>to a1 
			>from a2;
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

	if ( cs >= state_act_first_final ) {
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

	m( "hi\nhi\n" );
}

