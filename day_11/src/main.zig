const std = @import("std");
const ArrayList = std.ArrayList;
const HashMap = std.StringHashMap;

fn day11(graph: HashMap(ArrayList([]const u8)), root: []const u8) u64 {
    if (std.mem.eql(u8, root, "out")) {
        return 1;
    }

    var res: u64 = 0;
    const edges = graph.get(root).?;
    for (edges.items) |next| {
        res += day11(graph, next);
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

    var graph = HashMap(ArrayList([]const u8)).init(gpa);
    defer {
        var it = graph.iterator();
        while (it.next()) |node| {
            for (node.value_ptr.items) |edge| {
                gpa.free(edge);
            }
            node.value_ptr.deinit(gpa);
            gpa.free(node.key_ptr.*);
        }
        graph.deinit();
    }

    while (try stdin.takeDelimiter('\n')) |line| {
        var iter = std.mem.splitScalar(u8, line, ' ');
        var root: ?[]const u8 = null;
        var edges: ArrayList([]const u8) = .empty;
        while (iter.next()) |node| {
            if (root == null) {
                const r = try gpa.dupe(u8, node[0 .. node.len - 1]);
                root = r;
            } else {
                const n = try gpa.dupe(u8, node);
                try edges.append(gpa, n);
            }
        }
        if (root) |r| {
            try graph.put(r, edges);
        }
    }

    const res = day11(graph, "you");

    try stdout.print("{d}\n", .{res});
    try stdout.flush();
}
