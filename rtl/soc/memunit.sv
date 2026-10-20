module memunit#(
    parameter integer MEM_WORDS = 144 //THIS IS SUITED TO ONLY ONE M4K BLOCK, INCREASE ACCORDINGLY
)(
    input logic clk,
    input logic resetn,
    nativepkg bus
);
    logic [31 : 0] mem [0 : MEM_WORDS - 1];
    typedef enum {DECODE, WRITE_LOAD, READ_LOAD} state_t;
    state_t state;
    logic [29 : 0] memaddr;
    logic write_en;
    always_ff @(posedge clk) begin
        if(~resetn) begin
            state <= DECODE;
            bus.rdata <= 0;
            bus.svalid <= 0;
        end
        else begin
            case(state)
                DECODE: begin
                    bus.svalid <= 0;
                    if(bus.mvalid) begin
                        if(write_en) begin
                            state <= WRITE_LOAD;
                        end
                        else begin
                            state <= READ_LOAD;
                        end
                    end
                end
                WRITE_LOAD: begin
                    if(bus.wstrb[0]) mem[memaddr][7 : 0] = bus.wdata[7 : 0];
                    if(bus.wstrb[1]) mem[memaddr][15 : 8] = bus.wdata[15 : 8];
                    if(bus.wstrb[2]) mem[memaddr][23 : 16] = bus.wdata[23 : 16];
                    if(bus.wstrb[3]) mem[memaddr][31 : 24] = bus.wdata[31 : 24];
                    if(bus.svalid) begin
                        state <= DECODE;
                        bus.svalid <= 0;
                    end
                    else begin
                        bus.svalid <= 1;
                    end
                end
                READ_LOAD: begin
                    bus.rdata <= mem[memaddr];
                    bus.svalid <= 1;
                    state <= DECODE;
                    if(bus.svalid) begin
                        state <= DECODE;
                        bus.svalid <= 0;
                    end
                    else begin
                        bus.svalid <= 1;
                    end                
                end
            endcase;
        end
    end
    assign memaddr = bus.addr[31 : 2];
    assign write_en = | bus.wstrb;
endmodule