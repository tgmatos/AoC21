const std = @import("std");
const File = @import("std.fs.File");
const fmt = @import("std.fmt");
const name = "input";

const Command = enum { forward, up, down, err };
const CommandError = error{inputError};

fn readFile(filename: []const u8, allocator: std.mem.Allocator) anyerror![]u8 {
    var file = std.fs.cwd().openFile(filename, .{ .mode = .read_only }) catch |err| return err;
    defer file.close();

    var file_buffer = file.readToEndAlloc(allocator, file.getEndPos() catch 0) catch |err| return err;

    return file_buffer;
}

fn parseInput(input: []u8) anyerror![]i32 {
    var horizon: i32 = 0;
    var depth: i32 = 0;
    var aim: i32 = 0;
    var arr: [3]i32 = undefined;

    var iter = std.mem.splitSequence(u8, input, "\n");

    while (iter.next()) |line| {
        var lineSequence = std.mem.splitSequence(u8, line, " ");
        var t = std.meta.stringToEnum(Command, lineSequence.first()) orelse .err;
        var x = try std.fmt.parseInt(i32, lineSequence.rest(), 10);

        switch (t) {
            .forward => {
                horizon += x;
                depth += aim * x;
            },
            .up => aim -= x,
            .down => aim += x,
            .err => return CommandError.inputError,
        }
    }

    arr[0] = horizon;
    arr[1] = depth;
    arr[2] = aim;

    return &arr;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var arrayFile = try readFile(name, allocator);
    defer allocator.free(arrayFile);

    var arr = try parseInput(arrayFile);
    std.debug.print("Horizontal position: {d}\nDepth: {d}\nAim: {d}\nMultiplication: {d}", .{ arr[0], arr[1], arr[2], arr[0] * arr[1] });
}
