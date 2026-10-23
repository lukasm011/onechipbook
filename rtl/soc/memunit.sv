module memunit#(
    parameter integer MEM_BLKS = 104
)(
    input logic clk,
    input logic resetn,
    nativepkg bus
);
    //
    // NOTE: MADE TO WORK WITH ALTERA CYCLONE I USING M4K RAM
    //
    localparam integer WORDS_PER_BLK = 144;
    localparam integer MEM_WORDS = WORDS_PER_BLK * MEM_BLKS;
    localparam integer ADDR_WIDTH = $clog2(MEM_WORDS);
    logic [31 : 0] mem [0 : MEM_WORDS - 1];
    typedef enum {DECODE, WRITE_LOAD, READ_LOAD} state_t;
    state_t state, state_next;
    logic [ADDR_WIDTH - 1 : 0] memaddr, memaddr_next;
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
        write_reg <= write_reg_next;
        if(state == WRITE_LOAD) begin
           if(bus.wstrb[0]) mem[memaddr][7 : 0] <= write_reg[7 : 0];
           if(bus.wstrb[1]) mem[memaddr][15 : 8] <= write_reg[15 : 8];
           if(bus.wstrb[2]) mem[memaddr][23 : 16] <= write_reg[23 : 16];
           if(bus.wstrb[3]) mem[memaddr][31 : 24] <= write_reg[31 : 24]; 
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
        if(~resetn) begin
            state_next = DECODE;
        end
        else begin
            case(state)
                DECODE: begin
                    if(bus.mvalid) begin
                        memaddr_next = bus.addr[(ADDR_WIDTH - 1) + 2 : 2];
                        if(|bus.wstrb) begin
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