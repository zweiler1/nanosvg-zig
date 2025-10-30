const std = @import("std");
const nanosvg = @import("nanosvg");

pub fn main() !void {
    const image = nanosvg.parseFromFile("test.svg", "px", 96);
    defer image.delete();
    std.debug.print("size: {d} × {d}\n", .{ image.width, image.height });

    var shape = image.shapes;
    while (shape != null) : (shape = shape.?.next) {
        std.debug.print("opacity: {d}\n", .{shape.?.opacity});
        var path = shape.?.paths;
        while (path != null) : (path = path.?.next) {
            var i: i32 = 0;
            while (i < path.?.npts - 1) : (i += 3) {
                const p: [*]f32 = @ptrCast(&path.?.pts[@intCast(i * 2)]);
                std.debug.print("p0 = {d}\n", .{p[0]});
            }
        }
    }
}
