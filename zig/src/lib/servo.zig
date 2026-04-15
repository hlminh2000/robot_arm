pub const Servo = struct {
    _id: u8,
    _pin: ?c_int,

    const _attach = @extern(*const fn (u8, c_int) callconv(.c) u8, .{ .name = "servo_attach" });
    const _attachMinmax = @extern(*const fn (u8, c_int, c_int, c_int) callconv(.c) u8, .{ .name = "servo_attach_minmax" });
    const _write = @extern(*const fn (u8, c_int) callconv(.c) void, .{ .name = "servo_write" });
    const _writeMicroseconds = @extern(*const fn (u8, c_int) callconv(.c) void, .{ .name = "servo_write_microseconds" });
    const _read = @extern(*const fn (u8) callconv(.c) c_int, .{ .name = "servo_read" });
    const _readMicroseconds = @extern(*const fn (u8) callconv(.c) c_int, .{ .name = "servo_read_microseconds" });
    const _attached = @extern(*const fn (u8) callconv(.c) bool, .{ .name = "servo_attached" });
    const _detach = @extern(*const fn (u8) callconv(.c) void, .{ .name = "servo_detach" });

    pub fn init(__id: u4) Servo {
        return .{ ._id = __id, ._pin = null };
    }
    pub fn id(self: Servo) u8 {
        return self._id;
    }
    pub fn pin(self: Servo) ?c_int {
        return self._pin;
    }
    pub fn attach(self: *Servo, __pin: c_int) void {
        _ = _attach(self._id, __pin);
        self._pin = __pin;
    }
    pub fn write(self: Servo, angleDegree: c_int) void {
        _ = _write(self._id, angleDegree);
    }
    pub fn read(self: Servo) c_int {
        return _read(self._id);
    }
};
