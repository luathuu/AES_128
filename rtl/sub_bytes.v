//====================== SubBytes (with registered output) ======================
module sub_bytes (
    input  wire        clk,
    input  wire [127:0] state_in,
    output wire  [127:0] state_out
);
    wire [7:0] sbox_out [0:15];

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : SBOX_LOOKUP
            sbox_single u (
                .clk      (clk),
                .in_byte  (state_in[i*8 +: 8]),
                .out_byte (sbox_out[i])
            );
        end
    endgenerate

  // always @(posedge clk) begin
  assign      state_out = {
            sbox_out[15], sbox_out[14], sbox_out[13], sbox_out[12],
            sbox_out[11], sbox_out[10], sbox_out[9],  sbox_out[8],
            sbox_out[7],  sbox_out[6],  sbox_out[5],  sbox_out[4],
            sbox_out[3],  sbox_out[2],  sbox_out[1],  sbox_out[0]
        };
   // end
endmodule
