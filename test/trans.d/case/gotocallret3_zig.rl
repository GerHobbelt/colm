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

%%{
	machine gotocallret;

	# A reference to a state in an unused action caused a segfault in 5.8. */
	action unusedAction {fentry(garble_line);
}

	action err_garbling_line {_out( "{s}", .{ "error: garbling line\n" } );
}
	action goto_main {fnext main;}
	action recovery_failed {_out( "{s}", .{ "error: failed to recover\n" } );
}

	# Error machine, consumes to end of 
	# line, then starts the main line over.
	garble_line := ( (any-'\n')*'\n') 
		>err_garbling_line
		@goto_main
		$/recovery_failed;

	action hold_and_return {fhold;fnret;}

	# Look for a string of alphas or of digits, 
	# on anything else, hold the character and return.
	alp_comm := alpha+ $!hold_and_return;
	dig_comm := digit+ $!hold_and_return;

	# Choose which to machine to call into based on the command.
	action comm_arg {if ( comm >= 97 )
{
	fncall alp_comm;
}
else {
	fncall dig_comm;
}
}

	# Specifies command string. Note that the arg is left out.
	command = (
		[a-z0-9] @{comm = fc;
} ' ' @comm_arg @{_out( "{s}", .{ "prints\n" } );
} '\n'
	) @{_out( "{s}", .{ "correct command\n" } );
};

	# Any number of commands. If there is an 
	# error anywhere, garble the line.
	main := command* $!{fhold;fnext garble_line;}; 
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

	if ( cs >= gotocallret_first_final ) {
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

	m( "lkajsdf\n" );
	m( "2134\n" );
	m( "(\n" );
	m( "\n" );
	m( "*234234()0909 092 -234aslkf09`1 11\n" );
	m( "1\n" );
	m( "909\n" );
	m( "1 a\n" );
	m( "11 1\n" );
	m( "a 1\n" );
	m( "aa a\n" );
	m( "1 1\n" );
	m( "1 123456\n" );
	m( "a a\n" );
	m( "a abcdef\n" );
	m( "h" );
	m( "a aa1" );
}

