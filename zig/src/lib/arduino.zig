// --- Types ---

pub const String = [*:0]const u8;

// --- Constants ---
pub const DigitalValue = enum(u8) {
    high = 0x1,
    low = 0x0,
};

pub const PinMode = enum(u8) {
    input = 0x0,
    output = 0x1,
    input_pullup = 0x2,
};

pub const BitOrder = enum(u8) {
    lsb_first = 0,
    msb_first = 1,
};

pub const InterruptMode = enum(u8) {
    change = 1,
    falling = 2,
    rising = 3,
};

pub const AnalogRef = enum(u8) {
    default = 1,
    external = 0,
    internal = 3,
};

// --- Digital I/O ---

const _pinMode = @extern(*const fn (u8, u8) callconv(.c) void, .{ .name = "arduino_pinMode" });
pub fn pinMode(pin: u8, mode: PinMode) void {
    _pinMode(pin, @intFromEnum(mode));
}
pub const digitalWrite = @extern(*const fn (u8, DigitalValue) callconv(.c) void, .{ .name = "arduino_digitalWrite" });
pub const digitalRead = @extern(*const fn (u8) callconv(.c) DigitalValue, .{ .name = "arduino_digitalRead" });

// --- Analog I/O ---

pub const analogRead = @extern(*const fn (u8) callconv(.c) c_int, .{ .name = "arduino_analogRead" });
pub const analogReference = @extern(*const fn (u8) callconv(.c) void, .{ .name = "arduino_analogReference" });
pub const analogWrite = @extern(*const fn (u8, c_int) callconv(.c) void, .{ .name = "arduino_analogWrite" });

// --- Timing ---

pub const delay = @extern(*const fn (c_ulong) callconv(.c) void, .{ .name = "arduino_delay" });
pub const delayMicroseconds = @extern(*const fn (c_uint) callconv(.c) void, .{ .name = "arduino_delayMicroseconds" });
pub const millis = @extern(*const fn () callconv(.c) c_ulong, .{ .name = "arduino_millis" });
pub const micros = @extern(*const fn () callconv(.c) c_ulong, .{ .name = "arduino_micros" });

// --- Pulse ---

pub const pulseIn = @extern(*const fn (u8, u8, c_ulong) callconv(.c) c_ulong, .{ .name = "arduino_pulseIn" });
pub const pulseInLong = @extern(*const fn (u8, u8, c_ulong) callconv(.c) c_ulong, .{ .name = "arduino_pulseInLong" });

// --- Shift ---

pub const shiftOut = @extern(*const fn (u8, u8, u8, u8) callconv(.c) void, .{ .name = "arduino_shiftOut" });
pub const shiftIn = @extern(*const fn (u8, u8, u8) callconv(.c) u8, .{ .name = "arduino_shiftIn" });

// --- Interrupts ---

pub const interrupts = @extern(*const fn () callconv(.c) void, .{ .name = "arduino_interrupts" });
pub const noInterrupts = @extern(*const fn () callconv(.c) void, .{ .name = "arduino_noInterrupts" });

// --- Tone ---

pub const tone = @extern(*const fn (u8, c_uint, c_ulong) callconv(.c) void, .{ .name = "arduino_tone" });
pub const noTone = @extern(*const fn (u8) callconv(.c) void, .{ .name = "arduino_noTone" });

// --- Random ---

pub const random = @extern(*const fn (c_long) callconv(.c) c_long, .{ .name = "arduino_random" });
pub const randomRange = @extern(*const fn (c_long, c_long) callconv(.c) c_long, .{ .name = "arduino_random_range" });
pub const randomSeed = @extern(*const fn (c_ulong) callconv(.c) void, .{ .name = "arduino_randomSeed" });

// --- Math (bridged) ---

pub const map = @extern(*const fn (c_long, c_long, c_long, c_long, c_long) callconv(.c) c_long, .{ .name = "arduino_map" });

// --- Math (pure Zig, no bridge needed) ---

pub fn constrain(val: anytype, low: anytype, high: anytype) @TypeOf(val) {
    if (val < low) return low;
    if (val > high) return high;
    return val;
}

pub fn sq(x: anytype) @TypeOf(x) {
    return x * x;
}

pub fn lowByte(w: anytype) u8 {
    return @truncate(w & 0xff);
}

pub fn highByte(w: anytype) u8 {
    return @truncate((w >> 8) & 0xff);
}

pub fn bit(b: u5) u32 {
    return @as(u32, 1) << b;
}

pub fn bitRead(value: anytype, b: anytype) u1 {
    return @truncate((value >> @intCast(b)) & 0x01);
}

pub fn bitSet(value: anytype, b: anytype) @TypeOf(value) {
    return value | (@as(@TypeOf(value), 1) << @intCast(b));
}

pub fn bitClear(value: anytype, b: anytype) @TypeOf(value) {
    return value & ~(@as(@TypeOf(value), 1) << @intCast(b));
}

pub fn bitToggle(value: anytype, b: anytype) @TypeOf(value) {
    return value ^ (@as(@TypeOf(value), 1) << @intCast(b));
}

// --- Serial ---
const _printInt = @extern(*const fn (c_int) callconv(.c) void, .{ .name = "serial_print_int" });
const _print = @extern(*const fn (String) callconv(.c) void, .{ .name = "serial_print" });
const _printlnInt = @extern(*const fn (c_int) callconv(.c) void, .{ .name = "serial_println_int" });
const _println = @extern(*const fn (String) callconv(.c) void, .{ .name = "serial_println" });

const _begin = @extern(*const fn (c_ulong) callconv(.c) void, .{ .name = "serial_begin" });
const _writeByte = @extern(*const fn (u8) callconv(.c) void, .{ .name = "serial_write_byte" });
const _available = @extern(*const fn () callconv(.c) c_int, .{ .name = "serial_available" });
const _read = @extern(*const fn () callconv(.c) c_int, .{ .name = "serial_read" });
pub const Serial = struct {
    pub fn begin(baud: c_ulong) void {
        _begin(baud);
    }
    pub fn available() c_int {
        return _available();
    }
    pub fn writeByte(b: u8) void {
        _writeByte(b);
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
