//================ File: aes_encrypt_core.v =================
`timescale 1ns/1ps

module aes_encrypt_core (
    input  wire        clk,
    input  wire        rst,
    input  wire        start,
    input  wire [127:0] plaintext,
    input  wire [127:0] round_key0,
    input  wire [127:0] round_key1,
    input  wire [127:0] round_key2,
    input  wire [127:0] round_key3,
    input  wire [127:0] round_key4,
    input  wire [127:0] round_key5,
    input  wire [127:0] round_key6,
    input  wire [127:0] round_key7,
    input  wire [127:0] round_key8,
    input  wire [127:0] round_key9,
    input  wire [127:0] round_key10,
    output reg  [127:0] ciphertext,
    output reg          done
  
);

    // FSM states
    parameter IDLE   = 4'b0000,
              WARMUP = 4'b0001,
              ROUND  = 4'b0010,
              FINAL  = 4'b0011,
				  TG1 = 4'b0100,
				  TG3= 4'b0101,
				  TG5=4'b0111,
				  TG=4'B1000;
    reg [2:0] fsm_state;
    reg       warmup_done;
    reg [3:0] round;

    // pipeline registers
    reg [127:0] state_reg;
    reg [127:0] sb_sr_reg;
    reg [127:0] rk_d0;    
    reg [127:0] rk_d1;
    reg [31:0]  dem;

    // comb wires
    wire [127:0] subbytes_wire;
    wire [127:0] sb_sr_wire;
    wire [127:0] mixcolumns_out;

    // round-key array
    wire [127:0] rk [0:10];
    assign rk[0]  = round_key0;  assign rk[1]  = round_key1;
    assign rk[2]  = round_key2;  assign rk[3]  = round_key3;
    assign rk[4]  = round_key4;  assign rk[5]  = round_key5;
    assign rk[6]  = round_key6;  assign rk[7]  = round_key7;
    assign rk[8]  = round_key8;  assign rk[9]  = round_key9;
    assign rk[10] = round_key10;

    // submodules
    sub_bytes   u_subbytes  (.clk(clk), .state_in(state_reg),   .state_out(subbytes_wire));
    shift_rows  u_shiftrows (.state_in(subbytes_wire),.state_out(sb_sr_wire));
    mix_columns u_mixcolumns(.state_in(sb_sr_reg),   .state_out(mixcolumns_out));

    // debug taps
    assign dbg_state = state_reg;
    assign dbg_sb_sr = sb_sr_reg;
   assign dbg_mc    = mixcolumns_out;
   assign dbg_round = round;

    // FSM
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            fsm_state   <= IDLE;
            warmup_done <= 1'b0;
            round       <= 4'd0;
            done        <= 1'b0;
            state_reg   <= 128'd0;
            sb_sr_reg   <= 128'd0;
            rk_d0       <= 128'd0;
            rk_d1       <= 128'd0;
            dem         <= 32'd0;
            ciphertext  <= 128'd0;
        end else begin
            case (fsm_state)
				TG: begin 
				fsm_state   <= IDLE;
            warmup_done <= 1'b0;
            round       <= 4'd0;
            done        <= 1'b0;
            state_reg   <= 128'd0;
            sb_sr_reg   <= 128'd0;
            rk_d0       <= 128'd0;
            rk_d1       <= 128'd0;
            dem         <= 32'd0;
     //     ciphertext  <= 128'd0;
				end 
            IDLE: begin
                done = 1'b0;
					 warmup_done <= 1'b0;
                round       <= 4'd0;
                done        <= 1'b0;
                state_reg   <= 128'd0;
                sb_sr_reg   <= 128'd0;
                rk_d0       <= 128'd0;
                rk_d1       <= 128'd0;
                dem         <= 32'd0;
            //    ciphertext  <= 128'd0;
                if (start) begin
                    state_reg   <= plaintext ^ rk[0];
                    rk_d0       <= rk[1];
                    rk_d1       <= rk[2];
                    warmup_done <= 1'b0;
                    dem         <= 32'd0;
                    fsm_state   <= TG1;
                    round     <= 4'd1;
                end
            end
				 TG1:
			   begin 
			   fsm_state <=WARMUP;
			   end 
            WARMUP: begin
                sb_sr_reg <= sb_sr_wire;
                fsm_state<=TG3;
                    end
            TG3: begin 
            state_reg <= mixcolumns_out ^ rk_d0;
                rk_d0 <= rk_d1;
                rk_d1 <= rk[round+2];
                 if (round < 4'd9) begin
                     round <= round + 1;  
                     fsm_state<=TG1;
                 end else if(round >= 4'd9) begin
                fsm_state<=TG5; end
            end 
               TG5:
			   begin 
			   fsm_state <=FINAL;
			   end   
            FINAL: begin
                sb_sr_reg  <= sb_sr_wire;
                ciphertext <= sb_sr_wire ^ rk[10];
                done       <= 1'b1;
                fsm_state  <= TG;
            end
            endcase
        end
    end
endmodule
