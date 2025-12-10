const std = @import("std");

pub fn day01(input: []const []const u8) !u64 {
    var count: u64 = 0;
    var dial: u64 = 50;
    for (input) |row| {
        if (row.len < 2) {
            continue;
        }
        const value = try std.fmt.parseInt(u64, row[1..], 10) % 100;
        switch (row[0]) {
            'L' => {
                dial = (dial + 100 - value) % 100;
            },
            'R' => {
                dial = (dial + value) % 100;
            },
            else => {},
        }
        if (dial == 0) {
            count += 1;
        }
    }
    return count;
}

pub fn main() !void {
    const reader = std.io.getStdIn().reader();
    const writer = std.io.getStdOut().writer();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var input = std.ArrayList([]const u8).init(allocator);
    defer input.deinit();
    while (try reader.readUntilDelimiterOrEofAlloc(std.heap.page_allocator, '\n', std.math.maxInt(usize))) |row| {
        try input.append(row);
    }

    const res = try day01(input.items);

    try writer.print("{d}\n", .{res});
}

test "test" {
    const input = [_][]const u8{ "L68", "L30", "R48", "L5", "R60", "L55", "L1", "L99", "R14", "L82" };
    try std.testing.expectEqual(@as(i32, 3), day01(input[0..]));
}
