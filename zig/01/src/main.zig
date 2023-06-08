const std = @import("std");

pub fn main() !void {
    var file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();
    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    var max: u64 = 0;
    var current: u64 = 0;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var elves = std.ArrayList(u64).init(gpa.allocator());
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (line.len == 0) {
            try elves.append(current);
            // std.debug.print("{}\n", .{current});
            max = std.math.max(max, current);
            current = 0;
        } else {
            // std.debug.print("- {s}\n", .{line});
            const num = try std.fmt.parseUnsigned(u64, line, 10);
            current += num;
        }
    }
    std.debug.print("Max Calories Top 1: {}\n", .{max});
    std.sort.sort(u64, elves.items, {}, std.sort.desc(u64));
    std.debug.print("Max Calories Top 3: {}\n", .{elves.items[0] + elves.items[1] + elves.items[2]});
}
