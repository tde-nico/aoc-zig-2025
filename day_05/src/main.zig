const std = @import("std");

fn ls(_: void, a: [2]u64, b: [2]u64) bool {
    return std.mem.order(u64, &a, &b) == .lt;
}

pub fn day05(ranges: [][2]u64, ids: []const u64) u64 {
    var fresh: u64 = 0;
    std.mem.sort([2]u64, ranges, {}, comptime ls);
    for (ids) |id| {
        for (ranges) |range| {
            if (id < range[0]) {
                break;
            }
            if (id <= range[1]) {
                fresh += 1;
                break;
            }
        }
    }
    return fresh;
}

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var ranges = std.ArrayList([2]u64).init(allocator);
    defer ranges.deinit();

    var buf: [1024]u8 = undefined;
    while (try stdin.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (line.len == 0) {
            break;
        }

        var values = std.mem.splitAny(u8, line, "-");

        const first_str = values.first();
        const second_str = values.next().?;
        const first = try std.fmt.parseInt(u64, first_str, 10);
        const second = try std.fmt.parseInt(u64, second_str, 10);

        try ranges.append([2]u64{ first, second });
    }

    var ids = std.ArrayList(u64).init(allocator);
    defer ids.deinit();

    while (try stdin.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        try ids.append(try std.fmt.parseInt(u64, line, 10));
    }

    const res = day05(ranges.items, ids.items);

    try stdout.print("{d}\n", .{res});
}

test "test" {
    var ranges = [_][2]u64{
        .{ 3, 5 },
        .{ 10, 14 },
        .{ 16, 20 },
        .{ 12, 18 },
    };
    const ids: []const u64 = &.{ 1, 5, 8, 11, 17, 32 };
    try std.testing.expectEqual(3, day05(&ranges, ids));
}
