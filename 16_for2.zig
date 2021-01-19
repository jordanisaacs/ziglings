//
// For loops also let you store the "index" of the iteration - a
// number starting with 0 that counts up with each iteration:
//
//     for (items) |item, index| {
//         // Do something with item and index
//     }
//
const std = @import("std");

pub fn main() void {
    // Let's store the bits of binary number 1101 in
    // 'little-endian' order (least significant byte first):
    const bits = [_]u8{ 1, 0, 1, 1 };
    var value: u32 = 0;

    // Now we'll convert the binary bits to a number value by adding
    // the value of the place as a power of two for each bit. See if
    // you can figure out the missing piece:
    //
    for (bits) |bit, i| {
        var place_value = std.math.pow(u32, 2, @intCast(u32, i));
        value += place_value * bit;
    }

    std.debug.print("The value of bits '1101': {}.\n", .{value});
}