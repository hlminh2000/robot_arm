const microzig = @import("microzig");
const gpio = microzig.hal.gpio;

comptime {
    asm (
        \\.section microzig_flash_start,"ax",@progbits
        \\jmp microzig_start
    );
}

const led = gpio.pin(.b, 5);
const usart = microzig.chip.peripherals.USART0;

fn uart_init() void {
    usart.UBRR0 = 103; // 9600 baud @ 16MHz
    usart.UCSR0C.write(.{
        .UCPOL0 = 0,
        .UCSZ0 = 0b11,
        .USBS0 = .@"1_BIT",
        .UPM0 = .DISABLED,
        .UMSEL0 = .ASYNCHRONOUS_USART,
    });
    usart.UCSR0B.write(.{
        .TXB80 = 0,
        .RXB80 = 0,
        .UCSZ02 = 0,
        .TXEN0 = 1,
        .RXEN0 = 0,
        .UDRIE0 = 0,
        .TXCIE0 = 0,
        .RXCIE0 = 0,
    });
}

fn uart_putc(c: u8) void {
    while (usart.UCSR0A.read().UDRE0 == 0) {}
    usart.UDR0 = c;
}

// AVR Harvard architecture workaround: string literals live in flash but
// ld reads from RAM. Using inline for with comptime strings emits each
// character as an immediate value, avoiding flash/RAM address confusion.
fn uart_print(comptime s: []const u8) void {
    inline for (s) |c| {
        uart_putc(c);
    }
}

fn uart_put_hex(val: u16) void {
    uart_print("0x");
    nibble(@as(u4, @truncate(val >> 12)));
    nibble(@as(u4, @truncate(val >> 8)));
    nibble(@as(u4, @truncate(val >> 4)));
    nibble(@as(u4, @truncate(val)));
}

fn nibble(n: u4) void {
    uart_putc(if (n < 10) @as(u8, n) + '0' else @as(u8, n) - 10 + 'a');
}

var loop_count: u16 = 0;

pub fn main() void {
    uart_init();
    led.set_direction(.output);

    uart_print("boot: ATmega328P ready\r\n");

    while (true) {
        led.toggle();
        loop_count +%= 1;

        uart_print("loop ");
        uart_put_hex(loop_count);
        uart_print(": LED toggled\r\n");

        busyloop(800_000);
    }
}

fn busyloop(limit: u32) void {
    var i: u32 = 0;
    while (i < limit) : (i += 1) {
        asm volatile ("");
    }
}
