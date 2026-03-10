`timescale 1ns/1ps

module tb_sub_bytes;

    reg  [127:0] state_in;
    wire [127:0] state_out;
    reg  [127:0] expected;
    integer i;

    sub_bytes uut (
        .state_in(state_in),
        .state_out(state_out)
    );

    reg [127:0] inputs    [0:9];
    reg [127:0] expecteds [0:9];

    initial begin
        $display("===== SubBytes 10 Test Cases =====");
        $dumpfile("tb_sub_bytes.vcd");
        $dumpvars(0, tb_sub_bytes);

        // Input & Expected values (MSB to LSB)
        inputs[0]    = 128'h3bc6a410798764bb6ee6cdaefb8d53ee;
        expecteds[0] = 128'he2b449cab61743ea9f8ebde40f5ded28;

        inputs[1]    = 128'h6995fbe40a05e7e0f5f00162af843d38;
        expecteds[1] = 128'hf92a0f69676b94e1e68c7caa795f2707;

        inputs[2]    = 128'hee639ce0456c6682dad51145b17264b9;
        expecteds[2] = 128'h28fbdee16e5033135703826ec8404356;

        inputs[3]    = 128'hb101537c3c9cc1de0d06b1f5ee1c386d;
        expecteds[3] = 128'hc87ced10ebde781dd76fc8e6289c073c;

        inputs[4]    = 128'h340d9c29c190fcd292b09bbce3db043a;
        expecteds[4] = 128'h18d7dea57860b0b54fe7146511b9f280;

        inputs[5]    = 128'ha943a32eb33a7ac48cd1594a8c05526b;
        expecteds[5] = 128'h4979b45d7429e0e5d3fbc4c772a58f22;

        inputs[6]    = 128'hbc68a1427ff28703cf508f6f9831da8f;
        expecteds[6] = 128'hf3b999db901cf8d7ba78d97727fc5619;

        inputs[7]    = 128'h05101240df3c7702cc144c30e3735740;
        expecteds[7] = 128'h9a7b77a7b8fce0a9624e3b53b9632d7c;

        inputs[8]    = 128'hff00ff00aa55aa550f0f0f0f00000000;
        expecteds[8] = 128'h16166363e54fe54f8c8cbebe63636363;

        inputs[9]    = 128'h123456789abcdef00123456789abcdef;
        expecteds[9] = 128'hc4a7f87e63cab1e164a7f87e63cab1e1;

        for (i = 0; i < 10; i = i + 1) begin
            state_in = inputs[i];
            expected = expecteds[i];
            #10;
            $display("Test %0d:", i);
            $display("Input    : %h", state_in);
            $display("Output   : %h", state_out);
            $display("Expected : %h", expected);
            if (state_out === expected)
                $display("*** PASS ***\n");
            else
                $display("*** FAIL ***\n");
        end

        $stop;
    end

endmodule
