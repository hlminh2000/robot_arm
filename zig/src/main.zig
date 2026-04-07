const microzig = @import("microzig");
const avr = @import("avr.zig");
const gpio = microzig.hal.gpio;

comptime {
    asm (
        \\.section microzig_flash_start,"ax",@progbits
        \\jmp microzig_start
    );
}

const led = gpio.pin(.b, 5);

pub fn main() !void {
    var loop_count: u16 = 0;
    avr.uart_init();
    led.set_direction(.output);

    print("boot: ATmega328P ready\r\n");

    while (true) {
        led.toggle();
        loop_count +%= 1;
        print("tick\r\n");

        delay(800_000);
    }
}

fn delay(limit: u32) void {
    var i: u32 = 0;
    while (i < limit) : (i += 1) {
        asm volatile ("");
    }
}

fn print(s: []const u8) void {
    for (s) |c| {
        _ = avr.uart_putchar(c, null);
    }
}
