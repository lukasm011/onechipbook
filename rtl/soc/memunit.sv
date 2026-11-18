`timescale 1ns/1ps
module memunit#(
    parameter integer MEM_BLKS = 32
    //
    // NOTE: ACTUAL SIZE OF BSRAM IS 52 BLOCKS,
    // 32 SET TO AVOID BOUNDS CHECKING IN FIRST DRAFT
    // TODO: EXTEND MEM_BLKS TO 52!
    //
)(
    input logic clk,
    input logic resetn,
    native_if bus
);
    //
    // NOTE: MADE TO WORK WITH ALTERA CYCLONE I USING M4K RAM
    // USAGE OF PARITY BITS IS NOT CURRENTLY SUPPORTED
    //
    localparam integer WORDS_PER_BLK = 128;
    localparam integer MEM_WORDS = WORDS_PER_BLK * MEM_BLKS;
    localparam integer ADDR_WIDTH = $clog2(MEM_WORDS);
    logic [31 : 0] mem [0 : MEM_WORDS - 1];
    typedef enum {DECODE, WRITE_LOAD, READ_LOAD} state_t;
    state_t state, state_next;
    logic [ADDR_WIDTH - 1 : 0] memaddr, memaddr_next;
    logic [3 : 0] strb_reg, strb_reg_next;
    logic [31 : 0] read_reg, write_reg, write_reg_next;
    logic svalid_next;
    //
    // Memunit clocked
    //
    always_ff @(posedge clk) begin
        memaddr <= memaddr_next;
        read_reg <= mem[memaddr];
        bus.svalid <= svalid_next;
        state <= state_next;
        strb_reg <= strb_reg_next;
        //Write strobe
        if(strb_reg[0]) write_reg[7 : 0] <= write_reg_next[7 : 0];
        if(strb_reg[1]) write_reg[15 : 8] <= write_reg_next[15 : 8];
        if(strb_reg[2]) write_reg[23 : 16] <= write_reg_next[23 : 16];
        if(strb_reg[3]) write_reg[31 : 24] <= write_reg_next[31 : 24];
        if(state == WRITE_LOAD) begin
           mem[memaddr] <= write_reg;
        end
    end
    //
    // Memunit combinational
    //
    always_comb begin
        //
        // Default values
        //
        memaddr_next = memaddr;
        state_next = state;
        bus.rdata = read_reg;
        svalid_next = 0;
        write_reg_next = bus.wdata;
        strb_reg_next = strb_reg;
        if(~resetn) begin
            state_next = DECODE;
            strb_reg_next = 0;
            memaddr_next = 0;
        end
        else begin
            case(state)
                DECODE: begin
                    if(bus.mvalid) begin
                        memaddr_next = bus.addr[(ADDR_WIDTH - 1) + 2 : 2];
                        if(|bus.wstrb) begin
                            strb_reg_next = bus.wstrb;
                            state_next = WRITE_LOAD;
                            svalid_next = 1;
                        end
                        else begin
                            state_next = READ_LOAD;
                        end
                    end
                end
                READ_LOAD: begin
                    if(bus.svalid) begin
                        svalid_next = 0;
                        state_next = DECODE;
                    end else begin
                        //register write
                        svalid_next = 1;
                    end
                end
                WRITE_LOAD: begin
                    svalid_next = 0;
                    state_next = DECODE;
                end
            endcase
        end
    end
endmodule
