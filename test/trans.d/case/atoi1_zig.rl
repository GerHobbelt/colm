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

var neg: i32 = 0;
var value: i32 = 0;

%%{
	machine atoi;

	action begin {neg = 0;
value = 0;
}

	action see_neg {neg = 1;
}

	action add_digit {value = value * 10 + @as( i32, @intCast( fc - 48 ) )
;
}

	action finish {if ( neg != 0 )
{
	value = -1 * value;

}
}
	action print {_out( "{d}", .{ value } );
_out( "{s}", .{ "\n" } );
}

	atoi = (
		('-'@see_neg | '+')? (digit @add_digit)+
	) >begin %finish;

	main := atoi '\n' @print;
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
value = 0;
neg = 0;

	%% write init;
	%% write exec;

	if ( cs >= atoi_first_final ) {
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

	m( "1\n" );
	m( "12\n" );
	m( "222222\n" );
	m( "+2123\n" );
	m( "213 3213\n" );
	m( "-12321\n" );
	m( "--123\n" );
	m( "-99\n" );
	m( " -3000\n" );
}

