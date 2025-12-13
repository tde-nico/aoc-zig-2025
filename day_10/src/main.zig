const std = @import("std");

const Machine = struct {
    target: u64,
    buttons: std.ArrayList(u64),
};

fn day10(gpa: std.mem.Allocator, machines: []Machine) !u64 {
    var res: u64 = 0;
    var queue: std.ArrayList(struct { u64, u64 }) = .empty;
    defer queue.deinit(gpa);
    var visited: std.AutoArrayHashMapUnmanaged(u64, void) = .empty;
    defer visited.deinit(gpa);

    for (machines) |machine| {
        var best: u64 = std.math.maxInt(u64);
        try queue.append(gpa, .{ 0, 0 });
        var i: usize = 0;

        while (i < queue.items.len) {
            const state, const count = queue.items[i];
            i += 1;
            if (state == machine.target) {
                best = count;
                break;
            }
            for (machine.buttons.items) |button| {
                const next_state = state ^ button;
                if (visited.contains(next_state)) {
                    continue;
                }
                try queue.append(gpa, .{ next_state, count + 1 });
            }
        }

        queue.clearRetainingCapacity();
        visited.clearRetainingCapacity();
        res += best;
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

    var machines: std.ArrayList(Machine) = .empty;
    defer {
        for (machines.items) |*m| m.buttons.deinit(gpa);
        machines.deinit(gpa);
    }

    while (try stdin.takeDelimiter('\n')) |line| {
        var machine = Machine{
            .target = 0,
            .buttons = .empty,
        };
        var components = std.mem.splitScalar(u8, line, ' ');
        while (components.next()) |component| {
            const content = component[1 .. component.len - 1];
            switch (component[0]) {
                '[' => {
                    for (content, 0..) |light, i| {
                        if (light == '#') {
                            machine.target |= @as(u64, 1) << @as(u6, @intCast(i));
                        }
                    }
                },
                '(' => {
                    var button: u64 = 0;
                    var iter = std.mem.splitScalar(u8, content, ',');
                    while (iter.next()) |light_str| {
                        const light = try std.fmt.parseInt(u64, light_str, 10);
                        button |= @as(u64, 1) << @as(u6, @intCast(light));
                    }
                    try machine.buttons.append(gpa, button);
                },
                else => break,
            }
        }
        try machines.append(gpa, machine);
    }

    const res = try day10(gpa, machines.items);

    try stdout.print("{d}\n", .{res});
    try stdout.flush();
}
