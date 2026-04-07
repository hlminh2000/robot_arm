const std = @import("std");
const microzig = @import("microzig");

const MicroBuild = microzig.MicroBuild(.{
    .atmega = true,
});

pub fn build(b: *std.Build) void {
    const avr_c_dep = b.dependency("avr_c", .{});
    const mz_dep = b.dependency("microzig", .{});
    const mb = MicroBuild.init(b, mz_dep) orelse return;

    const firmware = mb.add_firmware(.{
        .name = "robot",
        .target = mb.ports.atmega.boards.arduino.uno_rev3,
        .optimize = .ReleaseSmall,
        .root_source_file = b.path("src/main.zig"),
    });

    const avr_libc_include = "/opt/homebrew/Cellar/avr-gcc@9/9.5.0/avr/include";
    firmware.add_c_source_file(.{
        .file = avr_c_dep.path("Library/uart.c"),
        .flags = &.{ "-DF_CPU=16000000UL", "-DBAUD=9600", "-D__AVR_ATmega328P__", "-mmcu=atmega328p", "-Os" },
    });
    firmware.add_include_path(avr_c_dep.path("Library"));
    firmware.add_include_path(.{ .cwd_relative = avr_libc_include });

    mb.install_firmware(firmware, .{});
    mb.install_firmware(firmware, .{ .format = .elf });
}
