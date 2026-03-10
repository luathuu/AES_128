`timescale 1ns/1ps
module tb_aes128_debug;

    reg            clk, rst, start;
    reg  [127:0]   plaintext;
    reg  [127:0]   cipher_key;
    wire [127:0]   ciphertext;
    wire           done;

    // debug taps
    wire [127:0]   dbg_state;
    wire [127:0]   dbg_sb_sr;
    wire [127:0]   dbg_mc;
    wire [3:0]     dbg_round;

    // instantiate top
    aes128_top dut (
        .clk        (clk),
        .rst        (rst),
        .start      (start),
        .plaintext  (plaintext),
        .cipher_key (cipher_key),
        .ciphertext (ciphertext),
        .done       (done),
        .dbg_state  (dbg_state),
        .dbg_sb_sr  (dbg_sb_sr),
        .dbg_mc     (dbg_mc),
        .dbg_round  (dbg_round)
    );

    // clock gen
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        rst        = 1;
        start      = 0;
        plaintext  = 128'h0;
        cipher_key = 128'h0;
        #20 rst    = 0;

        plaintext  = 128'h00112233445566778899aabbccddeeff;
        cipher_key = 128'h000102030405060708090a0b0c0d0e0f;

        #10 start = 1;
        #10 start = 0;

        wait(dbg_round == 1);
        repeat(10) begin
            @(posedge clk);
            $display("--- Round %0d ---", dbg_round);
            $display("state  : %h", dbg_state);
            $display("sb_sr  : %h", dbg_sb_sr);
            $display("mixcol : %h", dbg_mc);
        end

        wait(done);
        #10;
        $display("Ciphertext: %h", ciphertext);
        $display("Expected  : 69c4e0d86a7b0430d8cdb78070b4c55a");
        if (ciphertext === 128'h69c4e0d86a7b0430d8cdb78070b4c55a)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
