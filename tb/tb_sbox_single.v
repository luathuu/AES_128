`timescale 1ns/1ps

module tb_sbox_single;

    reg  [7:0] in_byte;
    wire [7:0] out_byte;

    // Instantiate the S-Box module
    sbox_single uut (
        .in_byte(in_byte),
        .out_byte(out_byte)
    );

    // Reference S-Box table (from FIPS-197)
    reg [7:0] sbox_ref [0:255];

    integer i;
    integer fail_count;

    initial begin
        $display("===== TESTING SBOX_SINGLE (0x00 → 0xFF) =====");
        $dumpfile("tb_sbox_single.vcd");
        $dumpvars(0, tb_sbox_single);

        // Initialize expected S-box values (FIPS-197)
        // Dòng này load từ file chuẩn giống .mem bạn dùng
        $readmemh("sbox_rom.mem", sbox_ref);

        fail_count = 0;

        for (i = 0; i < 256; i = i + 1) begin
            in_byte = i[7:0];
            #1; // Wait for combinational result

            if (out_byte !== sbox_ref[i]) begin
                $display("FAIL: SBOX(%02x) = %02x (Expected %02x)", i, out_byte, sbox_ref[i]);
                fail_count = fail_count + 1;
            end
        end

        if (fail_count == 0)
            $display("*** ALL 256 VALUES PASSED ✅ ***");
        else
            $display("*** TOTAL FAILED: %0d ❌ ***", fail_count);

        $stop;
    end

endmodule
