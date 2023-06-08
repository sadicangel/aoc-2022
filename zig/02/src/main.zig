const std = @import("std");

fn getSymbol(i: i32) u8 {
    return switch (i) {
        0 => 'R',
        1 => 'P',
        else => 'S',
    };
}

fn getResult(i: i32) u8 {
    return switch (i) {
        0 => 'L',
        1 => 'D',
        else => 'W',
    };
}

fn part1() !void {
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
        //std.debug.print("{c} {c} => {} + {}\n", .{ getSymbol(o), getSymbol(p), moveScore, playScore });
        totalScore += moveScore + playScore;
    }

    std.debug.print("Score Part 1: {}\n", .{totalScore});
}

fn part2() !void {
    const content = @embedFile("input.txt");
    var readIter = std.mem.tokenize(u8, content, "\n");
    var totalScore: i32 = 0;
    while (readIter.next()) |line| {
        const o = @intCast(i32, line[0] - 'A');
        // 0: lose, 1: draw, 2: win
        const r = @intCast(i32, line[2] - 'X');
        const playScore = r * 3;
        // Pick right to win, left to lose and same to draw.
        const p = @mod(o + r - 1, 3);
        const moveScore = p + 1;
        // std.debug.print("{c}: {c} {c} => {} + {}\n", .{ getResult(r), getSymbol(o), getSymbol(p), moveScore, playScore });
        totalScore += moveScore + playScore;
    }

    std.debug.print("Score Part 2: {}\n", .{totalScore});
}

pub fn main() !void {
    try part1();
    try part2();
}
