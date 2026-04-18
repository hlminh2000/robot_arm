const std = @import("std");

pub fn build(b: *std.Build) void {
    const arduino_avr_dep = b.dependency("ArduinoCore-avr", .{});
    const servo_dep = b.dependency("Servo", .{});

    const avr_core_path = arduino_avr_dep.path("cores/arduino");
    const avr_variant_path = arduino_avr_dep.path("variants/standard");
    const servo_src_path = servo_dep.path("src");

    const avr_gcc = "avr-gcc";
    const avr_gpp = "avr-g++";

    const common_flags = &[_][]const u8{
        "-c",
        "-mmcu=atmega328p",
        "-Os",
        "-ffunction-sections",
        "-fdata-sections",
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
        "wiring_pulse.c",
        "wiring_pulse.S",
        "wiring_shift.c",
        "hooks.c",
        "WInterrupts.c",
    };

    const cpp_srcs = &[_][]const u8{
        "main.cpp",
        "WMath.cpp",
        "WString.cpp",
        "Print.cpp",
        "Stream.cpp",
        "Tone.cpp",
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
        .strip = true,
        .single_threaded = true,
        .error_tracing = false,
    });

    const zig_obj = b.addObject(.{
        .name = "robot",
        .root_module = zig_mod,
    });

    // Link everything with avr-gcc (handles CRT startup, linker script, libgcc)
    const link = b.addSystemCommand(&.{ avr_gcc, "-mmcu=atmega328p", "-Wl,--gc-sections" });
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

    const include_paths = &[_]std.Build.LazyPath{ avr_core_path, avr_variant_path, servo_src_path };

    // Servo library
    const servo_obj = compileWithAvrGpp(b, avr_gpp, common_flags, include_paths, servo_dep.path("src/avr/Servo.cpp"), "Servo.cpp.o");
    link.addFileArg(servo_obj);

    // C++ bridge (needs Servo.h for servo functions)
    const bridge_obj = compileWithAvrGpp(b, avr_gpp, common_flags, include_paths, b.path("src/lib/bridge/index.cpp"), "index.cpp.o");
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

fn compileWithAvrGpp(
    b: *std.Build,
    avr_gpp: []const u8,
    common_flags: []const []const u8,
    include_paths: []const std.Build.LazyPath,
    source: std.Build.LazyPath,
    out_name: []const u8,
) std.Build.LazyPath {
    const compile = b.addSystemCommand(&.{avr_gpp});
    for (common_flags) |flag| compile.addArg(flag);
    for (include_paths) |p| compile.addPrefixedDirectoryArg("-I", p);
    compile.addFileArg(source);
    compile.addArg("-o");
    return compile.addOutputFileArg(out_name);
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
