const std = @import("std");

fn range(len: usize) []const void {
    return @as([*]void, undefined)[0..len];
}

fn print(stacks: std.ArrayList(std.ArrayList(u8))) !void {
    var max: usize = 0;
    for (range(stacks.items.len)) |_, i| {
        max = std.math.max(max, stacks.items[i].items.len);
    }

    for (range(max)) |_, l| {
        for (stacks.items) |stack| {
            const i = max - l - 1;
            if (i < stack.items.len) {
                std.debug.print("[{c}] ", .{stack.items[i]});
            } else {
                std.debug.print("    ", .{});
            }
        }
        std.debug.print("\n", .{});
    }
}

pub fn main() !void {
    const content = @embedFile("input.txt");
    var readIter = std.mem.tokenize(u8, content, "\n");
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var stacks = std.ArrayList(std.ArrayList(u8)).init(gpa.allocator());
    defer stacks.deinit();
    var isInit = false;
    while (readIter.next()) |line| {
        // Init stacks.
        if (!isInit) {
            isInit = true;
            for (range((line.len + 1) / 4)) |_| {
                var stack = std.ArrayList(u8).init(gpa.allocator());
                defer stack.deinit();
                try stacks.append(stack);
            }
        }
        // Reached end of stack lines?
        if (line[1] == '1') {
            for (range(stacks.items.len)) |_, i| {
                std.debug.print(" {}  ", .{i});
            }
            std.debug.print("\n", .{});
            break;
        }

        for (range(stacks.items.len)) |_, i| {
            var box = line[1 + 4 * i];
            if (box != ' ')
                try stacks.items[i].insert(0, box);
        }
    }

    try print(stacks);

    // Move boxes
    while (readIter.next()) |line| {
        var moveIter = std.mem.tokenize(u8, line, " ");
        _ = moveIter.next();
        var count = try std.fmt.parseUnsigned(usize, moveIter.next().?, 10);
        _ = moveIter.next();
        var fromIndex = try std.fmt.parseUnsigned(usize, moveIter.next().?, 10) - 1;
        _ = moveIter.next();
        var toIndex = try std.fmt.parseUnsigned(usize, moveIter.next().?, 10) - 1;
        //std.debug.print("move {} from {} to {}\n", .{ count, fromIndex, toIndex });
        var from: std.ArrayList(u8) = stacks.items[fromIndex];
        var to: std.ArrayList(u8) = stacks.items[toIndex];
        for (range(count)) |_| {
            const box = from.orderedRemove(from.items.len - 1);
            std.debug.print("move {c} from {} to {}\n", .{ box, fromIndex, toIndex });
            try to.append(box);
        }
        stacks.items[fromIndex] = from;
        stacks.items[toIndex] = to;
    }
    try print(stacks);

    for (stacks.items) |stack| {
        std.debug.print("{c}", .{stack.items[stack.items.len - 1]});
    }
}
