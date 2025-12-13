const std = @import("std");

const JOINS = 1000;

const Point = struct {
    x: u64,
    y: u64,
    z: u64,

    fn distance(self: *const Point, other: *const Point) u128 {
        const dx = @as(i128, self.x) - @as(i128, other.x);
        const dy = @as(i128, self.y) - @as(i128, other.y);
        const dz = @as(i128, self.z) - @as(i128, other.z);
        const dx2 = @as(u128, @abs(dx * dx));
        const dy2 = @as(u128, @abs(dy * dy));
        const dz2 = @as(u128, @abs(dz * dz));
        return @as(u128, dx2 + dy2 + dz2);
    }
};

const Edge = struct {
    len: u128,
    a: usize,
    b: usize,

    pub fn lt(_: void, a: Edge, b: Edge) bool {
        if (a.len == b.len) {
            return a.a < b.a;
        }
        return a.len < b.len;
    }
};

const DSU = struct {
    allocator: *const std.mem.Allocator,
    parent: []u64,
    rank: []u64,
    sz: []u64,
    num_components: u64,

    fn init(self: *DSU, allocator: *const std.mem.Allocator, N: u64) !void {
        self.allocator = allocator;
        self.parent = try self.allocator.alloc(u64, N);
        self.rank = try self.allocator.alloc(u64, N);
        self.sz = try self.allocator.alloc(u64, N);
        for (0..N) |i| {
            self.parent[i] = i;
        }
        @memset(self.rank, 0);
        @memset(self.sz, 1);
        self.num_components = N;
    }

    fn deinit(self: *DSU) void {
        self.allocator.free(self.parent);
        self.allocator.free(self.rank);
        self.allocator.free(self.sz);
    }

    fn find(self: *DSU, x: u64) u64 {
        if (self.parent[x] == x) {
            return x;
        }
        self.parent[x] = self.find(self.parent[x]);
        return self.parent[x];
    }

    fn merge(self: *DSU, A: u64, B: u64) bool {
        var a = self.find(A);
        var b = self.find(B);
        if (a == b) {
            return false;
        }
        if (self.rank[a] > self.rank[b]) {
            std.mem.swap(u64, &a, &b);
        }

        self.parent[a] = b;
        self.sz[b] += self.sz[a];
        if (self.rank[a] == self.rank[b]) {
            self.rank[b] += 1;
        }
        self.num_components -= 1;
        return true;
    }
};

fn day08(allocator: *const std.mem.Allocator, points: []const Point, joins: u64) !u64 {
    var dsu: DSU = undefined;
    try dsu.init(allocator, @as(u64, points.len));
    defer dsu.deinit();

    var edges = try allocator.alloc(Edge, points.len * (points.len - 1) / 2);
    defer allocator.free(edges);
    var idx: usize = 0;
    for (0..points.len) |i| {
        for (i + 1..points.len) |j| {
            const p1 = &points[i];
            const p2 = &points[j];
            edges[idx].len = p1.distance(p2);
            edges[idx].a = i;
            edges[idx].b = j;
            idx += 1;
        }
    }

    std.mem.sort(Edge, edges, {}, Edge.lt);

    for (0..joins) |j| {
        const edge = edges[j];
        _ = dsu.merge(edge.a, edge.b);
    }

    var counter = try allocator.alloc(u64, points.len);
    defer allocator.free(counter);
    @memset(counter, 0);
    for (0..points.len) |i| {
        const parent = dsu.find(i);
        counter[parent] += 1;
    }

    std.mem.sort(u64, counter, {}, std.sort.desc(u64));

    var res: u64 = 1;
    for (0..3) |i| {
        res *= counter[i];
    }

    return res;
}

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var points = std.ArrayList(Point).init(allocator);
    defer points.deinit();

    var buf: [10240]u8 = undefined;
    while (try stdin.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var values = std.mem.splitScalar(u8, line, ',');

        const x_str = values.first();
        const y_str = values.next().?;
        const z_str = values.next().?;
        const x = try std.fmt.parseInt(u64, x_str, 10);
        const y = try std.fmt.parseInt(u64, y_str, 10);
        const z = try std.fmt.parseInt(u64, z_str, 10);
        try points.append(Point{ .x = x, .y = y, .z = z });
    }

    const res = try day08(&allocator, points.items, JOINS);

    try stdout.print("{d}\n", .{res});
}

test "test" {
    const joins = 10;
    const points: []const Point = &.{
        .{ .x = 162, .y = 817, .z = 812 },
        .{ .x = 57, .y = 618, .z = 57 },
        .{ .x = 906, .y = 360, .z = 560 },
        .{ .x = 592, .y = 479, .z = 940 },
        .{ .x = 352, .y = 342, .z = 300 },
        .{ .x = 466, .y = 668, .z = 158 },
        .{ .x = 542, .y = 29, .z = 236 },
        .{ .x = 431, .y = 825, .z = 988 },
        .{ .x = 739, .y = 650, .z = 466 },
        .{ .x = 52, .y = 470, .z = 668 },
        .{ .x = 216, .y = 146, .z = 977 },
        .{ .x = 819, .y = 987, .z = 18 },
        .{ .x = 117, .y = 168, .z = 530 },
        .{ .x = 805, .y = 96, .z = 715 },
        .{ .x = 346, .y = 949, .z = 466 },
        .{ .x = 970, .y = 615, .z = 88 },
        .{ .x = 941, .y = 993, .z = 340 },
        .{ .x = 862, .y = 61, .z = 35 },
        .{ .x = 984, .y = 92, .z = 344 },
        .{ .x = 425, .y = 690, .z = 689 },
    };

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    try std.testing.expectEqual(40, day08(&allocator, points, joins));
}
