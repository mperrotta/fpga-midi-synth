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


module test_midi_in();

reg clk_31250 = 1'b0;
always #16000 clk_31250 = ~clk_31250;

logic data_in;

bit [7:0] status;
bit [7:0] byte1;
bit [7:0] byte2;
bit rx_signal = 0;


midi_in UUT (.clk31250(clk_31250),
             .input_signal(data_in),
             .o_status_byte(status),
             .o_data_byte1(byte1),
             .o_data_byte2(byte2),
             .o_data_rx_signal(rx_signal));

int index = 0;
bit [89:0] data;

initial begin
    data[14:0] = 15'b111111111111111;
    data[15] = 1'b0; //start 
    data[23:16] = 8'b10000011; //status
    data[24] = 1'b1; //stop 
    data[25] = 1'b0; //start 
    data[33:26] = 8'b00000010; //byte 1
    data[34] = 1'b1; //stop 
    data[35] = 1'b0; //start 
    data[43:36] = 8'b00000100; //byte 2
    data[44] = 1'b1; //stop 
    data[59:45] = 15'b111111111111111;
    data[60] = 1'b0; //start 
    data[68:61] = 8'b10000100; //status
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
always @ (posedge rx_signal) begin
   if (msg_index == 0) begin
        assert (status ==  8'b11000001 && byte1 == 8'b01000000 && byte2 == 8'b00100000) else $error("It's gone wrong");
        msg_index++;
   end
   else if (msg_index == 1) 
        assert (status ==  8'b11111111 && byte1 == 8'b00010000 && byte2 == 8'b00001000) else $error("It's gone wrong");
   else
        msg_index = 0;
end

endmodule
