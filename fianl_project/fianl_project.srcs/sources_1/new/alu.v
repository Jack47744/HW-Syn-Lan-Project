`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.12.2020 20:38:59
// Design Name: 
// Module Name: alu
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


module alu(
    output minus,
    output [15:0] z,
    output NA,
    input [13:0] firstNumber,
    input [13:0] secondNumber,
    input [1:0] mode,
    input reset
    );
reg NA;
reg minus = 0;
reg [14:0] tmp;
always@(mode or firstNumber or secondNumber)
begin
        if(reset == 1)
            minus = 0;
        if(mode == 2'b00)
        begin
            minus = 0;
            tmp = firstNumber + secondNumber;
            if(tmp > 9999)
                NA = 1;
            else
                NA = 0;
        end 
        else if(mode == 2'b01)
        begin
            if(firstNumber >= secondNumber)
            begin
                tmp = firstNumber - secondNumber;
                minus = 0;
            end
            else
            begin
                tmp = secondNumber - firstNumber;
                minus = 1;
            end    
        end
        else if(mode == 2'b10)
        begin
            tmp = firstNumber * secondNumber;
            minus = 0;
            if(tmp > 9999)
                NA = 1;
            else
                NA = 0;
        end
        else if(mode == 2'b11)
        begin
            tmp = firstNumber / secondNumber;
            minus = 0;
        end
end
reg [15:0] rom[10000:0];
wire [15:0] z;
initial $readmemb("rom.data", rom);
assign z = NA? 16'b1111111111111111 : rom[tmp];
endmodule
