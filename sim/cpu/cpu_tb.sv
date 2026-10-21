`timescale 1ns/1ps


module cpu_tb;
    logic clk, resetn;
    nativepkg bus();
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
        $dumpfile("obj_dir/waveform.fst");
        $dumpvars;
        clk = 0;
        resetn = 1;
        assert_reset();
        repeat(40) @(posedge clk);
        $finish;
    end
    
    
endmodule
