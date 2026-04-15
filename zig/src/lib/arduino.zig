pub const pinMode = @extern(*const fn (u8, u8) callconv(.c) void, .{ .name = "arduino_pinMode" });
pub const digitalWrite = @extern(*const fn (u8, u8) callconv(.c) void, .{ .name = "arduino_digitalWrite" });
pub const delay = @extern(*const fn (c_ulong) callconv(.c) void, .{ .name = "arduino_delay" });

pub const Serial = struct {
    const _printInt = @extern(*const fn (c_int) callconv(.c) void, .{ .name = "serial_print_int" });
    const _print = @extern(*const fn ([*:0]const u8) callconv(.c) void, .{ .name = "serial_print" });
    const _printlnInt = @extern(*const fn (c_int) callconv(.c) void, .{ .name = "serial_println_int" });
    const _println = @extern(*const fn ([*:0]const u8) callconv(.c) void, .{ .name = "serial_println" });

    const _begin = @extern(*const fn (c_ulong) callconv(.c) void, .{ .name = "serial_begin" });
    const _writeByte = @extern(*const fn (u8) callconv(.c) void, .{ .name = "serial_write_byte" });
    const _available = @extern(*const fn () callconv(.c) c_int, .{ .name = "serial_available" });
    const _read = @extern(*const fn () callconv(.c) c_int, .{ .name = "serial_read" });

    pub fn begin(bau: c_ulong) void {
        return _begin(bau);
    }
    pub fn available() c_int {
        return _available();
    }
    pub fn writeByte(byte: u8) void {
        return _writeByte(byte);
    }
    pub fn read() c_int {
        return _read();
    }
    pub fn print(val: anytype) void {
        switch (@typeInfo(@TypeOf(val))) {
            .int, .comptime_int => _printInt(@intCast(val)),
            .pointer => _print(val),
            else => @compileError("unsupported type for Serial.print"),
        }
    }
    pub fn println(val: anytype) void {
        switch (@typeInfo(@TypeOf(val))) {
            .int, .comptime_int => _printlnInt(@intCast(val)),
            .pointer => _println(val),
            else => @compileError("unsupported type for Serial.println"),
        }
    }
};
