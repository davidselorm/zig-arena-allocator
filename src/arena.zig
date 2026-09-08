const std = @import("std");

pub const ArenaAllocator = struct {
    const Chunk = struct {
        next: ?*Chunk,
        size: usize,
        used: usize,
    };

    backing_allocator: std.mem.Allocator,
    first_chunk: ?*Chunk,
    current_chunk: ?*Chunk,
    chunk_size: usize,
    total_allocated: usize,

    pub fn init(backing: std.mem.Allocator, default_chunk_size: usize) ArenaAllocator {
        return .{
            .backing_allocator = backing,
            .first_chunk = null,
            .current_chunk = null,
            .chunk_size = default_chunk_size,
            .total_allocated = 0,
        };
    }

    pub fn deinit(self: *ArenaAllocator) void {
        var curr = self.first_chunk;
        while (curr) |c| {
            const next = c.next;
            self.backing_allocator.destroy(c);
            curr = next;
        }
        self.first_chunk = null;
        self.current_chunk = null;
    }

    pub fn reset(self: *ArenaAllocator) void {
        var curr = self.first_chunk;
        while (curr) |c| {
            c.used = 0;
            curr = c.next;
        }
        self.current_chunk = self.first_chunk;
        self.total_allocated = 0;
    }

    pub fn alloc(self: *ArenaAllocator, comptime T: type, count: usize) ![]T {
        const bytes_needed = @sizeOf(T) * count;
        const align_needed = @alignOf(T);

        if (self.current_chunk == null or (self.current_chunk.?.size - self.current_chunk.?.used) < bytes_needed + align_needed) {
            const new_size = @max(self.chunk_size, bytes_needed + @sizeOf(Chunk) + align_needed);
            const raw_mem = try self.backing_allocator.alloc(u8, new_size);
            const new_chunk: *Chunk = @ptrCast(@alignCast(raw_mem.ptr));
            new_chunk.next = null;
            new_chunk.size = new_size - @sizeOf(Chunk);
            new_chunk.used = 0;

            if (self.current_chunk) |c| {
                c.next = new_chunk;
            } else {
                self.first_chunk = new_chunk;
            }
            self.current_chunk = new_chunk;
        }

        const chunk = self.current_chunk.?;
        const base_ptr = @as([*]u8, @ptrCast(chunk)) + @sizeOf(Chunk) + chunk.used;
        chunk.used += bytes_needed;
        self.total_allocated += bytes_needed;

        const typed_ptr: [*]T = @ptrCast(@alignCast(base_ptr));
        return typed_ptr[0..count];
    }
};

test "arena allocation and reset" {
    var arena = ArenaAllocator.init(std.testing.allocator, 4096);
    defer arena.deinit();

    const slice = try arena.alloc(u32, 10);
    for (slice, 0..) |*item, i| {
        item.* = @intCast(i * 10);
    }
    try std.testing.expectEqual(slice[5], 50);

    arena.reset();
    try std.testing.expectEqual(arena.total_allocated, 0);
}
