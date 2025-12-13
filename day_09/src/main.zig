const std = @import("std");

fn day09(points: []const [2]i64) u64 {
    var max_area: u64 = 0;
    for (0..points.len) |i| {
        for (i + 1..points.len) |j| {
            const p1 = points[i];
            const p2 = points[j];
            const area = @abs(p1[0] - p2[0] + 1) * @abs(p1[1] - p2[1] + 1);
            if (area > max_area) {
                max_area = area;
            }
        }
    }
    return max_area;
}

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var points = std.ArrayList([2]i64).init(allocator);
    defer points.deinit();

    var buf: [10240]u8 = undefined;
    while (try stdin.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var values = std.mem.splitScalar(u8, line, ',');

        const x_str = values.first();
        const y_str = values.next().?;
        const x = try std.fmt.parseInt(i64, x_str, 10);
        const y = try std.fmt.parseInt(i64, y_str, 10);
        try points.append([2]i64{ x, y });
    }

    const res = day09(points.items);

    try stdout.print("{d}\n", .{res});
}

test "test" {
    const points = [_][2]i64{
        .{ 7, 1 },
        .{ 11, 1 },
        .{ 11, 7 },
        .{ 9, 7 },
        .{ 9, 5 },
        .{ 2, 5 },
        .{ 2, 3 },
        .{ 7, 3 },
    };
    try std.testing.expectEqual(50, day09(points[0..]));
}
