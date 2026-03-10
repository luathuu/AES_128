`timescale 1ns / 1ps

module tb_key_expansion;
    reg         clk, rst, start;
    reg  [127:0] cipher_key;
    wire [127:0] round_key0, round_key1, round_key2, round_key3;
    wire [127:0] round_key4, round_key5, round_key6, round_key7;
    wire [127:0] round_key8, round_key9, round_key10;
    wire        done;

    // Instantiate the DUT
    key_expansion uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .cipher_key(cipher_key),
        .round_key0(round_key0),
        .round_key1(round_key1),
        .round_key2(round_key2),
        .round_key3(round_key3),
        .round_key4(round_key4),
        .round_key5(round_key5),
        .round_key6(round_key6),
        .round_key7(round_key7),
        .round_key8(round_key8),
        .round_key9(round_key9),
        .round_key10(round_key10),
        .done(done)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        // Initialize
        clk = 0;
        rst = 1;
        start = 0;
        cipher_key = 128'h2b7e151628aed2a6abf7158809cf4f3c;  // Ví dụ key chuẩn

        // Reset system
        #10;
        rst = 0;

        // Start key expansion
        #10;
        start = 1;
        #10;
        start = 0;

        // Đợi cho đến khi done
        wait (done);

        // In kết quả
        $display("Round Key 0  : %h", round_key0);
        $display("Round Key 1  : %h", round_key1);
        $display("Round Key 2  : %h", round_key2);
        $display("Round Key 3  : %h", round_key3);
        $display("Round Key 4  : %h", round_key4);
        $display("Round Key 5  : %h", round_key5);
        $display("Round Key 6  : %h", round_key6);
        $display("Round Key 7  : %h", round_key7);
        $display("Round Key 8  : %h", round_key8);
        $display("Round Key 9  : %h", round_key9);
        $display("Round Key 10 : %h", round_key10);

        #20;
        $finish;
    end
endmodule
