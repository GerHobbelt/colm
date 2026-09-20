// -*-zig-*-
//
// Convert a string to an integer.
//
// To compile:
//
//   ragel-zig -T0 -o atoi.zig atoi.rl
//   zig build-exe atoi.zig
//   ./atoi
//
// Zig has no goto, but ragel-zig lowers the goto backends onto a labeled
// switch, so the -G0/-G1/-G2 styles work here too:
//
//   ragel-zig -G2 -o atoi.zig atoi.rl
//
// To show a diagram of your state machine:
//
//   ragel-zig -V -p -o atoi.dot atoi.rl
//   xdot atoi.dot
//

const std = @import("std");

%%{
    machine atoi;
    write data;
}%%

pub fn atoi(data: []const u8) i64 {
    var cs: i32 = 0;
    var p: i32 = 0;
    var pe: i32 = @intCast(data.len);
    var neg: bool = false;
    var val: i64 = 0;
    _ = &cs;
    _ = &p;
    _ = &pe;

    %%{
        action see_neg   { neg = true; }
        action add_digit { val = val * 10 + (@as(i64, fc) - '0'); }

        main :=
            ( '-'@see_neg | '+' )? ( digit @add_digit )+
            '\n'?
            ;

        write init;
        write exec;
    }%%

    if (neg) {
        val = -1 * val;
    }

    if (cs < atoi_first_final) {
        std.debug.print("atoi: there was an error: {d} < {d}\n", .{ cs, atoi_first_final });
    }

    return val;
}

//////////////////////////////////////////////////////////////////////

const AtoiTest = struct {
    s: []const u8,
    v: i64,
};

const atoi_tests = [_]AtoiTest{
    .{ .s = "7", .v = 7 },
    .{ .s = "666", .v = 666 },
    .{ .s = "-666", .v = -666 },
    .{ .s = "+666", .v = 666 },
    .{ .s = "1234567890", .v = 1234567890 },
    .{ .s = "+1234567890\n", .v = 1234567890 },
};

pub fn main() u8 {
    var res: u8 = 0;
    for (atoi_tests) |t| {
        const got = atoi(t.s);
        if (got != t.v) {
            std.debug.print("FAIL atoi(\"{s}\") = {d}, want {d}\n", .{ t.s, got, t.v });
            res = 1;
        }
    }
    return res;
}
