const std = @import("std");

pub fn main() !void {
    var file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();
    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    var max: u64 = 0;
    var current: u64 = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (line.len == 0) {
            std.debug.print("{}\n", .{current});
            max = std.math.max(max, current);
            current = 0;
        } else {
            std.debug.print("- {s}\n", .{line});
            const num = try std.fmt.parseUnsigned(u64, line, 10);
            current += num;
        }
    }
    std.debug.print("{}\n", .{max});
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
