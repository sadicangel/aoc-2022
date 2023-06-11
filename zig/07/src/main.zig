const std = @import("std");

const Entry = struct {
    name: []const u8,
    length: usize,
    isDir: bool,
    parent: *Entry,
    children: std.ArrayList(*Entry),
    pub fn createRoot(allocator: std.mem.Allocator) !*Entry {
        const obj = try allocator.create(Entry);
        obj.name = "/";
        obj.isDir = true;
        obj.parent = obj;
        obj.length = 0;
        obj.children = std.ArrayList(*Entry).init(allocator);
        return obj;
    }

    pub fn add(self: *Entry, allocator: std.mem.Allocator, name: []const u8, isDir: bool, length: usize) !*Entry {
        const obj = try allocator.create(Entry);
        obj.name = name;
        obj.isDir = isDir;
        obj.parent = self;
        obj.length = length;
        obj.children = std.ArrayList(*Entry).init(allocator);
        try self.children.append(obj);
        return obj;
    }

    pub fn find(self: *Entry, name: []const u8) ?*Entry {
        for (self.children.items) |entry| {
            if (std.mem.eql(u8, entry.name, name)) {
                return entry;
            }
        }
        return null;
    }

    pub fn print(self: *Entry, allocator: std.mem.Allocator, indent: []u8) !void {
        if (self.isDir) {
            std.debug.print("{s}d {s}\n", .{ indent, self.name });
            var array = std.ArrayList(u8).init(allocator);
            defer array.deinit();
            try array.appendNTimes(' ', indent.len + 2);
            for (self.children.items) |child| {
                try child.print(allocator, array.items);
            }
        } else {
            std.debug.print("{s}f {s} ({})\n", .{ indent, self.name, self.length });
        }
    }

    pub fn computeLength(self: *Entry) usize {
        var length: usize = 0;
        if (self.isDir) {
            for (self.children.items) |child| {
                length += child.computeLength();
            }
        } else {
            length = self.length;
        }
        return length;
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const root = try Entry.createRoot(gpa.allocator());
    root.parent = root;
    var cwd = root;
    const content = @embedFile("input.txt");
    var readIter = std.mem.tokenize(u8, content, "\n");
    while (readIter.next()) |line| {
        if (std.mem.startsWith(u8, line, "$ cd")) {
            if (std.mem.eql(u8, line, "$ cd /")) {
                cwd = root;
            } else if (std.mem.eql(u8, line, "$ cd ..")) {
                cwd = cwd.parent;
            } else {
                var dirNameIter = std.mem.tokenize(u8, line, " ");
                _ = dirNameIter.next();
                _ = dirNameIter.next();
                const dirName = dirNameIter.next().?;
                const optionalEntry = cwd.find(dirName);
                // If not found, we need to create as the command assumes it exists.
                if (optionalEntry) |entry| {
                    cwd = entry;
                } else {
                    cwd = try cwd.add(gpa.allocator(), dirName, true, 0);
                }
            }
            std.debug.print("cd '{s}'\n", .{cwd.name});
        } else if (std.mem.startsWith(u8, line, "$ ls")) {
            std.debug.print("ls '{s}'\n", .{cwd.name});
        } else if (std.mem.startsWith(u8, line, "dir")) {
            var dirNameIter = std.mem.tokenize(u8, line, " ");
            _ = dirNameIter.next();
            const dirName = dirNameIter.next().?;
            std.debug.print("mkdir '{s}'\n", .{dirName});
            const optionalEntry = cwd.find(dirName);
            if (optionalEntry == null) {
                _ = try cwd.add(gpa.allocator(), dirName, true, 0);
            }
        } else {
            var fileNameIter = std.mem.tokenize(u8, line, " ");
            const fileSize = try std.fmt.parseUnsigned(usize, fileNameIter.next().?, 10);
            const fileName = fileNameIter.next().?;
            const optionalEntry = cwd.find(fileName);
            if (optionalEntry == null) {
                _ = try cwd.add(gpa.allocator(), fileName, false, fileSize);
            }
            std.debug.print("mk '{s}'\n", .{fileName});
        }
    }

    try root.print(gpa.allocator(), "");
}
