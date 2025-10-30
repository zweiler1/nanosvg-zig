# nanosvg-zig

Zig package for the nanosvg C library

## Installation

Add `nanosvg` to your `build.zig.zon` .dependencies with:
```
zig fetch --save git+https://github.com/zweiler1/nanosvg-zig
```
and in your `build.zig` add:
```zig
pub fn build(b: *std.Build) void {
    const exe = b.addExecutable(.{ ... });

    const zstbi = b.dependency("nanosvg_zig", .{});
    exe.root_module.addImport("nanosvg", nanosvg.module("root"));
}
```
Now in your code you may import and use `nanosvg`.
