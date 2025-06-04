`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/17/2025 09:50:09 AM
// Design Name: 
// Module Name: test_midi_in
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


module test_midi_top();

reg clk_100MHZ = 1'b0;
always #5 clk_100MHZ = ~clk_100MHZ;

reg clk_31250 = 1'b0;
always #16000 clk_31250 = ~clk_31250;

logic data_in;

//clk_100MHz : IN STD_LOGIC;
//midi_data_bit  : IN STD_LOGIC;
//SEG        : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
//AN         : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);  
//DP         : OUT STD_LOGIC

test_midi UUT (.clk_100MHz(clk_100MHZ),
             .midi_data_bit(data_in));

int index = 0;

bit [89:0] data;

initial begin
    data[14:0] = 15'b111111111111111;
    data[15] = 1'b0; //start 
    data[23:16] = 8'b11000001; //status
    data[24] = 1'b1; //stop 
    data[25] = 1'b0; //start 
    data[33:26] = 8'b01000000; //byte 1
    data[34] = 1'b1; //stop 
    data[35] = 1'b0; //start 
    data[43:36] = 8'b00100000; //byte 2
    data[44] = 1'b1; //stop 
    data[59:45] = 15'b111111111111111;
    data[60] = 1'b0; //start 
    data[68:61] = 8'b11111111; //status
    data[69] = 1'b1; //stop 
    data[70] = 1'b0; //start 
    data[78:71] = 8'b00010000;; //byte 1
    data[79] = 1'b1; //stop 
    data[80] = 1'b0; //start 
    data[88:81] = 8'b00001000;;
    data[89] = 1'b1; //stop 


end

always @ (posedge clk_31250) begin
   data_in = data[index];
   
   index = index+1;
   
 if (index >= 89) begin
    index = 0;
   end 
end

int msg_index = 0;
always @ (posedge UUT.midi_signal) begin
   if (msg_index == 0) begin
        assert (UUT.midi_status ==  8'b10000011 && UUT.midi_data1 == 8'b00000010 && UUT.midi_data2 == 8'b00000100) else $error("It's gone wrong");
        msg_index++;
   end
   else if (msg_index == 1) begin
        assert (UUT.midi_status ==  8'b11111111 && UUT.midi_data1 == 8'b11111111 && UUT.midi_data2 == 8'b11111111) else $error("It's gone wrong");
        msg_index = 0;
   end
end

endmodule
