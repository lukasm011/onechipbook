`timescale 1ns/1ps
module controller (
    input logic clk,
    input logic resetn,
    output logic [9 : 0] alu_controlvec,
    output logic aluoutwrite,
    output logic memoutsrc,
    output logic pcwrite,
    output logic irwrite,
    output logic regsrc,
    output logic srcasel,
    output logic [1 : 0] srcbsel,
    output logic mvalid,
    output logic pcsrc,
    input logic [31 : 0] instr,
    input logic svalid,
    output logic [3 : 0] wstrb,
    output logic [3 : 0] rstrb,
    output logic reg_sign,
    output logic immsrc
);
    //Instruction sections
    logic [6 : 0] opcode;
    logic [2 : 0] funct3;
    logic [6 : 0] funct7;
    logic [11 : 0] imm;
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
    localparam logic [6 : 0] rtype = 7'b0110011;
    localparam logic [6 : 0] itype = 7'b0010011;
    localparam logic [6 : 0] loadtype = 7'b000011;
    localparam logic [6 : 0] stype = 7'b0100011;
    // Next signal values
    logic next_mvalid;
    //States
    typedef enum {FETCH, DECODE, R_EXEC, R_WB, I_EXEC, L_EXEC, L_MEM, L_WB, S_EXEC, S_MEM} state_t;
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
        rstrb = 0;
        alu_controlvec = 0;
        memoutsrc = 0;
        pcwrite = 0;
        irwrite = 0;
        regsrc = 0;
        srcasel = 0;
        srcbsel = 0;
        next_mvalid = 0;
        next_state = state;
        pcsrc = 0;
        opcode = instr[6 : 0];
        funct3 = instr[14 : 12];
        funct7 = instr[31 : 25];
        imm = instr[31 : 20];
        aluoutwrite = 0;
        wstrb = 0;
        reg_sign = 0;
        immsrc = 0;
        if(~resetn) begin
            next_state = FETCH;
            pcsrc = 1; //LOAD PROGADDR_START
            pcwrite = 1;
        end else begin
            case(state)
                FETCH: begin
                    next_mvalid = 1;
                    irwrite = 1;
                    srcbsel = 1; //Add 4
                    alu_controlvec[add_bit] = 1;
                    aluoutwrite = 1;
                    if(svalid) begin
                        next_mvalid = 0;
                        next_state = DECODE;
                    end
                end
                DECODE: begin
                    pcwrite = 1;
                    case(opcode)
                        rtype: begin
                            next_state = R_EXEC;
                        end
                        itype: begin
                            next_state = I_EXEC;
                        end
                        loadtype: begin
                            next_state = L_EXEC;
                        end
                        stype: begin
                            next_state = S_EXEC;
                        end
                        default: begin
                            //OPCODE NOT RECOGNIZED, SKIP
                            next_state = FETCH;
                        end
                    endcase
                end
                R_EXEC: begin
                    srcbsel = 0;
                    srcasel = 1;
                    aluoutwrite = 1;
                    case(funct3)
                        0: alu_controlvec[|funct7 ? sub_bit : add_bit] = 1;
                        1: alu_controlvec[sll_bit] = 1;
                        2: alu_controlvec[cmps_bit] = 1;
                        3: alu_controlvec[cmpu_bit] = 1;
                        4: alu_controlvec[xor_bit] = 1;
                        5: begin
                           alu_controlvec[sr_bit] = 1;
                           if(|funct7 == 0) alu_controlvec[arlog_bit] = 1; 
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
                    rstrb = 4'b1111;
                    next_state = FETCH;
                end
                I_EXEC: begin
                    srcbsel = 2;
                    srcasel = 1;
                    aluoutwrite = 1;
                    case(funct3)
                        0: alu_controlvec[add_bit] = 1;
                        1: alu_controlvec[sll_bit] = 1;
                        2: alu_controlvec[cmps_bit] = 1;
                        3: alu_controlvec[cmpu_bit] = 1;
                        4: alu_controlvec[xor_bit] = 1;
                        5: begin
                           alu_controlvec[sr_bit] = 1;
                           if(|imm[11:5] == 0) alu_controlvec[arlog_bit] = 1;  
                        end
                        6:
                            alu_controlvec[or_bit] = 1;
                        7:
                            alu_controlvec[and_bit] = 1;
                    endcase
                    next_state = R_WB;
                end
                L_EXEC: begin
                    srcbsel = 2;
                    srcasel = 1;
                    alu_controlvec[add_bit] = 1;
                    aluoutwrite = 1;
                    next_state = L_MEM;
                    next_mvalid = 1;
                end
                L_MEM: begin
                    memoutsrc = 1;
                    next_mvalid = 1;
                    if(svalid) begin
                        irwrite = 1;
                        next_mvalid = 0;
                        rstrb = 4'b1111;
                        regsrc = 0;
                        case(funct3)
                            0: begin
                                rstrb = 4'b0001;
                                reg_sign = 1;
                            end
                            1: begin
                                rstrb = 4'b0011;
                                reg_sign = 1;
                            end
                            2: begin
                                rstrb = 4'b1111;
                            end
                            4: begin
                                rstrb = 4'b0001;
                            end
                            default: begin
                                rstrb = 4'b0011;
                            end
                        endcase
                        next_state = FETCH;
                        //NOTE: IT IS POSSIBLE TO ADD A REGISTER WHICH WILL TAKE THE VALUES 
                        //AS THEY BECOME VALID TO AVOID TIMING COMPLICATIONS WITH THE REGFILE
                        //IN THIS CASE AN EXTRA STATE (L_WB) SHOULD BE ADDED TO HANDLE THIS
                    end
                end
                S_EXEC: begin
                    immsrc = 1;
                    srcbsel = 2;
                    srcasel = 1;
                    alu_controlvec[add_bit] = 1;
                    aluoutwrite = 1;
                    next_state = S_MEM;
                    next_mvalid = 1;
                end
                S_MEM: begin
                    case(funct3)
                        0: begin
                            wstrb = 4'b0001; //sb
                        end
                        1: begin
                            wstrb = 4'b0011; //sh
                        end
                        default: begin
                            wstrb = 4'b1111; //sw
                        end
                    endcase
                    memoutsrc = 1;
                    next_mvalid = 1;
                    if(svalid) begin
                        next_mvalid = 0;
                        next_state = FETCH;
                    end
                end
            endcase
        end
    end
endmodule
