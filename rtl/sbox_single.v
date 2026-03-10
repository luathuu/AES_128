// ====================== S-Box dùng Block RAM ======================
module sbox_single (
    input  wire        clk,
    input  wire  [7:0] in_byte,
    output reg   [7:0] out_byte
);
    (* ram_style = "block" *)   // Gợi ý synthesis sử dụng Block RAM
    reg [7:0] sbox_mem [0:255];

    initial begin
        $readmemh("sbox_rom.mem", sbox_mem);  // Load từ file ROM
    end

    always @(posedge clk) begin
        out_byte <= sbox_mem[in_byte];
    end
endmodule
