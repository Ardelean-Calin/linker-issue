const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    const optimization = std.builtin.OptimizeMode.ReleaseSmall;
    const cpu_model = &std.Target.arm.cpu.cortex_m0plus;

    const target = std.zig.CrossTarget{
        .cpu_arch = std.Target.Cpu.Arch.thumb,
        .cpu_model = .{ .explicit = cpu_model },
        .os_tag = std.Target.Os.Tag.freestanding,
        .abi = std.Target.Abi.eabi,
    };

    const elf = b.addExecutable(.{
        .name = "dummy-arm",
        // In this case the main source file is merely a path, however, in more
        // complicated build scripts, this could be a generated file.
        .root_source_file = .{ .path = "src/startup.zig" },
        .target = target,
        .optimize = optimization,
    });

    // This line breaks the linker, comment it out to see for yourself
    elf.addCSourceFile(.{ .file = .{ .path = "src/empty.c" }, .flags = &[_][]const u8{} });

    elf.setLinkerScript(.{ .path = "linker.ld" });

    // Copy the elf to the output directory
    const copy_elf = b.addInstallArtifact(elf, .{});
    b.default_step.dependOn(&copy_elf.step);
}
