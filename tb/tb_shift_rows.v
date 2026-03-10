`timescale 1ns/1ps

module tb_shift_rows;

    reg  [127:0] state_in;
    wire [127:0] state_out;

    reg  [127:0] expected;
    integer i;

    // Instantiate DUT (Device Under Test)
    shift_rows uut (
        .state_in(state_in),
        .state_out(state_out)
    );

    // Define test vectors (row-major layout)
    reg [127:0] inputs     [0:4];
    reg [127:0] expecteds  [0:4];

    initial begin
        $display("==== ShiftRows Test ====");
        $dumpfile("tb_shift_rows.vcd");
        $dumpvars(0, tb_shift_rows);

        // Test Case 0 - All zero
        inputs[0]    = 128'h00000000000000000000000000000000;
        expecteds[0] = 128'h00000000000000000000000000000000;

        // Test Case 1 - Increasing bytes
        inputs[1]    = 128'h000102030405060708090a0b0c0d0e0f;
        expecteds[1] = 128'h00050a0f04090e03080d02070c01060b;

        // Test Case 2 - Reverse bytes
        inputs[2]    = 128'hfffefdfcfbfaf9f8f7f6f5f4f3f2f1f0;
        expecteds[2] = 128'hfffaf5f0fbf6f1fcf7f2fdf8f3fef9f4;

        // Test Case 3 - Only row 1 has data
        inputs[3]    = 128'haa11bbccdd22eeff0011223344556677;
        expecteds[3] = 128'haa222277dd1166cc0055bbff4411ee33;

        // Test Case 4 - Random pattern
        inputs[4]    = 128'h123456789abcdef00123456789abcdef;
        expecteds[4] = 128'h12bc45ef9a23cd7801ab56f08934de67;

        for (i = 0; i < 5; i = i + 1) begin
            state_in = inputs[i];
            expected = expecteds[i];
            #10;

            $display("Test %0d:", i);
            $display("Input    : %h", inputs[i]);
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
