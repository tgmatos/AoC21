const std = @import("std");
const File = @import("std.fs.File");
const fmt = @import("std.fmt");

const filename = "input";

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var file = try std.fs.cwd().openFile(filename, .{ .mode = .read_only });
    defer file.close();

    var buf = std.io.bufferedReader(file.reader());
    var reader = buf.reader();

    var line = std.ArrayList(u8).init(allocator);
    defer line.deinit();

    const writter = line.writer();

    var count: usize = 0;
    var increasedCounter: u16 = undefined;
    var previousNumber: i32 = undefined;
    var number: i32 = undefined;

    while (reader.streamUntilDelimiter(writter, '\n', null)) : (count += 1) {
        defer line.clearRetainingCapacity();

        number = try std.fmt.parseInt(i32, line.items, 10);

        if (count == 0) {
            previousNumber = number;
            increasedCounter = 0;
        }

        if (number >= previousNumber) {
            increasedCounter += 1;
        }

        previousNumber = number;
    } else |err| switch (err) {
        error.EndOfStream => {}, // Continue on
        else => |e| return e, // Propagate error
    }

    std.debug.print("{d}", .{increasedCounter});
}
