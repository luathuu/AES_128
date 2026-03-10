//================ File: aes128_top.v =================
`timescale 1ns/1ps

module aes128_top (
    input  wire        clk,
    input  wire        rst,
    input  wire        start,
    input  wire [127:0] plaintext,
    input  wire [127:0] cipher_key,
    output wire [127:0] ciphertext,
    output wire        done
);

    // expansion outputs
    wire [127:0] round_key0, round_key1, round_key2, round_key3, round_key4;
    wire [127:0] round_key5, round_key6, round_key7, round_key8, round_key9, round_key10;
    wire         key_done;
    reg          core_start;

    // key expansion
    key_expansion u_key_expansion (
        .clk        (clk),
        .rst        (rst),
        .start      (start),
        .cipher_key (cipher_key),
        .round_key0 (round_key0),
        .round_key1 (round_key1),
        .round_key2 (round_key2),
        .round_key3 (round_key3),
        .round_key4 (round_key4),
        .round_key5 (round_key5),
        .round_key6 (round_key6),
        .round_key7 (round_key7),
        .round_key8 (round_key8),
        .round_key9 (round_key9),
        .round_key10(round_key10),
        .done       (key_done)
    );

    // core instance
    aes_encrypt_core u_aes_encrypt_core (
        .clk        (clk),
        .rst        (rst),
        .start      (core_start),
        .plaintext  (plaintext),
        .round_key0 (round_key0),
        .round_key1 (round_key1),
        .round_key2 (round_key2),
        .round_key3 (round_key3),
        .round_key4 (round_key4),
        .round_key5 (round_key5),
        .round_key6 (round_key6),
        .round_key7 (round_key7),
        .round_key8 (round_key8),
        .round_key9 (round_key9),
        .round_key10(round_key10),
        .ciphertext (ciphertext),
        .done       (done)
    );

    // start core when key expansion done
    always @(posedge clk or posedge rst) begin
        if (rst)
            core_start <= 1'b0;
        else if (!done)
            core_start <= key_done;
    end
endmodule