const std = @import("std");

pub const Arena = struct {
    buffer: []u8,
    offset: usize,

    pub fn init(buf: []u8) Arena {
        return Arena{ .buffer = buf, .offset = 0 };
    }
    pub fn alloc(self: *Arena, comptime T: type, count: usize) ![]T {
        const alignment = @alignOf(T);
        const aligned_offset = std.mem.alignForward(usize, self.offset, alignment);
        const bytes_needed = count * @sizeOf(T);
        if (aligned_offset + bytes_needed > self.buffer.len) return error.OutOfMemory;
        self.offset = aligned_offset + bytes_needed;
        return @ptrCast(@alignCast(self.buffer[aligned_offset..self.offset]));
    }
    pub fn reset(self: *Arena) void {
        self.offset = 0;
    }
};
