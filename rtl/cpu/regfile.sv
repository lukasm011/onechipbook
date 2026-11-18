`timescale 1ns/1ps
module regfile #(
    parameter integer STACKADDR = 'hffff //PLACEHOLDER! TODO:CHANGE DEFAULT FOR FINAL STACKADDR
)(
    input logic clk,
    input logic resetn,
    input logic [4 : 0] addr_a,
    output logic [31 : 0] data_a,
    input logic [4 : 0] addr_b,
    output logic [31 : 0] data_b,
    input logic [4 : 0] addr_c,
    input logic [31 : 0] data_c,
    input logic [3 : 0] strb,
    input logic sign
);
    logic [31 : 0] registers [1 : 31]; //x0 can be skipped
    logic msb;
    always_ff @(posedge clk) begin
        if(~resetn) begin
            registers[2] <= STACKADDR; //sp
        end
        else begin
            if(|strb && |addr_c) begin
                //Output all register writes
                $display("%d : %h", addr_c, data_c);
                //TODO: IMPLEMENT AS MASK
                //registers[addr_c] <= data_c & mask;
                if(strb[0]) registers[addr_c][7 : 0] <= data_c[7 : 0];

                if(strb[1]) registers[addr_c][15 : 8] <= data_c[15 : 8];
                else registers[addr_c][15 : 8] <= {8{msb}};
                
                if(strb[2]) registers[addr_c][23 : 16] <= data_c[23 : 16];
                else registers[addr_c][23 : 16] <= {8{msb}};
                
                if(strb[3]) registers[addr_c][31 : 24] <= data_c[31 : 24];
                else registers[addr_c][31 : 24] <= {8{msb}};
            end 
        end
    end
    assign data_a = |addr_a ? registers[addr_a] : 32'h0;
    assign data_b = |addr_b ? registers[addr_b] : 32'h0;
    //Find MSB for sign extension in case of strobe 0011 or 0001
    assign msb = strb[1] ? data_c[15] & sign : data_c[7] & sign;
endmodule
