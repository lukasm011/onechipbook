`timescale 1ns/1ps
module datapath#(
    parameter integer PROGADDR_START = 'h0
)(
    input logic clk,
    input logic resetn,
    //CONTROL SIGNALS
    input logic [3 : 0] reg_strb,
    input logic [9 : 0] alu_controlvec,
    input logic aluoutwrite,
    input logic reg_sign,
    input logic memoutsrc,
    input logic pcwrite,
    input logic irwrite,
    input logic regsrc,
    input logic srcasel,
    input logic [1 : 0] srcbsel,
    input logic pcsrc,
    input logic immsrc,
    output logic [31 : 0] instr,
    //BUS INTERFACE
    native_if bus
);
    logic [4 : 0] reg_addr_a, reg_addr_b, reg_addr_c;
    logic [31 : 0] reg_data_a, reg_data_b, reg_data_c, alu_srca, alu_srcb, alu_result_next, alu_result;
    logic [31 : 0] pc, pc_next, rf_out [2], rf_out_next[2], imm_sext;

    regfile #(
        .STACKADDR('hffff)
    ) regfile_instance (
        .clk(clk),
        .resetn(resetn),
        .addr_a(reg_addr_a),
        .addr_b(reg_addr_b),
        .addr_c(reg_addr_c),
        .data_a(reg_data_a),
        .data_b(reg_data_b),
        .data_c(reg_data_c),
        .strb(reg_strb),
        .sign(reg_sign)
    );

    alu alu_instance (
        .srca(alu_srca),
        .srcb(alu_srcb),
        .result(alu_result_next),
        .controlvec(alu_controlvec)
    );

    //
    // Datapath clocked
    //
    always_ff @(posedge clk) begin
        //PC DATA
        if(pcwrite) pc <= pc_next;

        //IR DATA
        if(irwrite) instr <= bus.rdata;

        //ALU OUT
        if(aluoutwrite) alu_result <= alu_result_next;

        //REGFILE DATA
        rf_out <= rf_out_next;
    end
    //
    // Datapath combinational
    //
    always_comb begin
        // REGFILE SIGNALS
        reg_addr_a = instr[19 : 15];
        reg_addr_b = instr[24 : 20];
        reg_addr_c = instr[11 : 7];
        reg_data_c = regsrc ? alu_result : bus.rdata;

        // ALU SIGNALS
        alu_srca = srcasel ? rf_out[0] : pc;
        //Sign extension:
        //The lowest 5 bits of the immediate can come either from the continuous I-type block
        //or from imm[4 : 0] field of the S-type block. The top 26 bits always come from the same source.
        imm_sext = {{20{instr[31]}}, instr[31 : 25], immsrc ? instr[11 : 7] : instr[24 : 20]};
        case(srcbsel)
            0: alu_srcb = rf_out[1];
            1: alu_srcb = 4; //for PC incrementation
            2: alu_srcb = imm_sext;
            default: begin end //TODO and 3
        endcase

        // PC SIGNALS
        pc_next = pcsrc ? PROGADDR_START : alu_result;

        // REGFILE SIGNALS
        rf_out_next[0] = reg_data_a;
        rf_out_next[1] = reg_data_b;
    end 
    // BUS SIGNALS
    assign bus.addr = memoutsrc ? alu_result : pc;
    assign bus.wdata = rf_out[1];
endmodule
