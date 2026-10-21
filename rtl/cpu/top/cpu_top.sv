module cpu_top(
    input logic clk,
    input logic resetn,
    nativepkg bus
);
    logic regwrite, pcwrite, irwrite, memoutsrc, regsrc, srcasel, pcsrc;
    logic [1 : 0] srcbsel;
    logic [9 : 0] alu_controlvec;
    logic [31 : 0] instr;
    datapath datapath_instance (
        .clk(clk),
        .resetn(resetn),
        .reg_enable(regwrite),
        .alu_controlvec(alu_controlvec),
        .memoutsrc(memoutsrc),
        .pcwrite(pcwrite),
        .irwrite(irwrite),
        .regsrc(regsrc),
        .srcasel(srcasel),
        .srcbsel(srcbsel),
        .instr(instr),
        .pcsrc(pcsrc),
        .bus(bus)
    );

    controller controller_instance (
        .clk(clk),
        .resetn(resetn),
        .regwrite(regwrite),
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
        .instr(instr)
    );
endmodule
