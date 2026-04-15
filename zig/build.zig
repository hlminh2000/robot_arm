const std = @import("std");

pub fn build(b: *std.Build) void {
    const arduino_avr_dep = b.dependency("ArduinoCore-avr", .{});
    const servo_dep = b.dependency("Servo", .{});

    const avr_core_path = arduino_avr_dep.path("cores/arduino");
    const avr_variant_path = arduino_avr_dep.path("variants/standard");
    const servo_src_path = servo_dep.path("src");

    const avr_gcc = "/opt/homebrew/Cellar/avr-gcc@9/9.5.0/bin/avr-gcc";
    const avr_gpp = "/opt/homebrew/Cellar/avr-gcc@9/9.5.0/bin/avr-g++";

    const common_flags = &[_][]const u8{
        "-c",
        "-mmcu=atmega328p",
        "-Os",
        "-DF_CPU=16000000UL",
        "-DBAUD=9600",
        "-DARDUINO=10810",
        "-DARDUINO_AVR_UNO",
        "-DARDUINO_ARCH_AVR",
        "-I/opt/homebrew/Cellar/avr-gcc@9/9.5.0/avr/include",
    };

    const c_srcs = &[_][]const u8{
        "wiring.c",
        "wiring_digital.c",
        "wiring_analog.c",
        "hooks.c",
        "WInterrupts.c",
    };

    const cpp_srcs = &[_][]const u8{
        "main.cpp",
        "WMath.cpp",
        "WString.cpp",
        "Print.cpp",
        "Stream.cpp",
        "HardwareSerial.cpp",
        "HardwareSerial0.cpp",
        "abi.cpp",
    };

    // Compile Zig source to AVR object file
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .avr,
        .os_tag = .freestanding,
        .cpu_model = .{ .explicit = &std.Target.avr.cpu.atmega328p },
    });

    const zig_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = .ReleaseSmall,
    });

    const zig_obj = b.addObject(.{
        .name = "robot",
        .root_module = zig_mod,
    });

    // Link everything with avr-gcc (handles CRT startup, linker script, libgcc)
    const link = b.addSystemCommand(&.{ avr_gcc, "-mmcu=atmega328p" });
    link.addArg("-o");
    const elf_output = link.addOutputFileArg("robot.elf");

    link.addFileArg(zig_obj.getEmittedBin());

    for (c_srcs) |src| {
        const obj = compileWithAvrGcc(b, avr_gcc, common_flags, avr_core_path, avr_variant_path, src);
        link.addFileArg(obj);
    }

    for (cpp_srcs) |src| {
        const obj = compileWithAvrGcc(b, avr_gpp, common_flags, avr_core_path, avr_variant_path, src);
        link.addFileArg(obj);
    }

    // Servo library
    const servo_compile = b.addSystemCommand(&.{avr_gpp});
    for (common_flags) |flag| servo_compile.addArg(flag);
    servo_compile.addPrefixedDirectoryArg("-I", avr_core_path);
    servo_compile.addPrefixedDirectoryArg("-I", avr_variant_path);
    servo_compile.addPrefixedDirectoryArg("-I", servo_src_path);
    servo_compile.addFileArg(servo_dep.path("src/avr/Servo.cpp"));
    servo_compile.addArg("-o");
    const servo_obj = servo_compile.addOutputFileArg("Servo.cpp.o");
    link.addFileArg(servo_obj);

    // C++ bridge (needs Servo.h for servo functions)
    const bridge_compile = b.addSystemCommand(&.{avr_gpp});
    for (common_flags) |flag| bridge_compile.addArg(flag);
    bridge_compile.addPrefixedDirectoryArg("-I", avr_core_path);
    bridge_compile.addPrefixedDirectoryArg("-I", avr_variant_path);
    bridge_compile.addPrefixedDirectoryArg("-I", servo_src_path);
    bridge_compile.addFileArg(b.path("src/lib/arduino_bridge.cpp"));
    bridge_compile.addArg("-o");
    const bridge_obj = bridge_compile.addOutputFileArg("arduino_bridge.cpp.o");
    link.addFileArg(bridge_obj);

    link.addArg("-lm");

    // Convert ELF to Intel HEX for flashing
    const objcopy = b.addSystemCommand(&.{
        "/opt/homebrew/bin/avr-objcopy",
        "-O",
        "ihex",
        "-R",
        ".eeprom",
    });
    objcopy.addFileArg(elf_output);
    const hex_output = objcopy.addOutputFileArg("robot.hex");

    // Install into zig-out/firmware/
    const install_elf = b.addInstallFileWithDir(elf_output, .prefix, "firmware/robot.elf");
    const install_hex = b.addInstallFileWithDir(hex_output, .prefix, "firmware/robot.hex");
    b.getInstallStep().dependOn(&install_elf.step);
    b.getInstallStep().dependOn(&install_hex.step);
}

fn compileWithAvrGcc(
    b: *std.Build,
    compiler: []const u8,
    common_flags: []const []const u8,
    core_path: std.Build.LazyPath,
    variant_path: std.Build.LazyPath,
    src: []const u8,
) std.Build.LazyPath {
    const compile = b.addSystemCommand(&.{compiler});
    for (common_flags) |flag| {
        compile.addArg(flag);
    }
    compile.addPrefixedDirectoryArg("-I", core_path);
    compile.addPrefixedDirectoryArg("-I", variant_path);
    compile.addFileArg(core_path.path(b, src));
    compile.addArg("-o");
    return compile.addOutputFileArg(b.fmt("{s}.o", .{src}));
}
