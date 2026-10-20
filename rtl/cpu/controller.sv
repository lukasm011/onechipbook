module controller (
    input logic clk,
    input logic resetn,
    output logic regwrite,
    output logic [9 : 0] alu_controlvec,
    output logic memoutsrc,
    output logic pcwrite,
    output logic irwrite,
    output logic regsrc,
    output logic srcasel,
    output logic srcbsel,
    output logic mvalid,
    input logic svalid,
    input logic [31 : 0] instr
);
    //Instruction sections
    logic [6 : 0] opcode;
    logic [2 : 0] funct3;
    logic [6 : 0] funct7;
    //ALU Control bits
    localparam int add_bit = 0;
    localparam int sub_bit = 1;
    localparam int cmps_bit = 2;
    localparam int cmpu_bit = 3;
    localparam int xor_bit = 4;
    localparam int or_bit = 5;
    localparam int and_bit = 6;
    localparam int sll_bit = 7;
    localparam int sr_bit = 8;
    localparam int arlog_bit = 9;
    //Opcodes
    localparam int rtype = 7'b0110011;
    // Next signal values
    logic next_mvalid;
    //States
    typedef enum {FETCH, DECODE, R_EXEC, R_WB} state_t;
    state_t state, next_state;
    //
    // Clocked control
    //
    always_ff @(posedge clk) begin
        state <= next_state;
        mvalid <= next_mvalid;
    end
    //
    // Comb control
    //
    always_comb begin
        //
        // Default values
        //
        regwrite = 0;
        alu_controlvec = 0;
        memoutsrc = 0;
        pcwrite = 0;
        irwrite = 0;
        regsrc = 0;
        srcasel = 0;
        srcbsel = 0;
        next_mvalid = 0;
        next_state <= state;
        if(~resetn) begin
            next_state <= DECODE;
        end else begin
            case(state)
                FETCH: begin
                    memoutsrc = 0;
                    pcwrite = 0;
                    next_mvalid = 1;
                    irwrite = 1;
                    if(svalid) begin
                        irwrite = 0;
                        next_mvalid = 0;
                        next_state = DECODE;
                    end
                end
                DECODE: begin
                    case(opcode)
                        rtype: begin
                            next_state = R_EXEC;
                        end
                    endcase
                end
                R_EXEC: begin
                    srcbsel = 0;
                    srcasel = 1;
                    case(funct3)
                        0: alu_controlvec[funct7 ? sub_bit : add_bit] = 1;
                        1: alu_controlvec[sll_bit] = 1;
                        2: alu_controlvec[cmps_bit] = 1;
                        3: alu_controlvec[cmpu_bit] = 1;
                        4: alu_controlvec[xor_bit] = 1;
                        5: begin
                           alu_controlvec[sr_bit] = 1;
                           if(funct7) alu_controlvec[arlog_bit] = 1; 
                        end
                        6:
                            alu_controlvec[or_bit] = 1;
                        7:
                            alu_controlvec[and_bit] = 1;
                    endcase
                    next_state = R_WB;
                end
                R_WB: begin
                    regsrc = 1;
                    regwrite = 1;
                    next_state = DECODE;
                end
            endcase
        end
        opcode = instr[6 : 0];
        funct3 = instr[14 : 12];
        funct7 = instr[31 : 25];
    end
endmodule