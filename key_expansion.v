module key_expansion (
    input wire clk, rst, start, 
    input wire [127:0] cipher_key,
    output reg [127:0] round_key0, round_key1, round_key2, round_key3,
    output reg [127:0] round_key4, round_key5, round_key6, round_key7,
    output reg [127:0] round_key8, round_key9, round_key10,
    output reg done
);

    reg [3:0] round;
    reg [127:0] w [0:10];
    reg [31:0] temp_word, rcon;
    wire [7:0] sbox_out[3:0];
    reg [31:0] temp0, temp1, temp2, temp3;
reg [31:0] rcon_table [0:10];

    // FSM states
    parameter IDLE = 3'b000, ROT_SUB = 3'b001,
              WAIT_SBOX = 3'b010, GEN_WORDS = 3'b011,TG=3'b100;
    reg [2:0] state;

    // Rcon selector via combinational case
    initial begin
    rcon_table[0]  = 32'h00000000;
    rcon_table[1]  = 32'h01000000;
    rcon_table[2]  = 32'h02000000;
    rcon_table[3]  = 32'h04000000;
    rcon_table[4]  = 32'h08000000;
    rcon_table[5]  = 32'h10000000;
    rcon_table[6]  = 32'h20000000;
    rcon_table[7]  = 32'h40000000;
    rcon_table[8]  = 32'h80000000;
    rcon_table[9]  = 32'h1B000000;
    rcon_table[10] = 32'h36000000;
end
    // S-box substitutions
    sbox_single u0 (.clk(clk), .in_byte(temp_word[31:24]), .out_byte(sbox_out[0]));
    sbox_single u1 (.clk(clk), .in_byte(temp_word[23:16]), .out_byte(sbox_out[1]));
    sbox_single u2 (.clk(clk), .in_byte(temp_word[15:8]),  .out_byte(sbox_out[2]));
    sbox_single u3 (.clk(clk), .in_byte(temp_word[7:0]),   .out_byte(sbox_out[3]));

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            done <= 0;
            round <= 0;
        end else begin
            case (state)
				TG: begin
				state <= IDLE;
            done <= 0;
            round <= 0; end 
                IDLE: begin				 
                    if (start) begin
                        w[0] <= cipher_key;
                        temp_word <= cipher_key[31:0];
                        round <= 1;
                        done <= 0;
                        state <= ROT_SUB;
                    end
                end
                ROT_SUB: begin
                    state <= WAIT_SBOX;
						  rcon <= rcon_table[round];
                end

                WAIT_SBOX: begin
                  temp_word <= {sbox_out[1], sbox_out[2], sbox_out[3], sbox_out[0]} ^ rcon;
                    state <= GEN_WORDS;
                end

                GEN_WORDS: begin
                    temp0 = w[round-1][127:96] ^ temp_word;
                    temp1 = temp0 ^ w[round-1][95:64];
                    temp2 = temp1 ^ w[round-1][63:32];
                    temp3 = temp2 ^ w[round-1][31:0];
                    w[round][127:96] = temp0;
                    w[round][95:64]  = temp1;
                    w[round][63:32]  = temp2;
                    w[round][31:0]   = temp3;

                    if (round == 10) begin
                        // output all round keys
                        round_key0  <= w[0];
                        round_key1  <= w[1];
                        round_key2  <= w[2];
                        round_key3  <= w[3];
                        round_key4  <= w[4];
                        round_key5  <= w[5];
                        round_key6  <= w[6];
                        round_key7  <= w[7];
                        round_key8  <= w[8];
                        round_key9  <= w[9];
                        round_key10 <= w[10];
                        done <= 1;
                        state <= TG;
                    end else begin
                        temp_word <= w[round][31:0];
                        round <= round + 1;
                        state <= ROT_SUB;
                    end
                end
            endcase
        end
    end
endmodule
