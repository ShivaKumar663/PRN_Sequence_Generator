`timescale 1ns / 1ps
//==============================================================
//                          TOP MODULE
//==============================================================
module PRN_SEQ_Synth_50MHZ(PRN_Seq_out,CLK,RST,PRN_id,RD_ENE);
input CLK;
input RST;
input wire [3:0]PRN_id; //ID ranging from 0-15 we can access from 1-14
output PRN_Seq_out;  //Actual generated sequence which will be 1023 bit long
 wire [1:10] G2_ini;
output wire RD_ENE; // Read enable signal....when this is high at the posedge then only id will be passed to the generator

PRN_id PRN_ID(.id_clk(CLK),.id_rst(RST),.rd_en(RD_ENE),.g2_ini(G2_ini),.id(PRN_id));
PRN_seq_gen PRN_SEQ_GEN(.clk(CLK),.rst(RST),.g2_in(G2_ini),.rd_ene(RD_ENE),.out(PRN_Seq_out));

endmodule
//==============================================================
//                    MODULE - PRN ID SELECTOR
//==============================================================
module PRN_id(id_clk,id_rst,rd_en,id,g2_ini);
input id_clk;
input id_rst;
output reg rd_en;
input wire [3:0]id;  //ID ranging from 0-15 we can access from 1-14
output reg [1:10]g2_ini;

// Assigning the Initial Conditions for G2 Registers as Parameters 

parameter 	SAT_1 = 10'b1111011100,
			SAT_2 = 10'b1011111010,
  			SAT_3 = 10'b1000110001,
  			SAT_4 = 10'b1101010100,
  			SAT_5 = 10'b1000100101,
  			SAT_6 = 10'b0011010010,
  			SAT_7 = 10'b0111000100,
  			SAT_8 = 10'b0110010010,
  			SAT_9 = 10'b0111000011,
  			SAT_10 = 10'b0111110101,
  			SAT_11 = 10'b1000100111,
  			SAT_12 = 10'b1001011011,
  			SAT_13 = 10'b1010001010,
  			SAT_14 = 10'b1011000010;
  
always@(posedge id_clk)
begin 

if(id_rst)
  begin
  g2_ini <= 10'b0000000000;
  rd_en <= 1'b0;
  end
  
 //Based on the ID from 1-14 the initial conditions will be assigned to the registers
else
begin
    rd_en <= 1;
    case(id)
    4'd1:g2_ini <= SAT_1;
    4'd2:g2_ini <= SAT_2;
    4'd3:g2_ini <= SAT_3;
    4'd4:g2_ini <= SAT_4;
    4'd5:g2_ini <= SAT_5;
    4'd6:g2_ini <= SAT_6;
    4'd7:g2_ini <= SAT_7;
    4'd8:g2_ini <= SAT_8;
    4'd9:g2_ini <= SAT_9;
    4'd10:g2_ini <= SAT_10;
    4'd11:g2_ini <= SAT_11;
    4'd12:g2_ini <= SAT_12;
    4'd13:g2_ini <= SAT_13;
    4'd14:g2_ini <= SAT_14;
    
    default:g2_ini <= 10'b0000000000; //default value of the register which prevents the inference of unecessary latch
    endcase
end
end
endmodule

//================================================================================
//                          MODULE - PRN SEQ GENERATOR
//================================================================================
 
module PRN_seq_gen(clk,rst,g2_in,rd_ene,out);
input clk,rst;
input [1:10]g2_in;
input rd_ene;
output  out;
 reg [1:10]g1,g2;
 reg [9:0]count;
 reg flag;
 reg PRN;
always@(posedge clk)
begin
    if(rst)
        begin 
          g1 <= 10'b0000000000;
          g2 <= 10'b0000000000;
          count <= 1;
           flag <= 0;  
           PRN <= 0;
        end
  
  
  else if(flag && (rst == 0))
    begin
          if(count == 1024) //When count reaches to 1024 the loop will be exited...the generation of sequence will be stopped
            begin
              count <= 1;
              g2 <= g2_in;
              g1  <= 10'b1111111111;
            end
    
          else 				//Here the actual generation is going to take place
            begin
              count <= count + 1; 
              g1 <= {(g1[10]^g1[3]),g1[1:9]};	//This is right shift operation
              g2 <= {((g2[10]^g2[9]^g2[8])^(g2[6]^g2[3]^g2[2])),g2[1:9]};
              PRN <= g1[10]^g2[10];
            end 
    end
  
  else if(rd_ene)
    begin
          g1 <= 10'b1111111111;
          g2 <= g2_in;
          count <= 1;
          flag <= 1;
      end
end

  assign out = PRN;// The outputs of the both registers will be XORed here which is LSB
endmodule





