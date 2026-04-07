const microzig = @import("microzig");

const usart = microzig.chip.peripherals.USART0;

pub fn init() void {
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

pub fn putc(c: u8) void {
    while (usart.UCSR0A.read().UDRE0 == 0) {}
    usart.UDR0 = c;
}

// AVR Harvard architecture workaround: string literals live in flash but
// ld reads from RAM. Using inline for with comptime strings emits each
// character as an immediate value, avoiding flash/RAM address confusion.
pub fn print(comptime s: []const u8) void {
    inline for (s) |c| {
        putc(c);
    }
}

pub fn put_hex(val: u16) void {
    print("0x");
    nibble(@as(u4, @truncate(val >> 12)));
    nibble(@as(u4, @truncate(val >> 8)));
    nibble(@as(u4, @truncate(val >> 4)));
    nibble(@as(u4, @truncate(val)));
}

fn nibble(n: u4) void {
    putc(if (n < 10) @as(u8, n) + '0' else @as(u8, n) - 10 + 'a');
}
