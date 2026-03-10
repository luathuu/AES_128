`timescale 1ns/1ps

module tb_aes128_top_avalon;

    reg clk;
    reg reset_n;
    reg avs_write;
    reg avs_read;
    reg [3:0] avs_address;
    reg [31:0] avs_writedata;
    reg avs_chipselect;
    wire [31:0] avs_readdata;
    wire done;

    // Instantiate DUT
    aes128_top_avalon dut (
        .clk(clk),
        .reset_n(reset_n),
        .avs_write(avs_write),
        .avs_read(avs_read),
        .avs_address(avs_address),
        .avs_writedata(avs_writedata),
        .avs_readdata(avs_readdata),
        .avs_chipselect(avs_chipselect),
        .done(done)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;  // 10ns clock period

    // Task to write to Avalon-MM
    task avalon_write(input [3:0] addr, input [31:0] data);
        begin
            @(posedge clk);
            avs_chipselect <= 1;
            avs_write <= 1;
            avs_address <= addr;
            avs_writedata <= data;
            @(posedge clk);
            avs_write <= 0;
            avs_chipselect <= 0;
        end
    endtask

    // Task to read from Avalon-MM
    task avalon_read(input [3:0] addr);
        begin
            @(posedge clk);
            avs_chipselect <= 1;
            avs_read <= 1;
            avs_address <= addr;
            @(posedge clk);
				@(posedge clk);
            $display("Read from address %d = %h", addr, avs_readdata);
            avs_read <= 0;
            avs_chipselect <= 0;
        end
    endtask

     initial begin
        // Reset
        reset_n = 0;
        avs_write = 0;
        avs_read = 0;
        avs_chipselect = 0;
        #20;
        reset_n = 1;
        #20;

        // Test Case 1: Write cipher key 128'h000102030405060708090a0b0c0d0e0f
        avalon_write(4'd0, 32'h00010203);
        avalon_write(4'd1, 32'h04050607);
        avalon_write(4'd2, 32'h08090a0b);
        avalon_write(4'd3, 32'h0c0d0e0f);

        // Test Case 2: Write plaintext 128'h00112233445566778899aabbccddeeff
        avalon_write(4'd4, 32'h00112233);
        avalon_write(4'd5, 32'h44556677);
        avalon_write(4'd6, 32'h8899aabb);
        avalon_write(4'd7, 32'hccddeeff);

        // Test Case 3: Trigger start
        avalon_write(4'd8, 32'h00000001);

        // Wait for done
        wait (done);
        #10;

        // Test Case 4: Read ciphertext back
        avalon_read(4'd0);
        avalon_read(4'd1);
        avalon_read(4'd2);
        avalon_read(4'd3);
        avalon_read(4'd8);

        // Test Case 5: Write cipher key 128'hff00112233445566778899aabbccddeeff
        avalon_write(4'd0, 32'hff00ff00);
        avalon_write(4'd1, 32'h11223344);
        avalon_write(4'd2, 32'h55667788);
        avalon_write(4'd3, 32'h99aabbcc);

        // Test Case 6: Write plaintext 128'hdeadbeefdeadbeefdeadbeefdeadbeef
        avalon_write(4'd4, 32'hdeadbeef);
        avalon_write(4'd5, 32'hdeadbeef);
        avalon_write(4'd6, 32'hdeadbeef);
        avalon_write(4'd7, 32'hdeadbeef);

        // Test Case 7: Trigger start
        avalon_write(4'd8, 32'h00000001);

        // Wait for done
        wait (done);
        #10;

        // Test Case 8: Read ciphertext back
        avalon_read(4'd0);
        avalon_read(4'd1);
        avalon_read(4'd2);
        avalon_read(4'd3);
        avalon_read(4'd8);

        // Test Case 9: Write cipher key 128'h11111111111111111111111111111111
        avalon_write(4'd0, 32'h11111111);
        avalon_write(4'd1, 32'h11111111);
        avalon_write(4'd2, 32'h11111111);
        avalon_write(4'd3, 32'h11111111);

        // Test Case 10: Write plaintext 128'h1234567890abcdef1234567890abcdef
        avalon_write(4'd4, 32'h12345678);
        avalon_write(4'd5, 32'h90abcdef);
        avalon_write(4'd6, 32'h12345678);
        avalon_write(4'd7, 32'h90abcdef);

        // Test Case 11: Trigger start
        avalon_write(4'd8, 32'h00000001);

        // Wait for done
        wait (done);
        #10;

        // Test Case 12: Read ciphertext back
        avalon_read(4'd0);
        avalon_read(4'd1);
        avalon_read(4'd2);
        avalon_read(4'd3);
        avalon_read(4'd8);

        // Test Case 13: Write cipher key 128'h00000000000000000000000000000000
        avalon_write(4'd0, 32'h00000000);
        avalon_write(4'd1, 32'h00000000);
        avalon_write(4'd2, 32'h00000000);
        avalon_write(4'd3, 32'h00000000);

        // Test Case 14: Write plaintext 128'h00000000000000000000000000000000
        avalon_write(4'd4, 32'h00000000);
        avalon_write(4'd5, 32'h00000000);
        avalon_write(4'd6, 32'h00000000);
        avalon_write(4'd7, 32'h00000000);

        // Test Case 15: Trigger start
        avalon_write(4'd8, 32'h00000001);

        // Wait for done
        wait (done);
        #10;

        // Test Case 16: Read ciphertext back
        avalon_read(4'd0);
        avalon_read(4'd1);
        avalon_read(4'd2);
        avalon_read(4'd3);
        avalon_read(4'd8);

        // Test Case 17: Write cipher key 128'hffffffffffffffffffffffffffffffff
        avalon_write(4'd0, 32'hffffffff);
        avalon_write(4'd1, 32'hffffffff);
        avalon_write(4'd2, 32'hffffffff);
        avalon_write(4'd3, 32'hffffffff);

        // Test Case 18: Write plaintext 128'hffffffffffffffffffffffffffffffff
        avalon_write(4'd4, 32'hffffffff);
        avalon_write(4'd5, 32'hffffffff);
        avalon_write(4'd6, 32'hffffffff);
        avalon_write(4'd7, 32'hffffffff);

        // Test Case 19: Trigger start
        avalon_write(4'd8, 32'h00000001);

        // Wait for done
        wait (done);
        #10;

        // Test Case 20: Read ciphertext back
        avalon_read(4'd0);
        avalon_read(4'd1);
        avalon_read(4'd2);
        avalon_read(4'd3);
        avalon_read(4'd8);

        $finish;
    end
endmodule
