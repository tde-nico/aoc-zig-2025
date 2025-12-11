const std = @import("std");

pub fn day02_slow(ranges: []const [2]u64) !u64 {
    var sum: u64 = 0;
    var buf: [100]u8 = undefined;
    for (ranges) |range| {
        for (range[0]..range[1] + 1) |i| {
            const str = try std.fmt.bufPrint(&buf, "{d}", .{i});
            if (str.len % 2 == 1) {
                continue;
            }

            const first = str[0 .. str.len / 2];
            const second = str[str.len / 2 ..];
            if (std.mem.eql(u8, first, second)) {
                sum += i;
            }
        }
    }
    return sum;
}

pub fn day02(ranges: []const [2]u64) u64 {
    var sum: u64 = 0;
    for (ranges) |range| {
        for (range[0]..range[1] + 1) |i| {
            const digits = std.math.log(u64, 10, i) + 1;
            if (digits % 2 == 1) {
                continue;
            }

            const mod_half = std.math.pow(u64, 10, digits / 2);
            if (i / mod_half == i % mod_half) {
                sum += i;
            }
        }
    }
    return sum;
}

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var input = std.ArrayList([2]u64).init(allocator);
    defer input.deinit();

    var buf: [1024]u8 = undefined;
    while (try stdin.readUntilDelimiterOrEof(&buf, ',')) |range| {
        var values = std.mem.splitAny(u8, range, "-");

        const first_str = values.first();
        var second_str = values.next().?;
        if (second_str[second_str.len - 1] == '\n') {
            second_str = second_str[0 .. second_str.len - 1];
        }
        const first = try std.fmt.parseInt(u64, first_str, 10);
        const second = try std.fmt.parseInt(u64, second_str, 10);

        try input.append([2]u64{ first, second });
    }

    const res = day02(input.items);

    try stdout.print("{d}\n", .{res});
}

test "test" {
    const ranges = [_][2]u64{
        .{ 11, 22 },
        .{ 95, 115 },
        .{ 998, 1012 },
        .{ 1188511880, 1188511890 },
        .{ 222220, 222224 },
        .{ 1698522, 1698528 },
        .{ 446443, 446449 },
        .{ 38593856, 38593862 },
        .{ 565653, 565659 },
        .{ 824824821, 824824827 },
        .{ 2121212118, 2121212124 },
    };
    try std.testing.expectEqual(@as(u64, 1227775554), day02_slow(ranges[0..]));
    try std.testing.expectEqual(@as(u64, 1227775554), day02(ranges[0..]));
}
