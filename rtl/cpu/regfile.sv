module regfile #(
    parameter integer STACKADDR = 'hffff //PLACEHOLDER! TODO:CHANGE DEFAULT FOR FINAL STACKADDR
)(
    input logic clk,
    input logic resetn,
    input logic enable,
    input logic [4 : 0] addr_a,
    output logic [31 : 0] data_a,
    input logic [4 : 0] addr_b,
    output logic [31 : 0] data_b,
    input logic [4 : 0] addr_c,
    input logic [31 : 0] data_c
);
    logic [31 : 0] registers [1 : 31]; //x0 can be skipped
    always_ff @(posedge clk) begin
        if(~resetn) begin
            registers[2] <= STACKADDR; //sp
        end
        else begin
            if(enable & |addr_c) begin
                registers[addr_c] <= data_c;
            end 
        end
    end
    assign data_a = |addr_a ? registers[addr_a] : 32'h0;
    assign data_b = |addr_b ? registers[addr_b] : 32'h0;
endmodule
