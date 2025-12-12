const std = @import("std");

const Dir = struct {
    dy: i32,
    dx: i32,
};

fn directions() [8]Dir {
    var d: [8]Dir = undefined;
    var i = 0;
    for (0..3) |y| {
        for (0..3) |x| {
            if ((y == 1) and (x == 1)) {
                continue;
            }
            d[i].dy = @as(i32, y) - 1;
            d[i].dx = @as(i32, x) - 1;
            i += 1;
        }
    }
    return d;
}

const dirs = directions();

pub fn day04(grid: []const []const u8) u64 {
    var count: u64 = 0;
    for (0..grid.len) |y| {
        for (0..grid[0].len) |x| {
            if (grid[y][x] != '@') {
                continue;
            }

            var rolls: u64 = 0;
            for (dirs) |dir| {
                const curr_y = @as(i64, @intCast(y)) + dir.dy;
                if (curr_y < 0 or curr_y >= grid.len) {
                    continue;
                }

                const curr_x = @as(i64, @intCast(x)) + dir.dx;
                if (curr_x < 0 or curr_x >= grid[0].len) {
                    continue;
                }

                if (grid[@intCast(curr_y)][@intCast(curr_x)] == '@') {
                    rolls += 1;
                }
            }

            if (rolls < 4) {
                count += 1;
            }
        }
    }
    return count;
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
        const row = try allocator.dupe(u8, line);
        try input.append(row);
    }

    const res = day04(input.items);

    try stdout.print("{d}\n", .{res});
}

test "test" {
    const input: []const []const u8 = &.{
        "..@@.@@@@.",
        "@@@.@.@.@@",
        "@@@@@.@.@@",
        "@.@@@@..@.",
        "@@.@@@@.@@",
        ".@@@@@@@.@",
        ".@.@.@.@@@",
        "@.@@@.@@@@",
        ".@@@@@@@@.",
        "@.@.@@@.@.",
    };
    try std.testing.expectEqual(13, day04(input));
}
