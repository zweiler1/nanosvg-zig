const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addLibrary(.{
        .name = "nanosvg",
        .root_module = b.addModule("root", .{
            .root_source_file = b.path("src/root.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
    });
    b.installArtifact(lib);

    // Create the executable called 'nanosvg'
    const exe = b.addExecutable(.{
        .name = "nanosvg",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "nanosvg", .module = lib.root_module },
            },
        }),
    });
    b.installArtifact(exe);
    const run_step = b.step("run", "Run the app");
    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);
    run_cmd.step.dependOn(b.getInstallStep());

    // Forward CLI arguments to the executable
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

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
