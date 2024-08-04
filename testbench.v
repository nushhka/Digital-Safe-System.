`timescale 1ns / 1ps

module tb_digital_Safe();

// Inputs
reg clk;
reg startLoginBtn;
reg logoutBtn;
reg rstpwBtn;
reg cnf;
reg backSpace;
reg [9:0] keypad;

// Outputs
wire [3:0] an;
wire [6:0] seg;
wire a, b, c, d, p, clko, lck;
wire [2:0] rgb;
wire [6:0] error;

// Instantiate the module under test
digital_Safe uut (
    .clk(clk),
    .startLoginBtn(startLoginBtn),
    .logoutBtn(logoutBtn),
    .rstpwBtn(rstpwBtn),
    .cnf(cnf),
    .backSpace(backSpace),
    .keypad(keypad),
    .an(an),
    .seg(seg),
    .a(a),
    .b(b),
    .c(c),
    .d(d),
    .p(p),
    .rgb(rgb),
    .error(error),
    .clko(clko),
    .lck(lck)
);

// Clock generation
always #5 clk = ~clk;

// Test scenario
initial begin
    // Initialize inputs
    clk = 0;
    startLoginBtn = 0;
    logoutBtn = 0;
    rstpwBtn = 0;
    cnf = 0;
    backSpace = 0;
    keypad = 10'b0000000000;

    // Wait for some time
    #200;

    // Simulate login process
    startLoginBtn = 1;
    #10 startLoginBtn = 0;
    #10 keypad = 10'b0000000001; // Press '1'
    #10 keypad = 10'b0000000000; // Press '0'
    #10 keypad = 10'b0000000011; // Press '3'
    #10 keypad = 10'b0000000010; // Press '2'
    #10 cnf = 1;
    #10 cnf = 0;

    // Wait for some time
    #100;

    // Simulate logout process
    logoutBtn = 1;
    #10 logoutBtn = 0;

    // Wait for some time
    #200;

    // Simulate reset password process
    rstpwBtn = 1;
    #10 rstpwBtn = 0;
    #10 keypad = 10'b0000000010; // Press '2'
    #10 keypad = 10'b0000000011; // Press '3'
    #10 keypad = 10'b0000000000; // Press '0'
    #10 keypad = 10'b0000000001; // Press '1'
    #10 cnf = 1;
    #10 cnf = 0;

    // Wait for some time
    #100;

    // Simulate login process with new password
    startLoginBtn = 1;
    #10 startLoginBtn = 0;
    #10 keypad = 10'b0000000010; // Press '2'
    #10 keypad = 10'b0000000000; // Press '0'
    #10 keypad = 10'b0000000011; // Press '3'
    #10 keypad = 10'b0000000001; // Press '1'
    #10 cnf = 1;
    #10 cnf = 0;

    // End simulation
    #100;
    $finish;
end

endmodule