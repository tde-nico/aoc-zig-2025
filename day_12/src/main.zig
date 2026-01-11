const std = @import("std");
const ArrayList = std.ArrayList;

fn day11(regions: []u64, shapes_x_region: []u64) u64 {
    var res: u64 = 0;
    for (0..regions.len) |i| {
        if (regions[i] >= shapes_x_region[i] * 9) {
            res += 1;
        }
    }
    return res;
}

pub fn main() !void {
    var read_buf: [4 * 1024]u8 = undefined;
    var reader = std.fs.File.stdin().reader(&read_buf);
    const stdin = &reader.interface;
    var write_buf: [4 * 1024]u8 = undefined;
    var writer = std.fs.File.stdout().writer(&write_buf);
    const stdout = &writer.interface;

    var debug_allocator = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = debug_allocator.deinit();
    const gpa = debug_allocator.allocator();

    var regions: ArrayList(u64) = .empty;
    defer regions.deinit(gpa);
    var shapes_x_region: ArrayList(u64) = .empty;
    defer shapes_x_region.deinit(gpa);

    while (try stdin.takeDelimiter('\n')) |line| {
        if (!std.mem.containsAtLeastScalar(u8, line, 1, 'x')) {
            continue;
        }

        var iter = std.mem.splitScalar(u8, line, ':');

        var region_iter = std.mem.splitScalar(u8, iter.first(), 'x');
        var region: u64 = try std.fmt.parseInt(u64, region_iter.first(), 10);
        region *= try std.fmt.parseInt(u64, region_iter.next().?, 10);

        var shapes_iter = std.mem.splitScalar(u8, iter.next().?, ' ');
        var shapes: u64 = 0;
        while (shapes_iter.next()) |num| {
            if (num.len == 0) continue;
            shapes += try std.fmt.parseInt(u64, num, 10);
        }

        try regions.append(gpa, region);
        try shapes_x_region.append(gpa, shapes);
    }

    const res = day11(regions.items, shapes_x_region.items);

    try stdout.print("{d}\n", .{res});
    try stdout.flush();
}
