const std = @import("std");

pub fn day06(nums: []const []const u64, ops: []const u8) u64 {
    var sum: u64 = 0;
    for (0..ops.len) |i| {
        const mul = ops[i] == '*';
        var acc: u64 = 1;
        if (!mul) {
            acc -= 1;
        }
        for (0..nums.len) |j| {
            const num = nums[j][i];
            if (mul) {
                acc *= num;
            } else {
                acc += num;
            }
        }
        sum += acc;
    }
    return sum;
}

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var nums = std.ArrayList([]u64).init(allocator);
    defer {
        for (nums.items) |num| {
            allocator.free(num);
        }
        nums.deinit();
    }

    var tmp = std.ArrayList(u64).init(allocator);
    defer tmp.deinit();
    var ops = std.ArrayList(u8).init(allocator);
    defer ops.deinit();

    var buf: [10240]u8 = undefined;
    while (try stdin.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var values = std.mem.splitScalar(u8, line, ' ');
        while (values.next()) |val| {
            if (val.len == 0) {
                continue;
            }

            if (!std.ascii.isDigit(val[0])) {
                try ops.append(val[0]);
                continue;
            }

            const num = try std.fmt.parseInt(u64, val, 10);
            try tmp.append(num);
        }

        if (tmp.items.len != 0) {
            const items = try allocator.dupe(u64, tmp.items);
            try nums.append(items);
            tmp.clearRetainingCapacity();
        }
    }

    const res = day06(nums.items, ops.items);

    try stdout.print("{d}\n", .{res});
}

test "test" {
    const nums: []const []const u64 = &.{
        &.{ 123, 328, 51, 64 },
        &.{ 45, 64, 387, 23 },
        &.{ 6, 98, 215, 314 },
    };
    const ops: []const u8 = &.{ '*', '+', '*', '+' };

    try std.testing.expectEqual(4277556, day06(nums, ops));
}
