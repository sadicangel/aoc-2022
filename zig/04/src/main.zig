const std = @import("std");

pub fn main() !void {
    const content = @embedFile("input.txt");
    var readIter = std.mem.tokenize(u8, content, "\n");
    var inside: u32 = 0;
    var overlap: u32 = 0;
    while (readIter.next()) |line| {
        var rangeIter = std.mem.split(u8, line, ",");
        const range1 = rangeIter.next().?;
        const range2 = rangeIter.next().?;
        var splitIter1 = std.mem.split(u8, range1, "-");
        var splitIter2 = std.mem.split(u8, range2, "-");
        const min1 = try std.fmt.parseUnsigned(i32, splitIter1.next().?, 10);
        const max1 = try std.fmt.parseUnsigned(i32, splitIter1.next().?, 10);
        const min2 = try std.fmt.parseUnsigned(i32, splitIter2.next().?, 10);
        const max2 = try std.fmt.parseUnsigned(i32, splitIter2.next().?, 10);

        const r1WithinR2 = min1 >= min2 and max1 <= max2;
        const r2WithinR1 = min2 >= min1 and max2 <= max1;
        if (r1WithinR2 or r2WithinR1)
            inside += 1;
        if (min1 <= max2 and min2 <= max1)
            overlap += 1;
    }
    std.debug.print("Ranges inside other: {}\n", .{inside});
    std.debug.print("Ranges that overlap: {}\n", .{overlap});
}
