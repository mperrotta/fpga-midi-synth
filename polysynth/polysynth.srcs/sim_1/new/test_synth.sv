`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/28/2025 03:23:20 PM
// Design Name: 
// Module Name: test_synth
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module test_synth(

    );
    
reg clk_100MHZ = 1'b0;
always #5 clk_100MHZ = ~clk_100MHZ;

reg clk_31250 = 1'b0;
always #16000 clk_31250 = ~clk_31250;

logic data_in;

synth_top UUT (.clk_100MHz(clk_100MHZ),
             .midi_data_bit(data_in));

int index = 0;

bit [74:0] data;

initial begin
    data[14:0] = 15'b111111111111111;
    data[15] = 1'b0; //start 
    data[23:16] = 8'b10010000; //status 0x90
    data[24] = 1'b1; //stop 
    data[25] = 1'b0; //start 
    data[33:26] = 8'b01000101; //byte 1
    data[34] = 1'b1; //stop 
    data[35] = 1'b0; //start 
    data[43:36] = 8'b00000000; //byte 2
    data[44] = 1'b1; //stop 
    data[45] = 1'b0; //start 
    data[53:46] = 8'b10000000; //status 0x80
    data[54] = 1'b1; //stop 
    data[55] = 1'b0; //start 
    data[63:56] = 8'b01000101; //byte 1
    data[64] = 1'b1; //stop 
    data[65] = 1'b0; //start 
    data[73:66] = 8'b00000000;
    data[74] = 1'b1; //stop 


end

always @ (posedge clk_31250) begin
   data_in = data[index];
   
   index = index+1;
   
 if (index >= 44) begin
    data_in = 1'b1;
    #2000000000;
    index = 0;
   end 
end

endmodule
