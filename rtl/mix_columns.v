module mix_columns (
    input  wire [127:0] state_in,
    output wire [127:0] state_out
);

    //--------- Internal wires ----------
    wire [7:0] s [0:15];
    wire [7:0] x [0:15];  // xtime(s[i])
    wire [7:0] m [0:15];  // MixColumns result

    // Split 128-bit state into 16 bytes
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : SPLIT
            assign s[i] = state_in[127 - i*8 -: 8];
        end
    endgenerate

    // GF(2^8) multiplication by 2
    function [7:0] xtime(input [7:0] b);
        begin
            xtime = {b[6:0], 1'b0} ^ (8'h1b & {8{b[7]}});
        end
    endfunction

    // Precompute xtime(s[i])
    generate
        for (i = 0; i < 16; i = i + 1) begin : XTIME_GEN
            assign x[i] = xtime(s[i]);
        end
    endgenerate

    // MixColumns computation per column
    generate
        for (i = 0; i < 4; i = i + 1) begin : MIX
            assign m[i*4+0] = x[i*4]     ^ x[i*4+1] ^ s[i*4+1] ^ s[i*4+2] ^ s[i*4+3];
            assign m[i*4+1] = s[i*4]     ^ x[i*4+1] ^ x[i*4+2] ^ s[i*4+2] ^ s[i*4+3];
            assign m[i*4+2] = s[i*4]     ^ s[i*4+1] ^ x[i*4+2] ^ x[i*4+3] ^ s[i*4+3];
            assign m[i*4+3] = x[i*4]     ^ s[i*4]   ^ s[i*4+1] ^ s[i*4+2] ^ x[i*4+3];
        end
    endgenerate

    // Recombine output
    assign state_out = {
        m[0],  m[1],  m[2],  m[3],
        m[4],  m[5],  m[6],  m[7],
        m[8],  m[9],  m[10], m[11],
        m[12], m[13], m[14], m[15]
    };

endmodule
