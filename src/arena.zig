const std = @import("std");

pub const Arena = struct {
    buffer: []u8,
    offset: usize,

    pub fn init(buf: []u8) Arena {
        return Arena{ .buffer = buf, .offset = 0 };
    }
    pub fn reset(self: *Arena) void {
        self.offset = 0;
    }
};
