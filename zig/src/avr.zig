//! Declarations for AVR_C Library C API (headers under Library/).
//! https://github.com/lkoepsel/AVR_C/tree/main/Library
//! tinymt32.h also defines many inline static helpers in the header; those are not extern symbols.

// --- analogRead.h ---
pub extern fn analogRead(apin: u8) u16;

// --- analogWrite.h ---
pub extern fn clear_all_TC() void;
pub extern fn analogWrite(apin: u8, cycle: u8) u8;

// --- button.h ---
pub extern fn read_button(uno: u8) u8;
pub extern fn is_button_pressed(instance: u8) u8;

// --- delay.h ---
pub extern fn delay(ms: u16) void;
pub extern fn delay_us(us: u16) void;

// --- digitalRead.h ---
pub extern fn digitalRead(apin: u8) u8;

// --- digitalWrite.h ---
pub extern fn digitalWrite(apin: u8, level: u8) void;

// --- map.h ---
pub extern fn map(x: i32, in_min: i32, in_max: i32, out_min: i32, out_max: i32) i32;

// --- pinMode.h ---
pub extern fn pinMode(apin: u8, mode: u8) u8;

// --- readLine.h ---
pub extern fn readLine(buffer: [*c]u8, size: u8) u8;
pub extern fn printLine(buffer: [*c]u8, len: u8) void;

// --- serialRead.h ---
pub extern fn serialRead() u16;

// --- servo.h ---
pub const servo = extern struct {
    bit: u8,
    port: *volatile u8,
    state: u8,
    high_width: u16,
    low_width: u16,
    high_count: u16,
    low_count: u16,
};

pub const MAX_SERVOS = 2;

pub extern var servos: [MAX_SERVOS]servo;

pub extern fn init_servos() void;
pub extern fn set_servo(index: u8, bit: u8, port: *volatile u8, state: u8, high_width: u16) void;
pub extern fn move_servo(index: u8, high_width: u16) void;

// --- soft_serial.h ---
pub extern fn init_soft_serial() void;
pub extern fn soft_char_write(data: c_char) void;
pub extern fn soft_char_read() i8;
pub extern fn soft_string_write(buffer: [*c]u8, len: i8) i8;
pub extern fn soft_readLine(buffer: [*c]u8, size: i8) i8;
pub extern fn soft_int16_write(number: i16) void;
pub extern fn soft_int16_writef(number: i16, size: i8) void;
pub extern fn soft_int8_write(number: i8) void;
pub extern fn soft_char_NL() void;
pub extern fn soft_char_BL() void;
pub extern fn soft_pgmtext_write(pgm_text: [*c]const u8) void;

// --- sysclock.h ---
pub extern fn millis() u32;
pub extern fn micros() u16;
pub extern fn ticks() u16;
pub extern fn ticks_ro() u16;
pub extern fn servo_clock() u16;
pub extern fn init_sysclock_0() void;
pub extern fn init_pulse_0() void;
pub extern fn init_sysclock_1() void;
pub extern fn init_sysclock_2() void;
pub extern fn init_RESET() void;
pub extern fn is_RESET_pressed() u8;
pub extern fn read_RESET() u8;

pub extern fn millis_TC3() u32;
pub extern fn init_sysclock_3() void;

// --- tinymt32.h (linkable symbols from tinymt32.c only) ---
pub const tinymt32_t = extern struct {
    status: [4]u32,
    mat1: u32,
    mat2: u32,
    tmat: u32,
};

pub extern fn tinymt32_init(random: *tinymt32_t, seed: u32) void;
pub extern fn tinymt32_init_by_array(random: *tinymt32_t, init_key: [*c]const u32, key_length: c_int) void;

// --- tone.h ---
pub extern fn tone(pin: u8, note: u8, duration: u16) void;
pub extern fn tone_on(pin: u8, note: u8) void;
pub extern fn noTone(pin: u8) void;

// --- uart.h ---
pub extern fn uart_putchar(ch: u8, stream: ?*anyopaque) c_int;
pub extern fn uart_getchar(stream: ?*anyopaque) c_int;
pub extern fn uart_init() void;
pub extern fn init_serial() void;

// --- unolib.h ---
pub extern fn d_analogRead(pin: u8) u16;
pub extern fn constrain8_t(value: u8, min_v: u8, max_v: u8) u8;
pub extern fn constrain16_t(value: u16, min_v: u16, max_v: u16) u16;
pub extern fn wdt_init() callconv(.naked) void;

// --- xArm.h ---
pub const MAX_TOKENS = 24 / 2;
pub const xArm_MAX_BUFFER = 32;

pub extern var tokens: [MAX_TOKENS][*c]u8;
pub extern var xArm_in: [xArm_MAX_BUFFER + 1]u8;
pub extern var xArm_out: [xArm_MAX_BUFFER + 1]u8;

pub extern fn init_xArm() void;
pub extern fn print_help() void;
pub extern fn echo_command(n: u8) void;
pub extern fn vector_prompt() void;
pub extern fn print_result(e: u8) void;
pub extern fn lowByte(value: u16) u8;
pub extern fn highByte(value: u16) u8;
pub extern fn xArm_clamp(v: i16) i16;
pub extern fn valid_joint(joint: [*c]u8) i8;
pub extern fn valid_position(pos: [*c]u8) i16;
pub extern fn valid_vector(vect: [*c]u8) i8;
pub extern fn xArm_send(cmd: u8, len: u8) void;
pub extern fn xArm_recv(cmd: u8) u8;
pub extern fn xArm_beep() void;
pub extern fn valid_move(j: [*c]u8, p: [*c]u8) i8;
pub extern fn valid_add(j: [*c]u8, p: [*c]u8) i8;
pub extern fn valid_skip(j: [*c]u8) i8;
pub extern fn show_adds() u8;
pub extern fn show_vecs() u8;
pub extern fn show_joint_pos(j: i8, v: i8) void;
pub extern fn exec_adds() u8;
pub extern fn reset_adds() u8;
pub extern fn add_position() void;
pub extern fn xArm_setPosition(servo_id: u8, position: i16) void;
pub extern fn save_vectors() i8;
pub extern fn load_vectors() i8;
pub extern fn verify_vectors(v: i8, addr: u16) i8;
pub extern fn print_voltage() u8;
pub extern fn xArm_getBatteryVoltage() u16;
pub extern fn print_position(j: [*c]u8) i8;
pub extern fn get_vect_num(v: [*c]u8) i8;
pub extern fn show_all() u8;
pub extern fn perf_all() i8;
pub extern fn xArm_getPosition(servo_id: u8) u16;
