/////////////////////////////test bench/////////////////////////////////////

`timescale 1ns / 1ps
module PRN_SEQ_Synth_tb;
reg CLK;                   
reg RST;      
wire RD_ENE;                
reg [3:0]PRN_id;                  
wire PRN_Seq_out;          
//integer  bit_file;

PRN_SEQ_Synth_50MHZ dut(PRN_Seq_out,CLK,RST,PRN_id,RD_ENE);


initial begin
PRN_id = 4'd14;
end

initial begin
CLK = 0;
forever #10 CLK = ~CLK;
end


initial begin
RST = 1;
#12 RST = 0;
end 

initial begin
   $monitor($time," \t PRN_ID = %d \t RD_ENE = %b  \t PRN_Seq_out = %b ",PRN_id,RD_ENE,PRN_Seq_out);
  #10235 $finish;
end
 
endmodule
