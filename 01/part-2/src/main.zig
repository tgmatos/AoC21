const std = @import("std");
const File = @import("std.fs.File");
const name = "input";

fn readFile(filename: []const u8, allocator: std.mem.Allocator) anyerror![]u8 {
    var file = std.fs.cwd().openFile(filename, .{ .mode = .read_only }) catch |err| return err;
    defer file.close();

    var file_buffer = file.readToEndAlloc(allocator, file.getEndPos() catch 0) catch |err| return err;

    return file_buffer;
}

fn parseInput(input: []u8, allocator: std.mem.Allocator) anyerror![]i32 {
    var pos: usize = 0;
    var iter = std.mem.splitSequence(u8, input, "\n");

    var arr = allocator.alloc(i32, 2000) catch |err| return err;

    while (iter.next()) |line| {
        arr[pos] = try std.fmt.parseInt(i32, line, 10);
        pos += 1;
    }

    return arr;
}

fn sumInputs(input: []i32, allocator: std.mem.Allocator) ![]i64 {
    var arr = allocator.alloc(i64, input.len) catch |err| return err;
    var i: usize = 0;
    for (input) |sum| {
        if (i == (arr.len - 1)) {
            arr[i - 1] = sum;
        } else if (i == (arr.len - 2)) {
            arr[i] = (sum + input[i + 1]);
        } else {
            arr[i] = (sum + input[i + 1] + input[i + 2]);
        }
        i += 1;
    }

    return arr;
}

fn calculate(input: []i64) i32 {
    var old: i64 = 0;
    var result: i32 = 0;
    for (input) |num| {
        if (old == 0) old = num;

        if (old < num) {
            result += 1;
        }

        old = num;
    }

    return result;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var arrayFile = try readFile(name, allocator);

    var arrayParsed = try parseInput(arrayFile, allocator);
    defer allocator.free(arrayParsed);

    allocator.free(arrayFile);

    var arraySum = try sumInputs(arrayParsed, allocator);
    defer allocator.free(arraySum);

    var result = calculate(arraySum);
    std.debug.print("{d}", .{result});
}
