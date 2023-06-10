const std = @import("std");

fn areUnique(slice: []const u8) bool {
    if (slice[0] == slice[1] or slice[0] == slice[2] or slice[0] == slice[3])
        return false;
    if (slice[1] == slice[2] or slice[1] == slice[3])
        return false;
    if (slice[2] == slice[3])
        return false;
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
