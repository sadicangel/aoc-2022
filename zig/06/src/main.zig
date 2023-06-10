const std = @import("std");

fn areUnique(slice: []const u8) bool {
    for (slice) |n1, i| {
        for (slice[i + 1 ..]) |n2| {
            if (n1 == n2)
                return false;
        }
    }
    return true;
}

pub fn main() !void {
    const content = @embedFile("input.txt");
    var i: usize = 0;
    var j: usize = 4;
    while (j < content.len) {
        std.debug.print("{s}\n", .{content[i..j]});
        if (areUnique(content[i..j]))
            break;
        i += 1;
        j += 1;
    }
    std.debug.print("Last index of unique 4 word: {}\n", .{j});
}
