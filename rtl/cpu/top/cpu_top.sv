module cpu_top(
    input logic clk,
    input logic resetn,
    native_if bus
);
    logic pcwrite, irwrite, memoutsrc, regsrc, srcasel, pcsrc, aluoutwrite, sign, immsrc;
    logic [1 : 0] srcbsel;
    logic [9 : 0] alu_controlvec;
    logic [31 : 0] instr;
    logic [3 : 0] reg_strb;
    datapath datapath_instance (
        .clk(clk),
        .resetn(resetn),
        .alu_controlvec(alu_controlvec),
        .memoutsrc(memoutsrc),
        .pcwrite(pcwrite),
        .irwrite(irwrite),
        .regsrc(regsrc),
        .srcasel(srcasel),
        .srcbsel(srcbsel),
        .instr(instr),
        .pcsrc(pcsrc),
        .bus(bus),
        .reg_strb(reg_strb),
        .reg_sign(sign),
        .aluoutwrite(aluoutwrite),
        .immsrc(immsrc)
    );

    controller controller_instance (
        .clk(clk),
        .resetn(resetn),
        .alu_controlvec(alu_controlvec),
        .memoutsrc(memoutsrc),
        .pcwrite(pcwrite),
        .irwrite(irwrite),
        .regsrc(regsrc),
        .srcasel(srcasel),
        .srcbsel(srcbsel),
        .mvalid(bus.mvalid),
        .svalid(bus.svalid),
        .pcsrc(pcsrc),
        .instr(instr),
        .reg_sign(sign),
        .wstrb(bus.wstrb),
        .rstrb(reg_strb),
        .aluoutwrite(aluoutwrite),
        .immsrc(immsrc)
    );
endmodule
