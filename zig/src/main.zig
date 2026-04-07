const microzig = @import("microzig");

comptime {
    asm (
        \\.section microzig_flash_start,"ax",@progbits
        \\jmp microzig_start
    );
}

pub fn main() void {
    // Set PB5 (pin 13) as output via DDRB
    asm volatile ("sbi 0x04, 5");

    while (true) {
        // Toggle PB5 via PINB
        asm volatile ("sbi 0x03, 5");

        // Long delay — ~500ms at 16MHz
        var i: u32 = 0;
        while (i < 800_000) : (i += 1) {
            asm volatile ("");
        }
    }
}
