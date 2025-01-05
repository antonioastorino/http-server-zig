const std = @import("std");

pub fn main() !void {
    const self_addr = try std.net.Address.resolveIp("127.0.0.1", 8081);
    std.debug.print("address = {}\n", .{self_addr});
    var listener = try self_addr.listen(.{ .reuse_address = true });
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var allocator = gpa.allocator();
    while (true) {
        const conn = try listener.accept();
        const reader = conn.stream.reader();
        std.debug.print("connection accepted with {any}\n", .{conn});
        while (try reader.readUntilDelimiterOrEofAlloc(allocator, '\n', 1024)) |line| {
            defer allocator.free(line);
            for (line) |ch| {
                std.debug.print("{c}", .{ch});
            }
            std.debug.print("{s}", .{"\n"});
            // NOTE: removing this if statement will make the browser hang.
            // By stopping to load the page you will trigger the closing of the connection from the client side.
            if (line[0] == '\r') {
                std.debug.print("Header end\n", .{});
                break;
            }
        } else {
            std.debug.print("Connection closed by the client.\n", .{});
        }
    }
}
