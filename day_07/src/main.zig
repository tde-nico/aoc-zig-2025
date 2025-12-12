const std = @import("std");

pub fn day07(grid: []const []u8) u64 {
    var splits: u64 = 0;
    const max_y: u64 = grid.len;
    const max_x: u64 = grid[0].len;
    for (1..max_y) |y| {
        for (0..max_x) |x| {
            if (!(grid[y - 1][x] == '|' or grid[y - 1][x] == 'S')) {
                continue;
            }
            switch (grid[y][x]) {
                '.' => {
                    grid[y][x] = '|';
                },
                '^' => {
                    splits += 1;
                    if (x > 0) {
                        grid[y][x - 1] = '|';
                    }
                    if (x < max_x - 1) {
                        grid[y][x + 1] = '|';
                    }
                },
                else => {},
            }
        }
    }

    // for (grid) |row| {
    //     for (row) |x| {
    //         std.debug.print("{c}", .{x});
    //     }
    //     std.debug.print("\n", .{});
    // }

    return splits;
}

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var grid = std.ArrayList([]u8).init(allocator);
    defer {
        for (grid.items) |row| {
            allocator.free(row);
        }
        grid.deinit();
    }

    var buf: [10240]u8 = undefined;
    while (try stdin.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const line_dupe = try allocator.dupe(u8, line);
        try grid.append(line_dupe);
    }

    const res = day07(grid.items);

    try stdout.print("{d}\n", .{res});
}

test "test" {
    const grid: []const []const u8 = &.{
        ".......S.......",
        "...............",
        ".......^.......",
        "...............",
        "......^.^......",
        "...............",
        ".....^.^.^.....",
        "...............",
        "....^.^...^....",
        "...............",
        "...^.^...^.^...",
        "...............",
        "..^...^.....^..",
        "...............",
        ".^.^.^.^.^...^.",
        "...............",
    };

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var tmp = std.ArrayList([]u8).init(allocator);
    defer {
        for (tmp.items) |row| {
            allocator.free(row);
        }
        tmp.deinit();
    }

    for (grid) |row| {
        const row_dupe = try allocator.dupe(u8, row);
        try tmp.append(row_dupe);
    }

    try std.testing.expectEqual(21, day07(tmp.items));
}
