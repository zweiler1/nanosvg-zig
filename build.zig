const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addLibrary(.{
        .name = "nanosvg",
        .root_module = b.addModule("nanosvg", .{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
    });
    b.installArtifact(lib);

    const upstream = b.dependency("upstream", .{});
    lib.root_module.addIncludePath(upstream.path("src"));
    lib.installHeader(upstream.path("src/nanosvg.h"), "nanosvg.h");

    const c_source_code =
        \\#define NANOSVG_IMPLEMENTATION
        \\#include <nanosvg.h>
    ;
    const c_source_file_step = b.addWriteFiles();
    const c_source_path = c_source_file_step.add("c.c", c_source_code);
    lib.root_module.addIncludePath(b.path("src"));
    lib.root_module.addCSourceFile(.{
        .language = .c,
        .file = c_source_path,
        .flags = &[_][]const u8{
            "-Wall",
        },
    });
}
