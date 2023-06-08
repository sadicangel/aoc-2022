const std = @import("std");

fn getSymbol(i: i32) u8 {
    switch (i) {
        0 => return 'R',
        1 => return 'P',
        else => return 'S',
    }
}

pub fn main() !void {
    const content = @embedFile("input.txt");
    var readIter = std.mem.tokenize(u8, content, "\n");
    var totalScore: i32 = 0;
    while (readIter.next()) |line| {
        const o = @intCast(i32, line[0] - 'A');
        const p = @intCast(i32, line[2] - 'X');
        const moveScore = p + 1;
        var playScore: i32 = 0;
        if (o == p) {
            playScore += 3;
        } else {
            var c = @mod(p - o, 3);
            if (c < 0) c += 3;
            if (c <= 1)
                playScore += 6;
        }
        std.debug.print("{c} {c} => {} + {}\n", .{ getSymbol(o), getSymbol(p), moveScore, playScore });
        totalScore += moveScore + playScore;
    }

    std.debug.print("Total Score: {}\n", .{totalScore});
}
