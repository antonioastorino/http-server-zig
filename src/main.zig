const std = @import("std");

pub fn main() !void {
    const self_addr = try std.net.Address.resolveIp("0.0.0.0", 4206);
    std.debug.print("address = {}\n", .{self_addr});
    var listener = try self_addr.listen(.{ .reuse_address = true });
    while (true) {
        const conn = listener.accept();
        std.debug.print("connection accepted with {any}\n", .{conn});
    }
}
