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
    var k: usize = 14;
    var packetEnd: usize = 0;
    var messageEnd: usize = 0;
    while (j < content.len) {
        std.debug.print("{s}\n", .{content[i..j]});
        if (packetEnd == 0 and areUnique(content[i..j])) {
            packetEnd = j;
        }
        if (messageEnd == 0 and areUnique(content[i..k])) {
            messageEnd = k;
        }
        i += 1;
        j += 1;
        k += 1;
        if (packetEnd != 0 and messageEnd != 0)
            break;
    }
    std.debug.print("Last index of unique 4 word: {}\n", .{packetEnd});
    std.debug.print("Last index of unique 14 word: {}\n", .{messageEnd});
}
