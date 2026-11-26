module soc_top(
    input logic clk,
    input logic resetn
);
    native_if bus ();
    cpu_top cpu_top (
    	.clk   (clk),
    	.resetn(resetn),
    	.bus   (bus)
    );
endmodule
