const microzig = @import("microzig");
const gpio = microzig.hal.gpio;
const uart = @import("uart.zig");

comptime {
    asm (
        \\.section microzig_flash_start,"ax",@progbits
        \\jmp microzig_start
    );
}

const led = gpio.pin(.b, 5);

var loop_count: u16 = 0;

pub fn main() void {
    uart.init();
    led.set_direction(.output);

    uart.print("boot: ATmega328P ready\r\n");

    while (true) {
        led.toggle();
        loop_count +%= 1;

        uart.print("loop ");
        uart.put_hex(loop_count);
        uart.print(": LED toggled\r\n");

        delay(800_000);
    }
}

fn delay(limit: u32) void {
    var i: u32 = 0;
    while (i < limit) : (i += 1) {
        asm volatile ("");
    }
}
