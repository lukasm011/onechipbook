`timescale 1ns/1ps


module cpu_tb;
    logic clk, resetn;
    native_if bus();
    cpu_top dut (
        .clk(clk),
        .resetn(resetn),
        .bus(bus)
    );

    dummy_mem #(
        .MEM_WORDS(1024)
    ) dummy_mem_instance (
        .clk(clk),
        .resetn(resetn),
        .bus(bus)
    );

    task assert_reset();
        resetn = 0;
        repeat(5) @(posedge clk);
        resetn = 1;
    endtask

    always #5 clk <= ~clk;
    initial begin
        integer progsize = 0, expected_x5 = 0, expected_x6 = 0;
        if($value$plusargs("PROGSIZE=%d", progsize))
            $display("PROGSIZE OF %d RECEIVED", progsize);
        else
            progsize = 44; //default value
        $dumpfile("obj_dir/waveform.fst");
        $dumpvars;
        clk = 0;
        resetn = 1;
        assert_reset();
        while(dut.datapath_instance.pc != progsize) begin
            @(posedge clk);
        end
        for(integer i = 1; i < 32; i++) begin
            $display("%d: %h", i, dut.datapath_instance.regfile_instance.registers[i]);
        end
        $finish;
    end


endmodule
