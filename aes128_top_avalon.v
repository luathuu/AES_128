module aes128_top_avalon (
    input  wire        clk,
    input  wire        reset_n,  // Active-low reset chuẩn Avalon

    // Avalon-MM Slave Interface
    input  wire        avs_write,
    input  wire        avs_read,
    input  wire [3:0]  avs_address,
    input  wire [31:0] avs_writedata,
    output reg  [31:0] avs_readdata,
    input  wire        avs_chipselect,

    // Output interrupt or done signal
    output wire        done
);

    // Internal AES signals
    reg         start;
    reg [127:0] plaintext, cipher_key;
    wire [127:0] ciphertext;
    // Internal instance of aes128_top
    aes128_top u_aes128_top (
        .clk(clk),
        .rst(~reset_n),               // Inverse reset signal for active-low reset
        .start(start),
        .plaintext(plaintext),
        .cipher_key(cipher_key),
        .ciphertext(ciphertext),
        .done(done)
    );
    // Avalon-MM interface logic
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            start <= 0;
            plaintext <= 0;
            cipher_key <= 0;
            avs_readdata <= 32'd0;
        end else if (avs_chipselect) begin
            if (avs_write) begin
                case (avs_address)
                    4'd0: cipher_key[127:96]  <= avs_writedata; // Write first part of cipher_key
                    4'd1: cipher_key[95:64]   <= avs_writedata; // Write second part of cipher_key
                    4'd2: cipher_key[63:32]   <= avs_writedata; // Write third part of cipher_key
                    4'd3: cipher_key[31:0]    <= avs_writedata; // Write fourth part of cipher_key
                    4'd4: plaintext[127:96]   <= avs_writedata; // Write first part of plaintext
                    4'd5: plaintext[95:64]    <= avs_writedata; // Write second part of plaintext
                    4'd6: plaintext[63:32]    <= avs_writedata; // Write third part of plaintext
                    4'd7: plaintext[31:0]     <= avs_writedata;
						  4'd8: start               <=avs_writedata[0];
						 // Write fourth part of plaintext
                endcase
            end else if (avs_read) begin
                case (avs_address)
                    4'd0: avs_readdata <= ciphertext[127:96]; // Read first part of ciphertext
                    4'd1: avs_readdata <= ciphertext[95:64];  // Read second part of ciphertext
                    4'd2: avs_readdata <= ciphertext[63:32];  // Read third part of ciphertext
                    4'd3: avs_readdata <= ciphertext[31:0];   // Read fourth part of ciphertext
                    4'd8: avs_readdata <= {31'd0, done};  // Return done signal status
                    default: avs_readdata <= 32'hDEADBEEF;  // Invalid address error code
                endcase
            end
        end
    end

endmodule
