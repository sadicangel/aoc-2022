const std = @import("std");

fn getPriority(c: u8) u32 {
    return if (c >= 'a') c - 'a' + 1 else c - 'A' + 27;
}

fn part1() !void {
    const content = @embedFile("input.txt");
    var readIter = std.mem.tokenize(u8, content, "\n");
    var priority: u32 = 0;
    while (readIter.next()) |line| {
        const m = line.len / 2;
        var c: u8 = 0;
        for (line[0..m]) |c1| {
            for (line[m..]) |c2| {
                if (c1 == c2) {
                    c = c1;
                    break;
                }
            }
        }
        const p = getPriority(c);
        //std.debug.print("{c}: {}\n", .{ c, p });
        priority += p;
    }
    std.debug.print("Individual priorities: {}\n", .{priority});
}

fn part2() !void {
    const content = @embedFile("input.txt");
    var readIter = std.mem.tokenize(u8, content, "\n");
    var priority: u32 = 0;
    while (readIter.next()) |line1| {
        const line2 = readIter.next();
        const line3 = readIter.next();
        //std.debug.print("{?s}\n{?s}\n{?s}\n", .{ line1, line2, line3 });
        var c: u8 = undefined;
        var found = false;
        for (line1) |c1| {
            if (found)
                break;
            for (line2.?) |c2| {
                if (found)
                    break;
                if (c1 != c2)
                    continue;
                for (line3.?) |c3| {
                    if (c1 == c3) {
                        c = c1;
                        break;
                    }
                }
            }
        }
        //std.debug.print("{c}\n\n", .{c});
        priority += getPriority(c);
    }
    std.debug.print("Group priorities: {}\n", .{priority});
}

pub fn main() !void {
    try part1();
    try part2();
}
