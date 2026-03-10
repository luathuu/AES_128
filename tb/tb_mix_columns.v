`timescale 1ns/1ps

module tb_mix_columns;

    reg  [127:0] state_in;
    wire [127:0] state_out;

    // Instantiate DUT
    mix_columns uut (
        .state_in(state_in),
        .state_out(state_out)
    );

    // Test vector from FIPS-197 Appendix C (after SubBytes and ShiftRows)
    // Input: d4 bf 5d 30  e0 b4 52 ae  b8 41 11 f1  1e 27 98 e5
    // Output after MixColumns: 04 66 81 e5  e0 cb 19 9a  48 f8 d3 7a  28 06 26 4c
    initial begin
        $display("==== MixColumns Test ====");
        $dumpfile("tb_mix_columns.vcd");
        $dumpvars(0, tb_mix_columns);

        // Input in row-major order:
        state_in = 128'hd4bf5d30e0b452aeb84111f11e2798e5;

        #10;

        $display("Input State     : %h", state_in);
        $display("Output State    : %h", state_out);

        if (state_out === 128'h046681e5e0cb199a48f8d37a2806264c)
            $display("*** PASS: MixColumns output matches expected ***");
        else
            $display("*** FAIL: MixColumns output incorrect ***");

        $stop;
    end

endmodule
