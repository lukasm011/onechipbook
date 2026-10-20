module datapath(
    input logic clk,
    input logic resetn,
    //CONTROL SIGNALS
    input logic reg_enable,
    input logic [9 : 0] alu_controlvec,
    input logic memoutsrc,
    input logic pcwrite,
    input logic irwrite,
    input logic regsrc,
    input logic srcasel,
    input logic srcbsel,
    //BUS INTERFACE
    nativepkg bus
);
    logic [4 : 0] reg_addr_a, reg_addr_b, reg_addr_c;
    logic [31 : 0] reg_data_a, reg_data_b, reg_data_c, alu_srca, alu_srcb, alu_result;
    logic [31 : 0] pc, pc_next, instr_reg;

    regfile #(
        .STACKADDR('hffff)
    ) regfile_instance (
        .clk(clk),
        .resetn(resetn),
        .addr_a(reg_addr_a),
        .addr_b(reg_addr_b),
        .addr_c(reg_addr_c),
        .enable(reg_enable),
        .data_a(reg_data_a),
        .data_b(reg_data_b),
        .data_c(reg_data_c)
    );

    alu alu_instance (
        .srca(alu_srca),
        .srcb(alu_srcb),
        .result(alu_result),
        .controlvec(alu_controlvec)
    );

    //
    // Datapath clocked
    //
    always_ff @(posedge clk) begin
        //PC DATA
        if(pcwrite) pc <= alu_result;

        //IR DATA
        if(irwrite) instr_reg <= bus.rdata;

        //
    end
    //
    // Datapath combinational
    //
    always_comb begin
        // REGFILE SIGNALS
        reg_addr_a = instr_reg[19 : 15];
        reg_addr_b = instr_reg[24 : 20];
        reg_addr_c = instr_reg[11 : 7];
        reg_data_c = regsrc ? alu_result : bus.rdata;

        // ALU SIGNALS
        alu_srca = srcasel ? reg_data_a : pc;
        case(srcbsel)
            0: alu_srcb = reg_data_b;
            1: alu_srcb = 4;
            default: begin end //TODO 2 and 3
        endcase

        // BUS SIGNALS
        
    end

endmodule
