module alu(
    input logic [31 : 0] srca,
    input logic [31 : 0] srcb,
    output logic [31 : 0] result,
    input logic [9 : 0] controlvec
);
    /************************/
    /* controlvec structure */
    /*[0] - add             */
    /*[1] - sub             */
    /*[2] - cmps            */
    /*[3] - cmpu            */
    /*[4] - xor             */
    /*[5] - or              */
    /*[6] - and             */
    /*[7] - sll             */
    /*[8] - sr              */
    /*[9] - a/l             */
    /************************/
    
    //addsub
    logic [32 : 0] add_res;
    logic [31 : 0] add_srca, add_srcb;
    
    assign add_res = {1'b0, add_srca} + {1'b0, add_srcb} + {31'h0, (|controlvec[3 : 1])};
    assign add_srca = srca;
    assign add_srcb = | {controlvec[1], controlvec[2], controlvec[3]}  ? ~srcb : srcb;
    //cmps
    logic cmps_res;
    assign cmps_res = (srca[31] & ~srcb[31]) | (srca[31] & srcb[31] & add_res[31]) | (~srca[31] & ~srcb[31] & add_res[31]);
    //cmpu
    logic cmpu_res;
    assign cmpu_res = (~srca[31] & srcb[31]) | (~(srca[31] ^ srcb[31]) & add_res[31]);
    //xor
    logic [31 : 0] xor_res;
    assign xor_res = srca ^ srcb;
    //or
    logic [31 : 0] or_res;
    assign or_res = srca | srcb;
    //and
    logic [31 : 0] and_res;
    assign and_res = srca & srcb;
    //sll
    logic [31 : 0] sll_res;
    always_comb begin
        logic [4 : 0] from_index;
        for(logic [5 : 0] i = 0; i <= 31; i++) begin
            from_index = i[4 : 0] - srcb[4 : 0];
            sll_res[i] = from_index < 0 ? 0 : srca[from_index];
        end
    end
    //sr
    logic [31 : 0] sr_res;
    always_comb begin
        logic [4 : 0] from_index;
        for(logic [5 : 0] i = 0; i <= 31; i++) begin
            from_index = i[4 : 0] + srcb[4 : 0];
            sr_res[i] = from_index > 31 ? srca[31] & controlvec[9] : srca[from_index];
        end
    end
    //result mux
    assign result = | controlvec[1 : 0] ? add_res[31 : 0] : controlvec[2] ? {31'h0, cmps_res} :
                    controlvec[3] ? {31'h0, cmpu_res} : controlvec[4] ? xor_res : controlvec[5] ? or_res :
                    controlvec[6] ? and_res : controlvec[7] ? sll_res : controlvec[8] ? sr_res : 0;

endmodule
