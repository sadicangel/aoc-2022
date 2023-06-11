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
            std.debug.print("{s}d {s} ({})\n", .{ indent, self.name, self.length });
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
        if (self.isDir) {
            self.length = 0;
            for (self.children.items) |child| {
                self.length += child.computeLength();
            }
        }
        return self.length;
    }

    pub fn computeProblem1(self: *Entry) usize {
        var sum: usize = 0;
        if (self.isDir) {
            if (self.length <= 100000)
                sum += self.length;
            for (self.children.items) |child| {
                sum += child.computeProblem1();
            }
        }
        return sum;
    }

    pub fn computeProblem2(self: *Entry, requiredSpace: usize, min: *usize, size: *usize) void {
        if (self.isDir) {
            if (requiredSpace < self.length) {
                const m = self.length - requiredSpace;
                if (m < min.*) {
                    min.* = m;
                    size.* = self.length;
                }
            }
            for (self.children.items) |child| {
                child.computeProblem2(requiredSpace, min, size);
            }
        }
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const root = try Entry.createRoot(gpa.allocator());
    root.parent = root;
    var cwd = root;
    const content = @embedFile("input.txt");
    var readIter = std.mem.tokenize(u8, content, "\r\n");
    while (readIter.next()) |line| {
        if (std.mem.startsWith(u8, line, "$ cd")) {
            if (std.mem.startsWith(u8, line, "$ cd /")) {
                cwd = root;
            } else if (std.mem.startsWith(u8, line, "$ cd ..")) {
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
            //std.debug.print("cd '{s}'\n", .{cwd.name});
        } else if (std.mem.startsWith(u8, line, "$ ls")) {
            //std.debug.print("ls '{s}'\n", .{cwd.name});
        } else if (std.mem.startsWith(u8, line, "dir")) {
            var dirNameIter = std.mem.tokenize(u8, line, " ");
            _ = dirNameIter.next();
            const dirName = dirNameIter.next().?;
            //std.debug.print("mkdir '{s}'\n", .{dirName});
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
            //std.debug.print("mk '{s}'\n", .{fileName});
        }
    }

    const rootSize = root.computeLength();

    std.debug.print("Disk space: {}/{}\n", .{ 70000000 - rootSize, rootSize });

    const sizeSum = root.computeProblem1();

    std.debug.print("Sum of sizes of directories with size less or equal to 100000: {}\n", .{sizeSum});

    const requiredSpace = 30000000 - (70000000 - rootSize);

    std.debug.print("Required space: {}\n", .{requiredSpace});

    // Problem 2.
    var min: usize = 0xffff_ffff_ffff_ffff;
    var size: usize = 0;
    root.computeProblem2(requiredSpace, &min, &size);

    std.debug.print("Smallest directory to remove has size: {}\n", .{size});
}
