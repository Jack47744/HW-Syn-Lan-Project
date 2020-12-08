`timescale 1ns / 1ps

module uart(
    output RsTx,
    output [7:0] outputData,
    output ready,
    input RsRx,
    input clk
    );
reg ready;
reg RsTx;
reg [7:0] outputData;
reg [13:0] counter = 0;
reg isReceiving = 0;
reg [9:0] data = 0;
reg [3:0] index = 0;

always@(posedge clk)
begin
    if(ready == 1) 
        ready = 0;
    counter = counter + 1;
    if(counter == 10416)
    begin
        counter = 0;
        if(isReceiving == 0 && RsRx)
        begin
            RsTx = data[9];
            data[9] = data[8];
            data[8] = data[7];
            data[7] = data[6];
            data[6] = data[5];
            data[5] = data[4];
            data[4] = data[3];
            data[3] = data[2]; 
            data[2] = data[1];
            data[1] = data[0];
            data[0] = 1;
        end
        else if(isReceiving==0 && RsRx==0)
        begin
            isReceiving = 1;
            data[9] = 0;
            index = 8;
        end
        else if(isReceiving)
        begin
            data[index] = RsRx;
            if(index == 0)
            begin
                isReceiving = 0;
                ready = 1;
                outputData = data[8:1];
            end
            else 
                index = index - 1;
        end
    end
    
end
endmodule
