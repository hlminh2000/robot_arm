pub const ServoAllocationError = error{OutOfServos};
var usedIndices = initUsedIndices: {
    var indices: [12]?bool = undefined;
    for (0..indices.len) |i| {
        indices[i] = false;
    }
    break :initUsedIndices indices;
};
var currentIndex: u4 = 0;
fn getNextOpenIndex() ServoAllocationError!@TypeOf(currentIndex) {
    var nextIndex = currentIndex;
    while (usedIndices[nextIndex] != false) {
        nextIndex += 1;
        if (nextIndex >= usedIndices.len) return ServoAllocationError.OutOfServos;
    }
    return nextIndex;
}

pub const Servo = struct {
    _id: u4,
    _pin: ?c_int,

    const _attach = @extern(*const fn (u8, c_int) callconv(.c) u8, .{ .name = "servo_attach" });
    const _attachMinmax = @extern(*const fn (u8, c_int, c_int, c_int) callconv(.c) u8, .{ .name = "servo_attach_minmax" });
    const _write = @extern(*const fn (u8, c_int) callconv(.c) void, .{ .name = "servo_write" });
    const _writeMicroseconds = @extern(*const fn (u8, c_int) callconv(.c) void, .{ .name = "servo_write_microseconds" });
    const _read = @extern(*const fn (u8) callconv(.c) c_int, .{ .name = "servo_read" });
    const _readMicroseconds = @extern(*const fn (u8) callconv(.c) c_int, .{ .name = "servo_read_microseconds" });
    const _attached = @extern(*const fn (u8) callconv(.c) bool, .{ .name = "servo_attached" });
    const _detach = @extern(*const fn (u8) callconv(.c) void, .{ .name = "servo_detach" });

    pub fn acquire() ServoAllocationError!Servo {
        currentIndex = try getNextOpenIndex();
        usedIndices[currentIndex] = true;
        return .{ ._id = currentIndex, ._pin = null };
    }
    pub fn release(self: Servo) void {
        _detach(self._id);
        currentIndex = self._id;
        usedIndices[currentIndex] = false;
        currentIndex = if (currentIndex == 0) 0 else currentIndex - 1;
    }
    pub fn attach(self: *Servo, _pin: c_int) void {
        _ = _attach(self._id, _pin);
        self._pin = _pin;
    }
    pub fn write(self: Servo, angleDegree: c_int) void {
        _ = _write(self._id, angleDegree);
    }
    pub fn read(self: Servo) c_int {
        return _read(self._id);
    }
};
