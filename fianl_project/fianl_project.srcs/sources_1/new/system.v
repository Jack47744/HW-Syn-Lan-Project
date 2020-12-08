module system(
    output [6:0] seg,
    output dp,
    output [3:0] an,
    output [15:0] LED,
    output RsTx,
    input RsRx,
    input clk,
    input btnC
    );
reg [13:0] firstNumber;
reg [13:0] secondNumber;
wire minus;
wire NA;
wire [15:0] ans;

wire [7:0] getData;
wire ready;
uart u(RsTx, getData, ready, RsRx, clk);
reg [3:0] tmp;
wire [7:0] myData;
assign myData[0] = getData[7];
assign myData[1] = getData[6];
assign myData[2] = getData[5];
assign myData[3] = getData[4];
assign myData[4] = getData[3];
assign myData[5] = getData[2];
assign myData[6] = getData[1];
assign myData[7] = getData[0];

always@(myData)
begin
    case(myData)
        8'b00110000 : tmp = 4'b0000; // 0
        8'b00110001 : tmp = 4'b0001;
        8'b00110010 : tmp = 4'b0010;
        8'b00110011 : tmp = 4'b0011;
        8'b00110100 : tmp = 4'b0100;
        8'b00110101 : tmp = 4'b0101;
        8'b00110110 : tmp = 4'b0110;
        8'b00110111 : tmp = 4'b0111;
        8'b00111000 : tmp = 4'b1000;
        8'b00111001 : tmp = 4'b1001; // 9
        8'b00101011 : tmp = 4'b1010; // plus        10
        8'b00101101 : tmp = 4'b1011; // minus       11
        8'b00101010 : tmp = 4'b1100; // multiply    12
        8'b00101111 : tmp = 4'b1101; // division    13
        8'b00001101 : tmp = 4'b1110; // enter       14
        8'b01111010 : tmp = 4'b1111; // reset       15
    endcase
end

reg [3:0] state = 0;
reg [3:0] num0;
reg [3:0] num1;
reg [3:0] num2;
reg [3:0] num3;
always@(state or reset)
begin
    if(reset)
    begin
        num3 = 0;
        num2 = 0;
        num1 = 0;
        num0 = 0;
    end
    else if(state == 0)
    begin
        num3 = num13;
        num2 = num12;
        num1 = num11;
        num0 = num10;
    end
    else if(state == 1)
    begin
        num3 = num23;
        num2 = num22;
        num1 = num21;
        num0 = num20;
    end
    else if(state == 2)
    begin
        num3 = ans[15:12];
        num2 = ans[11:8];
        num1 = ans[7:4];
        num0 = ans[3:0];
    end
end
//assign num3 = reset? 0 : ans[15:12];
//assign num2 = reset? 0 : ans[11:8];
//assign num1 = reset? 0 : ans[7:4];
//assign num0 = reset? 0 : ans[3:0];

reg [3:0] num10;
reg [3:0] num11;
reg [3:0] num12;
reg [3:0] num13;

reg [3:0] num20;
reg [3:0] num21;
reg [3:0] num22;
reg [3:0] num23;

assign LED[15] = minus? 1 : 0; //negative number
assign LED[0] = (mode==0 && ledON)? 1 : 0;
assign LED[1] = (mode==1 && ledON)? 1 : 0;
assign LED[2] = (mode==2 && ledON)? 1 : 0;
assign LED[3] = (mode==3 && ledON)? 1 : 0;
reg ledON = 0; 
reg [1:0] mode;
reg runCalculation = 0;
reg reset = 0;
reg [2:0] counter1;
reg [2:0] counter2;
alu alu1(minus, ans, NA, firstNumber, secondNumber, mode, r);
always@(posedge clk)
begin
    if(btnC==1)
    begin
            state = 0;
            num13 = 0;
            num12 = 0;
            num11 = 0;
            num10 = 0;
            num23 = 0;
            num22 = 0;
            num21 = 0;
            num20 = 0;
            firstNumber = 0;
            secondNumber = 0;
            reset = 1;  
            ledON = 0;  
            counter1 = 0;
            counter2 = 0;
    end
    if(ready == 1)
    begin
        
        if(state == 0)
        begin
           reset = 0;
           if((tmp==0 || tmp==1 || tmp==2 || tmp==3 || tmp==4 || tmp==5 || tmp==6 || tmp==7 ||tmp==8 || tmp==9) && (counter1 == 0 || counter1 == 1 || counter1 == 2 || counter1 == 3))
           begin
                num13 = num12;
                num12 = num11;
                num11 = num10;
                num10 = tmp;
                counter1 = counter1 + 1;
           end
           else if((tmp == 10 || tmp==11 || tmp==12 || tmp==13) && state == 0)
           begin
                ledON = 1;
                state = 1;
                if(tmp == 10)
                    mode = 0;
                else if(tmp == 11)
                    mode = 1;
                else if(tmp == 12)
                    mode = 2;
                else if(tmp == 13)
                    mode = 3;
           end
        end
        else if(state == 1)
        begin
           if((tmp==0 || tmp==1 || tmp==2 || tmp==3 || tmp==4 || tmp==5 || tmp==6 || tmp==7 ||tmp==8 || tmp==9) && (counter2==0 || counter2 == 1 || counter2 ==2 || counter2 == 3))
           begin
                num23 = num22;
                num22 = num21;
                num21 = num20;
                num20 = tmp;
                counter2 = counter2 + 1;
           end
           else if(tmp == 14)
           begin
                firstNumber = 1000*num13 + 100*num12 + 10*num11 + num10;
                secondNumber = 1000*num23 + 100*num22 + 10*num21 + num20;
                state = 2;
           end
        end  
    end
end


wire targetClk;
wire an0, an1, an2, an3;
assign an = {an3, an2, an1, an0};
wire[18:0] tclk;
assign tclk[0] = clk;
genvar c; 
generate for(c=0; c<18; c=c+1)
begin
    clockDiv fdiv(tclk[c+1], tclk[c]);
end endgenerate
clockDiv fdivTarget(targetClk, tclk[18]);
quadSevenSeg q7seg(seg, dp, an0, an1, an2, an3, num0, num1, num2, num3, targetClk);

endmodule
