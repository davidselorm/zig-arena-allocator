const std = @import("std");
pub fn build(b: *std.Build) void {
    const lib = b.addStaticLibrary(.{ .name = "zig-arena", .root_source_file = b.path("src/arena.zig"), .target = b.standardTargetOptions(.{}), .optimize = b.standardOptimizeOption({}) });
    b.installArtifact(lib);
}
