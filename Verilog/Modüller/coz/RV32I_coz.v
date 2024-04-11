`timescale 1ns / 1ps

module RV32I_coz(
   input [31:0] pipereg0,
   input [31:0] regfile[31:0],
   output reg [4:0] a_op, a_rd,
   output reg [31:0] a_in1, a_in2, a_in3
    );

//global
wire [4:0]rd = pipereg0[11:7];
wire [2:0]func3 = pipereg0[14:12];
wire [4:0]rs1 = pipereg0[19:15];
wire [6:0] op = pipereg0[6:0];

//U-type
wire [19:0]immU = pipereg0[31:12];

//I-type
wire [11:0]immI = pipereg0[31:20];
wire [4:0]shamt = pipereg0[24:20];
wire [6:0]offset = pipereg0[31:24];

//R-type
wire [4:0]rs2 = pipereg0[24:20];

//B-type
wire [11:0]immB = {pipereg0[31],pipereg0[7],pipereg0[30:25],pipereg0[11:8]};

//S-type
wire [11:0]immS = {pipereg0[31:25],pipereg0[11:7]};

//J-type
wire [31:0]immJ = {{12{pipereg0[31]}},pipereg0[19:12],pipereg0[20],pipereg0[30:21],1'b 0};

always@(*) begin
   case (op)
      7'b 0010011: begin //Register-Immediate
         case (func3)
            3'b 001: begin //SLLI
               if(offset == 7'b 0) begin
                  a_in1 <= regfile[rs1];
                  a_in2 <= shamt;
                  a_op <= {2'b 0,func3};
                  a_rd <= rd;
               end
            end
            3'b 101: begin //SRLI & SRAI
               if({offset[6],offset[4:0]} == 6'b 0) begin
                  a_in1 <= regfile[rs1];
                  a_in2 <= {offset[5], shamt};
                  a_op <= {2'b 0, func3};
                  a_rd <= rd;
               end
            end
            default: begin // ADDI, SLTI, SLTIU, XORI, ORI & ANDI
               a_in1 <= regfile[rs1];
               a_in2 <= {{20{immI[11]}},immI};
               a_op <= {2'b 0, func3};
               a_rd <= rd;
            end
         endcase
      end
      7'b 0110111: begin //LUI
         a_in1 <= {immU,12'b 0};
         a_op <= 5'b 11100;
         a_rd <= rd;
      end
      7'b 0010111: begin //AUIPC
         a_in1 <= {immU,12'b 0};
         a_op <= 5'b 11101;
         a_rd <= rd;
      end
      7'b 1101111: begin //JAL
         a_in1 <= immJ;
         a_op <= {5'b 11110};
         a_rd <= rd;
      end
      7'b 1100111: begin //JALR
         a_in1 <= regfile[rs1];
         a_in2 <= {{20{immI[11]}},immI};
         a_op <= {5'b 11111};
         a_rd <= rd;
      end
      7'b 1100011: begin //Conditional Branches // BEQ, BNE, BLT, BGE, BLTU & BGEU
         case (func3)
            3'b 010: begin //err
            end
            3'b 011: begin//err
            end
            default: begin
               a_in1 <= regfile[rs1];
               a_in2 <= regfile[rs2];
               a_in3 <= {{19{immB[11]}},immB,1'b 0};
               a_op <= {2'b 01, func3};
            end
         endcase
      end
      7'b 0110011: begin //Register-Register
         case (func3)
            3'b 000: begin //ADD & SUB
               if({offset[6],offset[4:0]} == 6'b 0) begin
                  if(offset[5]) begin
                     a_op <= 5'b 01010;
                  end else begin
                     a_op <= 5'b 01011;
                     a_in1 <= regfile[rs1];
                     a_in2 <= regfile[rs2];
                     a_rd <= rd;
                  end
               end
            end
            3'b 101: begin //SRL & SRA
               if({offset[6],offset[4:0]} == 6'b 0) begin
                  a_in1 <= regfile[rs1];
                  a_in2 <= {offset[5], regfile[rs2][4:0]};
                  a_op <= {2'b 0, func3};
                  a_rd <= rd;
               end
            end
            default: begin //SLL, SLT, SLTU, XOR, OR & AND
               if(offset == 7'b 0) begin
                  a_in1 <= regfile[rs1];
                  a_in2 <= regfile[rs2];
                  a_op <= {2'b 0, func3};
                  a_rd <= rd;
               end
            end
         endcase
      end
      7'b 0000011: begin //Load
         case (func3)
            3'b 011: begin //err
               end
            3'b 110: begin //err
               end
            3'b 111: begin //err
               end
            default: begin
               a_in1 <= regfile[rs1];
               a_in2 <= {{20{immI[11]}},immI};
               a_op <= {2'b 10, func3};
               a_rd <= rd;
            end
         endcase
      end
      7'b 0100011: begin //Store
         case (func3)
            3'b 011: begin //err
               end
            3'b 100: begin //err
               end
            3'b 101: begin //err
               end
            3'b 110: begin //err
               end
            3'b 111: begin //err
               end
            default: begin
               a_in1 <= regfile[rs1];
               a_in2 <= regfile[rs2];
               a_in3 <= {{20{immS[11]}},immS};
               a_op <= {2'b 11, func3};
               a_rd <= rd;
            end
         endcase
      end
   endcase
end
endmodule
