
import risc_v_core_pkg::*;

module Instruction_reg(
                  input     logic           [31:0]    instruction,
                  output    instruction_t             instruction_o 

                  // output reg  [6:0]     opcode,
                  // output reg  [4:0]     rd,
                  // output reg  [4:0]     rs1,
                  // output reg  [4:0]     rs2,
                  // output reg  [2:0]     func3,
                  // output reg  [6:0]     func7
);


    assign  instruction_o.opcode      =  opcode_t'(instruction[ 6: 0]); 

    assign  instruction_o.funct3      =  instruction[14:12]; 
    assign  instruction_o.funct7      =  instruction[31:25]; 

    assign  instruction_o.rs1_addr    =  instruction[19:15]; 
    assign  instruction_o.rs2_addr    =  instruction[24:20]; 
    assign  instruction_o.rd_addr     =  instruction[11: 7]; 

    assign  instruction_o.imm_I       =  instruction[31:20]; 
    assign  instruction_o.imm_S       =  {  instruction[31:25], 
                                            instruction[11:7]}; 

    assign  instruction_o.imm_B       =  {  instruction[31]   ,
                                            instruction[7 ]   ,
                                            instruction[30:25],
                                            instruction[11:8] ,
                                            1'b0            } ;

    assign  instruction_o.imm_U       = { instruction[31:12]  ,
                                          12'b0             } ; 

    assign  instruction_o.imm_J       = { instruction[31]     ,
                                          instruction[19:12]  ,
                                          instruction[20]     ,
                                          instruction[30:21]  ,
                                          1'b0              } ; 

   always_comb begin
    case (instruction_o.opcode)
      R_type      : begin
        case (instruction_o.funct3)
          3'b000: instruction_o.instr_name  = (instruction_o.funct7==0)? ADD  : SUB;
          3'b001: instruction_o.instr_name  = SLL   ;
          3'b010: instruction_o.instr_name  = SLT   ;
          3'b011: instruction_o.instr_name  = SLTU  ;
          3'b100: instruction_o.instr_name  = XOR   ;
          3'b101: instruction_o.instr_name  = (instruction_o.funct7==0)? SRL  : SRA;
          3'b110: instruction_o.instr_name  = OR    ;
          3'b111: instruction_o.instr_name  = AND   ;
          default: instruction_o.instr_name  = ADD   ;
        endcase
      end
      load_type   : begin
        case (instruction_o.funct3)
          3'b000: instruction_o.instr_name  = LB    ;
          3'b001: instruction_o.instr_name  = LH    ;
          3'b010: instruction_o.instr_name  = LW    ;
          3'b100: instruction_o.instr_name  = LBU   ;
          3'b101: instruction_o.instr_name  = LHU   ;         
          default: instruction_o.instr_name  = LB    ;
        endcase
      end
      I_type      : begin
        case (instruction_o.funct3)
          3'b000: instruction_o.instr_name  = ADDI  ;
          3'b001: instruction_o.instr_name  = SLLI  ;
          3'b010: instruction_o.instr_name  = SLTI  ;
          3'b011: instruction_o.instr_name  = SLTIU ;
          3'b100: instruction_o.instr_name  = XORI  ;
          3'b101: instruction_o.instr_name  = (instruction_o.funct7==0)? SRLI  : SRAI;
          3'b110: instruction_o.instr_name  = ORI   ;
          3'b111: instruction_o.instr_name  = ANDI  ;
          default: instruction_o.instr_name  = ADDI  ;
        endcase
      end
      jalr_type   : instruction_o.instr_name  = JALR  ;
      S_type      : begin
        case (instruction_o.funct3)
          3'b000: instruction_o.instr_name  = SB    ;
          3'b001: instruction_o.instr_name  = SH    ;
          3'b010: instruction_o.instr_name  = SW    ; 
          default: instruction_o.instr_name  = SB    ;
        endcase
      end
      B_type      : begin
        case (instruction_o.funct3)
          3'b000: instruction_o.instr_name  = BEQ   ;
          3'b001: instruction_o.instr_name  = BNE   ;
          3'b100: instruction_o.instr_name  = BLT   ;
          3'b101: instruction_o.instr_name  = BGE   ;
          3'b110: instruction_o.instr_name  = BLTU  ;
          3'b111: instruction_o.instr_name  = BGEU  ;
          default: instruction_o.instr_name  = BEQ   ;
        endcase
      end
      lui_type    : instruction_o.instr_name  = LUI     ;
      auipc_type  : instruction_o.instr_name  = AUIPC   ;
      J_type      : instruction_o.instr_name  = JAL     ;
      default:  instruction_o.instr_name  = NOP     ;
    endcase
   end

endmodule
