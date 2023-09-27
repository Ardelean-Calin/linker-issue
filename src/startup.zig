const empty = @import("empty.zig");

// These symbols come from the linker script
extern const _sidata: u32;
extern var _sdata: u32;
extern const _edata: u32;
extern var _sbss: u32;
extern const _ebss: u32;

export fn resetHandler() void {
    // Copy data from flash to RAM
    const data_loadaddr = @as([*]const u8, @ptrCast(&_sidata));
    const data = @as([*]u8, @ptrCast(&_sdata));
    const data_size = @intFromPtr(&_edata) - @intFromPtr(&_sdata);
    for (data_loadaddr[0..data_size], 0..) |d, i| data[i] = d;

    // Clear the bss
    const bss = @as([*]u8, @ptrCast(&_sbss));
    const bss_size = @intFromPtr(&_ebss) - @intFromPtr(&_sbss);
    for (bss[0..bss_size]) |*b| b.* = 0;

    // Call contained in main.zig
    empty.main();

    unreachable;
}
