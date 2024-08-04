`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/07/2024 04:56:14 PM
// Design Name: 
// Module Name: digitalSafe
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

module display(dig0,dig1,dig2,dig3,clk,rst,seg,an);
    input [3:0] dig0,dig1,dig2,dig3;
    input clk,rst;
    output reg [6:0] seg;
    output reg [3:0] an;

    wire [1:0] select;
    reg [3:0] dig;
    reg [25:0] clkdiv;

assign select = clkdiv[20:19];



always @(posedge clk or posedge rst) begin
    if(rst) clkdiv <= 0;
    else clkdiv <= clkdiv + 1;
end

always @(*) begin
    case(select)
        0 : begin an <= 4'b1110; dig <= dig0; end
        1 : begin an <= 4'b1101; dig <= dig1; end
        2 : begin an <= 4'b1011; dig <= dig2; end
        3 : begin an <= 4'b0111; dig <= dig3; end
    endcase
end

always @(*) begin 
    case(dig) 
        0 : seg <= 7'b1000000;
        1 : seg <= 7'b1111001;
        2 : seg <= 7'b0100100;
        3 : seg <= 7'b0110000;
        4 : seg <= 7'b0011001;
        5 : seg <= 7'b0010010;
        6 : seg <= 7'b0000010;
        7 : seg <= 7'b1111000;
        8 : seg <= 7'b0000000;
        9 : seg <= 7'b0010000;
        default : seg <= 7'b0111111;
    endcase
end
endmodule
module clk_fast(clkin,clkout);
    input clkin;
    output clkout;

    reg [25:0] clkdiv;

assign clkout = clkdiv[20];



always @(posedge clkin) begin
   clkdiv <= clkdiv + 1;
end
endmodule

module encoder(
    input [9:0] keys,
    output reg [3:0] code
);
always @(*)
    case(keys)
        10'b0000000001 : code <= 4'b0000;
        10'b0000000010 : code <= 4'b0001;
        10'b0000000100 : code <= 4'b0010;
        10'b0000001000 : code <= 4'b0011;
        10'b0000010000 : code <= 4'b0100;
        10'b0000100000 : code <= 4'b0101;
        10'b0001000000 : code <= 4'b0110;
        10'b0010000000 : code <= 4'b0111;
        10'b0100000000 : code <= 4'b1000;
        10'b1000000000 : code <= 4'b1001;
    endcase
endmodule

module digital_Safe(
    input clk, startLoginBtn, logoutBtn, rstpwBtn, cnf, backSpace,
    input [9:0] keypad,
    output [3:0] an,
    output [6:0] seg,
    output reg a,b,c,d,
    output p,
    output reg [2:0] rgb,
    output reg [6:0] error,
    output clko,
    output reg lck    
);   
    reg [3:0] pw0, pw1, pw2, pw3, x0, x1, x2, x3;
    reg [1:0] attempts;
    reg [4:0] state;
    
    parameter idle       = 5'b00000;
    parameter startLogin = 5'b00001;
    parameter loggedIn   = 5'b00010;
    parameter startRstPW = 5'b00011;
    parameter locked     = 5'b00100;
    
    parameter feeded1    = 5'b00101;
    parameter saved1     = 5'b00110;
    parameter backed1    = 5'b00111;    
    parameter feeded2    = 5'b01000;
    parameter saved2     = 5'b01001;
    parameter backed2    = 5'b01010;
    parameter feeded3    = 5'b01011;
    parameter saved3     = 5'b01100;
    parameter backed3    = 5'b01101;
    parameter feeded4    = 5'b01110;
    parameter saved4     = 5'b01111;
    parameter backed4    = 5'b10000;
    
    parameter feed1      = 5'b10001;
    parameter save1      = 5'b10010;
    parameter back1      = 5'b10011;
    parameter feed2      = 5'b10100;
    parameter save2      = 5'b10101;
    parameter back2      = 5'b10110;
    parameter feed3      = 5'b10111;
    parameter save3      = 5'b11000;
    parameter back3      = 5'b11001;
    parameter feed4      = 5'b11010;
    parameter save4      = 5'b11011;
    parameter back4      = 5'b11100;    
    
//    parameter bsc2 = 5'b11101;
//    parameter bsc3 = 5'b11110;
//    parameter bsc4 = 5'b11111;
    
    assign p = (keypad==10'b0000000000)?0:1;
    reg rst;
    
    reg [3:0] f;
    wire [3:0] encoded;
    
encoder E(keypad,encoded);
clk_fast C1(clk,clko); 
initial begin 
    {pw3, pw2, pw1, pw0} = {4'b0010, 4'b0011, 4'b0000, 4'b0001}; 
    {x3, x2, x1, x0}     = {4'b1111, 4'b1111, 4'b1111, 4'b1111}; 
    {a,b,c,d} = 4'b0111;
    attempts <= 2'b10; 
    state <= idle;
    rgb <= 3'b100;
    rst <= 0;
    error <= 7'b1001111;
    lck <= 1'b0;
end

display(x0,x1,x2,x3,clk,rst,seg,an);

always @(posedge clko) begin
    case(state)
        idle : begin 
//            {a,b,c,d} <= 4'b0000;
            {x3, x2, x1, x0}   = {4'b1111, 4'b1111, 4'b1111, 4'b1111};
            rgb <= 3'b100;
            if(startLoginBtn) state <= startLogin;
        end
        locked:
        begin
        lck <= 1'b1;
        end
        
        startLogin : begin
//            {a,b,c,d} <= 4'b0000;
            if(p) begin f <= encoded; state <= feeded1; end
        end
        feeded1 : begin
            error <= 7'b0000000;
            if(~p) begin state <= saved1; {x3,x2,x1,x0} <= {x2,x1,x0,f}; end 
        end
        saved1 : begin
//            {a,b,c,d} <= 4'b0001;
            if(backSpace) begin state <= backed1; {x3,x2,x1,x0} <= {4'b1111,x3,x2,x1}; end 
            else if(p) begin f <= encoded; state <= feeded2; end
        end
        backed1 : begin
            if(~backSpace) begin state <= startLogin; 
//            {x3,x2,x1,x0} <= {x2,x1,x0,f}; 
                  end 
        end
        
//        bsc2:
//        begin
//        {a,b,c,d} <= 4'b0001;
//        if(p) begin f <= encoded; state <= feeded2; end
//        end
        
        feeded2 : begin
            if(~p) begin state <= saved2; {x3,x2,x1,x0} <= {x2,x1,x0,f}; end 
        end
        saved2 : begin
//            {a,b,c,d} <= 4'b0011;
            if(backSpace) begin state <= backed2; {x3,x2,x1,x0} <= {4'b1111,x3,x2,x1}; end 
            else if(p) begin f <= encoded; state <= feeded3; end
        end
        backed2 : begin
            if(~backSpace) state <= saved1; 
        end
        
        
//        bsc3:
//        begin
//        {a,b,c,d} <= 4'b0011;
//        if(p) begin f <= encoded; state <= feeded3; end
//        end
        
        
        feeded3 : begin
            if(~p) begin state <= saved3; {x3,x2,x1,x0} <= {x2,x1,x0,f}; end 
        end
        saved3 : begin
//            {a,b,c,d} <= 4'b0111;
            if(backSpace) begin state <= backed3; {x3,x2,x1,x0} <= {4'b1111,x3,x2,x1}; end 
            else if(p) begin f <= encoded; state <= feeded4; end
        end
        backed3 : begin
            if(~backSpace) state <= saved2;
        end
        
        
//        bsc4:
//        begin
//        {a,b,c,d} <= 4'b0111;
//        if(p) begin f <= encoded; state <= feeded4; end
//        end

        feeded4 : begin
            if(~p) begin state <= saved4; {x3,x2,x1,x0} <= {x2,x1,x0,f}; end 
        end
        saved4 : begin
//            {a,b,c,d} <= 4'b1111;
            if(backSpace) begin state <= backed4; {x3,x2,x1,x0} <= {4'b1111,x3,x2,x1}; end 
            else if(cnf) begin 
                if({x3,x2,x1,x0}=={pw3,pw2,pw1,pw0}) state <= loggedIn; 
                else begin 
                    error <= 7'b1111001; 
                    if(attempts>0) begin 
                        state <= idle; attempts <= attempts - 1; 
                        if(attempts == 2'b10) 
                        begin
                          {a,b,c,d} <= 4'b0011 ; 
                           error <= 7'b1011011; 
                        end
                        if(attempts == 2'b01) 
                        begin  
                            {a,b,c,d} <= 4'b0001 ;
                            error <= 7'b0000110;  
                        end
                        end
                    else begin 
                        state <= locked;
                        {a,b,c,d} <= 4'b1111;
                    end 
                end
            end
        end
        backed4 : begin
            if(~backSpace) state <= saved3;  
        end
        
        
        
        
        loggedIn : begin
            rgb <= 3'b010;
            {x3, x2, x1, x0}   = {4'b1111, 4'b1111, 4'b1111, 4'b1111};
//            {a,b,c,d} <= 4'b0000;
            attempts <= 2'b10; 
            error <= 7'b0111001 ; 
            if(~logoutBtn) state <= idle;
            else if(rstpwBtn) state <= startRstPW;
        end
        
        startRstPW : begin
//            {a,b,c,d} <= 4'b0000;
            rgb <= 3'b001;
            {x3, x2, x1, x0}   = {4'b1111, 4'b1111, 4'b1111, 4'b1111};
            if(p) begin f <= encoded; state <= feed1; end
        end
        feed1 : begin
            if(~p) begin state <= save1; {x3,x2,x1,x0} <= {x2,x1,x0,f}; end 
        end
        save1 : begin
//            {a,b,c,d} <= 4'b0001;
            if(backSpace) begin state <= back1; {x3,x2,x1,x0} <= {4'b1111,x3,x2,x1}; end 
            else if(p) begin f <= encoded; state <= feed2; end
        end
        back1 : begin
            if(~backSpace) state <= startRstPW;
        end
        
        
        
        feed2 : begin
            if(~p) begin state <= save2; {x3,x2,x1,x0} <= {x2,x1,x0,f}; end 
        end
        save2 : begin
//            {a,b,c,d} <= 4'b0011;
            if(backSpace) begin state <= back2; {x3,x2,x1,x0} <= {4'b1111,x3,x2,x1}; end 
            else if(p) begin f <= encoded; state <= feed3; end
        end
        back2 : begin
            if(~backSpace) state <= save1; 
        end
        
        
        
        feed3 : begin
            if(~p) begin state <= save3; {x3,x2,x1,x0} <= {x2,x1,x0,f}; end 
        end
        save3 : begin
//            {a,b,c,d} <= 4'b0111;
            if(backSpace) begin state <= back3; {x3,x2,x1,x0} <= {4'b1111,x3,x2,x1}; end 
            else if(p) begin f <= encoded; state <= feed4; end
        end
        back3 : begin
            if(~backSpace) state <= save2;
        end
        
        
        
        feed4 : begin
            if(~p) begin state <= save4; {x3,x2,x1,x0} <= {x2,x1,x0,f}; end 
        end
        save4 : begin
//            {a,b,c,d} <= 4'b1111;
            if(backSpace) begin state <= back4; {x3,x2,x1,x0} <= {4'b1111,x3,x2,x1}; end 
            else if(cnf) begin {pw3,pw2,pw1,pw0} <= {x3,x2,x1,x0}; {x3,x2,x1,x0}<= {4'b1111, 4'b1111, 4'b1111, 4'b1111}; state <= loggedIn ; end
        end
        back4 : begin
            if(~backSpace) state <= save3;  
        end 
    endcase
end
endmodule