const std = @import("std");
const c = @cImport({
    @cInclude("nanosvg.h");
});

pub const PaintType = enum(i8) {
    undef = c.NSVG_PAINT_UNDEF,
    none = c.NSVG_PAINT_NONE,
    color = c.NSVG_PAINT_COLOR,
    linear_gradient = c.NSVG_PAINT_LINEAR_GRADIENT,
    radial_gradient = c.NSVG_PAINT_RADIAL_GRADIENT,
};

pub const SpreadType = enum(i8) {
    pad = c.NSVG_SPREAD_PAD,
    reflect = c.NSVG_SPREAD_REFLECT,
    repeat = c.NSVG_SPREAD_REPEAT,
};

pub const LineJoin = enum(i8) {
    miter = c.NSVG_JOIN_MITER,
    round = c.NSVG_JOIN_ROUND,
    bevel = c.NSVG_JOIN_BEVEL,
};

pub const LineCap = enum(i8) {
    butt = c.NSVG_CAP_BUTT,
    round = c.NSVG_CAP_ROUND,
    square = c.NSVG_CAP_SQUARE,
};

pub const FillRule = enum(i8) {
    nonzero = c.NSVG_FILLRULE_NONZERO,
    evenodd = c.NSVG_FILLRULE_EVENODD,
};

pub const Flags = enum(u8) {
    visible = c.NSVG_FLAGS_VISIBLE,
};

pub const PaintOrder = enum(u8) {
    fill = c.NSVG_PAINT_FILL,
    markers = c.NSVG_PAINT_MARKERS,
    stroke = c.NSVG_PAINT_STROKE,
};

pub const Color = extern union {
    rgba: u32,
    c: extern struct {
        r: u8,
        g: u8,
        b: u8,
        a: u8,
    },
};

pub const GradientStop = extern struct {
    color: Color,
    offset: f32,
};

pub const Gradient = extern struct {
    xform: [6]f32,
    spread: SpreadType,
    fx: f32,
    fy: f32,
    nstops: i32,
    stops: [1]GradientStop,
};

pub const Paint = extern struct {
    type: PaintType,
    u: extern union {
        color: c_uint,
        gradient: *Gradient,
    },
};

pub const Path = extern struct {
    pts: [*]f32,
    npts: i32,
    closed: u8,
    bounds: [4]f32,
    next: ?*Path,

    pub fn duplicate(self: *@This()) *Path {
        var path: c.NSVGpath = .{
            .pts = self.pts,
            .npts = self.npts,
            .closed = self.closed,
            .bounds = self.bounds,
            .next = if (self.next) |next| @ptrCast(next) else null,
        };
        return @ptrCast(c.nsvgDuplicatePath(@ptrCast(&path)));
    }

    pub fn free(self: *@This()) void {
        std.c.free(self.pts);
        std.c.free(self);
    }
};

pub const Shape = extern struct {
    id: [64]u8,
    fill: Paint,
    stroke: Paint,
    opacity: f32,
    stroke_width: f32,
    stroke_dash_offset: f32,
    stroke_dash_array: [8]f32,
    stroke_dash_count: i8,
    stroke_line_join: LineJoin,
    stroke_line_cap: LineCap,
    miter_limit: f32,
    fill_rule: FillRule,
    paint_order: PaintOrder,
    flags: Flags,
    bounds: [4]f32,
    fill_gradient: [64]u8,
    stroke_gradient: [64]u8,
    xform: [6]f32,
    paths: ?*Path,
    next: ?*Shape,
};

pub const Image = extern struct {
    width: f32,
    height: f32,
    shapes: ?*Shape,

    pub fn delete(self: *@This()) void {
        c.nsvgDelete(@ptrCast(self));
    }
};

pub fn parseFromFile(filename: [:0]const u8, units: [:0]const u8, dpi: f32) *Image {
    return @ptrCast(c.nsvgParseFromFile(filename.ptr, units.ptr, dpi));
}

pub fn parse(input: [:0]u8, units: [:0]const u8, dpi: f32) *Image {
    return @ptrCast(c.nsvgParse(input.ptr, units.ptr, dpi));
}
