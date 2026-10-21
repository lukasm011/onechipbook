module dummy_mem#(
    parameter MEM_WORDS = 1024
)(
    input logic clk,
    input logic resetn,
    nativepkg bus
);
    logic [31 : 0] mem [0 : MEM_WORDS];
    initial $readmemh("/home/lukas/digital/onechipbook/sim/test_sw/build/test.hex", mem);
    typedef enum {IDLE, READ, WRITE} state_t;
    state_t state;
    //NOTE: NOT TO BE USED FOR PERFORMANCE BENCHMARKING AS THE CYCLES
    //MAY NOT MATCH THE ACTUAL PERFORMANCE OF M4K MEMORY BLOCKS
    //TODO CHECK
    always_ff @(posedge clk) begin
        if(~resetn) begin
            bus.svalid <= 0;
            bus.rdata <= 0;
            state <= IDLE;
        end
        else begin
            case(state)
                IDLE: begin
                    bus.svalid <= 0;
                    if(bus.mvalid) begin
                        state <= (|bus.wstrb) ? WRITE : READ;
                    end
                end
                
                READ: begin
                    bus.rdata <= mem[bus.addr[12 : 2]];
                    state <= IDLE;
                    bus.svalid <= 1;
                end
                
                WRITE: begin
                    if(bus.wstrb[0]) mem[bus.addr[12 : 2]][7 : 0] <= bus.wdata[7 : 0];
                    if(bus.wstrb[1]) mem[bus.addr[12 : 2]][15 : 8] <= bus.wdata[15 : 8];
                    if(bus.wstrb[2]) mem[bus.addr[12 : 2]][23 : 16] <= bus.wdata[23 : 16];
                    if(bus.wstrb[3]) mem[bus.addr[12 : 2]][31 : 24] <= bus.wdata[31 : 24];
                    state <= IDLE;
                    bus.svalid <= 1;
                end
                
            endcase
        end
        
        
    end
    
endmodule
