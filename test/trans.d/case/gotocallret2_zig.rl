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
var val: i32 = 0;

%%{
	machine GotoCallRet;

	sp = ' ';

	handle := any @{_out( "{s}", .{ "handle " } );
fhold;if ( val == 1 )
{
	fnext *fentry(one);
}
if ( val == 2 )
{
	fnext *fentry(two);
}
if ( val == 3 )
{
	fnext main;
}
};

	one := |*
		'{' => {_out( "{s}", .{ "{ " } );
fcall *fentry(one);};
		"[" => {_out( "{s}", .{ "[ " } );
fcall *fentry(two);};
		"}" sp* => {_out( "{s}", .{ "} " } );
fret;};
		[a-z]+ => {_out( "{s}", .{ "word " } );
val = 1;
fgoto *fentry(handle);};
		' ' => {_out( "{s}", .{ "space " } );
};
	*|;

	two := |*
		'{' => {_out( "{s}", .{ "{ " } );
fcall *fentry(one);};
		"[" => {_out( "{s}", .{ "[ " } );
fcall *fentry(two);};
		']' sp* => {_out( "{s}", .{ "] " } );
fret;};
		[a-z]+ => {_out( "{s}", .{ "word " } );
val = 2;
fgoto *fentry(handle);};
		' ' => {_out( "{s}", .{ "space " } );
};
	*|;

	main := |* 
		'{' => {_out( "{s}", .{ "{ " } );
fcall one;};
		"[" => {_out( "{s}", .{ "[ " } );
fcall two;};
		[a-z]+ => {_out( "{s}", .{ "word " } );
val = 3;
fgoto handle;};
		[a-z] ' foil' => {_out( "{s}", .{ "this is the foil" } );
};
		' ' => {_out( "{s}", .{ "space " } );
};
		'\n';
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

	if ( cs >= GotoCallRet_first_final ) {
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

	m( "{a{b[c d]d}c}\n" );
	m( "[a{b[c d]d}c}\n" );
	m( "[a[b]c]d{ef{g{h}i}j}l\n" );
	m( "{{[]}}\n" );
	m( "a b c\n" );
	m( "{a b c}\n" );
	m( "[a b c]\n" );
	m( "{]\n" );
	m( "{{}\n" );
	m( "[[[[[[]]]]]]\n" );
	m( "[[[[[[]]}]]]\n" );
}

