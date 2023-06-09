const std = @import("std");

pub fn main() !void {
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
        const p = if (c >= 'a') c - 'a' + 1 else c - 'A' + 27;
        std.debug.print("{c}: {}\n", .{ c, p });
        priority += p;
    }
    std.debug.print("{}\n", .{priority});
}
