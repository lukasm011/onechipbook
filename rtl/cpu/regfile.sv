module regfile #(
    parameter integer STACKADDR = 'hffff //PLACEHOLDER! TODO:CHANGE DEFAULT FOR FINAL STACKADDR
)(
    input clk,
    input resetn,
    input enable,
    input [4 : 0] addr_a,
    output [31 : 0] data_a,
    input [4 : 0] addr_b,
    output [31 : 0] data_b,
    input [4 : 0] addr_c,
    input [31 : 0] data_c
);
    logic [31 : 0] registers [1 : 31]; //x0 can be skipped
    always_ff @(posedge clk) begin
        if(~resetn) begin
            registers[2] <= STACKADDR; //sp
        end
        else begin
            data_a <= addr_a ? registers[addr_a] : 32'h0;
            data_b <= addr_b ? registers[addr_b] : 32'h0;
            if(enable && addr_c) begin
                registers[addr_c] <= data_c;
            end 
        end
    end
endmodule