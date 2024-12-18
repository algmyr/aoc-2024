const std = @import("std");

const width = 71;
const height = 71;

const Point = struct {
    dist: i32,
    x: i32,
    y: i32,
};

fn make_grid() [height + 2][width + 2]bool {
    @setEvalBranchQuota(10000);
    var g: [height + 2][width + 2]bool = undefined;
    for (g, 0..) |row, y| {
        for (row, 0..) |_, x| {
            if (x % (height + 1) == 0 or y % (width + 1) == 0) {
                g[y][x] = true;
            } else {
                g[y][x] = false;
            }
        }
    }
    return g;
}

fn Queue(comptime T: type) type {
    return struct {
        const This = @This();
        const Allocator = std.mem.Allocator;

        data: []T = undefined,
        head: usize = 0,
        tail: usize = 0,

        pub fn init(allocator: Allocator, size: usize) This {
            // panic on error
            const data = allocator.alloc(T, size) catch unreachable;
            return This{ .data = data };
        }

        pub fn push(self: *This, item: T) void {
            self.data[self.tail] = item;
            self.tail = (self.tail + 1) % self.data.len;
        }

        pub fn pop(self: *This) T {
            const item = self.data[self.head];
            self.head = (self.head + 1) % self.data.len;
            return item;
        }

        pub fn len(self: *This) usize {
            if (self.tail >= self.head) {
                return self.tail - self.head;
            }
            return self.data.len - self.head + self.tail;
        }
    };
}

fn solve(ally: std.mem.Allocator, list: std.ArrayList(u32), limit: usize) i32 {
    var grid = comptime make_grid();
    {
        var it = std.mem.window(u32, list.items, 2, 2);
        var i: u32 = 0;
        while (if (i < limit) it.next() else null) |item| {
            grid[item[1] + 1][item[0] + 1] = true;
            i += 1;
        }
    }

    const target_x = width;
    const target_y = height;
    var q = Queue(Point).init(ally, 1000);

    q.push(Point{ .dist = 0, .x = 1, .y = 1 });
    while (q.len() > 0) {
        const p = q.pop();
        if (p.x == target_x and p.y == target_y) {
            return p.dist;
        }
        if (grid[@intCast(p.y)][@intCast(p.x)]) {
            continue;
        }
        grid[@intCast(p.y)][@intCast(p.x)] = true;

        const dxs = [_]i32{ -1, 0, 1, 0 };
        const dys = [_]i32{ 0, -1, 0, 1 };
        for (0..4) |i| {
            const dx = dxs[i];
            const dy = dys[i];
            const x = p.x + dx;
            const y = p.y + dy;
            q.push(Point{ .dist = p.dist + 1, .x = x, .y = y });
        }
    }
    return -1;
}

pub fn main() !void {
    var timer = try std.time.Timer.start();

    // 4 MiB ends up being enough.
    var buffer: [4 << 20]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const ally = fba.allocator();

    var reader = std.io.getStdIn().reader();
    const input = try reader.readAllAlloc(ally, 1 << 20);

    var list = std.ArrayList(u32).init(ally);
    defer list.deinit();
    {
        var it = std.mem.tokenizeAny(u8, input, "\n,");
        while (it.next()) |num| {
            const n = try std.fmt.parseInt(u32, num, 10);
            try list.append(n);
        }
    }

    const writer = std.io.getStdOut().writer();
    {
        const result = solve(ally, list, 1024);
        try writer.print("Part 1: {d}\n", .{result});
    }

    var l: usize = 0;
    var r: usize = list.items.len / 2 + 1;
    while (r - l > 1) {
        const m = l + (r - l) / 2;
        const result = solve(ally, list, m);
        if (result == -1) {
            r = m;
        } else {
            l = m;
        }
    }

    const x = list.items[2 * l];
    const y = list.items[2 * l + 1];
    try writer.print("Part 2: {d},{d}\n", .{ x, y });

    const elapsed2: f64 = @floatFromInt(timer.read());
    std.debug.print("Time elapsed is: {d:.3}ms\n", .{
        elapsed2 / std.time.ns_per_ms,
    });
}
