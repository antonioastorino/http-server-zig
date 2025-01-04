const std = @import("std");

pub fn main() !void {
    const self_addr = try std.net.Address.resolveIp("0.0.0.0", 4206);
    std.debug.print("address = {}\n", .{self_addr});
    var listener = try self_addr.listen(.{ .reuse_address = true });
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var allocator = gpa.allocator();
    while (true) {
        const conn = try listener.accept();
        const reader = conn.stream.reader();
        std.debug.print("connection accepted with {any}\n", .{conn});
        while (true) {
            const line = try reader.readUntilDelimiterOrEofAlloc(allocator, '\n', 1024);
            defer allocator.free(line.?);
            for (line.?) |ch| {
                std.debug.print("{c}", .{ch});
            }
            std.debug.print("{s}", .{"\n"});
        }
    }
}
