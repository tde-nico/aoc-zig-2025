const std = @import("std");

pub fn day03(banks: []const []const u8) u64 {
    var res: u64 = 0;
    for (banks) |bank| {
        const first_idx = std.mem.indexOfMax(u8, bank[0 .. bank.len - 1]);
        const second_idx = std.mem.indexOfMax(u8, bank[first_idx + 1 .. bank.len]) + first_idx + 1;
        res += bank[first_idx] * 10 + bank[second_idx];
    }
    return res;
}

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var input = std.ArrayList([]u8).init(allocator);
    defer {
        for (input.items) |row| {
            allocator.free(row);
        }
        input.deinit();
    }

    var buf: [1024]u8 = undefined;
    while (try stdin.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const bank = try allocator.dupe(u8, line);
        for (0..bank.len) |i| {
            bank[i] -= 0x30;
        }
        try input.append(bank);
    }

    const res = day03(input.items);

    try stdout.print("{d}\n", .{res});
}

test "test" {
    const input: []const []const u8 = &.{
        &.{ 9, 8, 7, 6, 5, 4, 3, 2, 1, 1, 1, 1, 1, 1, 1 },
        &.{ 8, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 9 },
        &.{ 2, 3, 4, 2, 3, 4, 2, 3, 4, 2, 3, 4, 2, 7, 8 },
        &.{ 8, 1, 8, 1, 8, 1, 9, 1, 1, 1, 1, 2, 1, 1, 1 },
    };
    try std.testing.expectEqual(357, day03(input));
}
