// seven_segment_controller.v
module seven_segment_controller (
    input wire clk_game,                    // 60Hz game clock
    input wire reset,                       // Active high reset
    
    // Game state inputs
    input wire [2:0] current_game_state,    // Current game state
    input wire game_mode_1p,                // 0=2P mode, 1=1P mode
    input wire [7:0] game_time_seconds,     // Game duration in seconds
    input wire winner_p1,                   // Player 1 won
    input wire winner_p2,                   // Player 2 won
    input wire game_is_draw,                // Game ended in draw
    
    // 7-segment display outputs (active LOW)
    output reg [6:0] hex0_out,              // Rightmost display
    output reg [6:0] hex1_out,
    output reg [6:0] hex2_out,
    output reg [6:0] hex3_out,
    output reg [6:0] hex4_out,
    output reg [6:0] hex5_out               // Leftmost display
);

    // Game state definitions
    localparam STATE_MENU      = 3'b000;
    localparam STATE_COUNTDOWN = 3'b001;
    localparam STATE_GAMEPLAY  = 3'b010;
    localparam STATE_GAME_OVER = 3'b011;
    
    // 7-segment patterns (active LOW - 0 = ON, 1 = OFF)
    localparam SEG_0 = 7'b1000000;  // Display '0'
    localparam SEG_1 = 7'b1111001;  // Display '1'
    localparam SEG_2 = 7'b0100100;  // Display '2'
    localparam SEG_3 = 7'b0110000;  // Display '3'
    localparam SEG_4 = 7'b0011001;  // Display '4'
    localparam SEG_5 = 7'b0010010;  // Display '5'
    localparam SEG_6 = 7'b0000010;  // Display '6'
    localparam SEG_7 = 7'b1111000;  // Display '7'
    localparam SEG_8 = 7'b0000000;  // Display '8'
    localparam SEG_9 = 7'b0010000;  // Display '9'
    
    localparam SEG_A = 7'b0001000;  // Display 'A'
    localparam SEG_b = 7'b0000011;  // Display 'b' (lowercase)
    localparam SEG_C = 7'b1000110;  // Display 'C'
    localparam SEG_d = 7'b0100001;  // Display 'd' (lowercase)
    localparam SEG_E = 7'b0000110;  // Display 'E'
    localparam SEG_F = 7'b0001110;  // Display 'F'
    localparam SEG_G = 7'b1000010;  // Display 'G'
    localparam SEG_H = 7'b0001001;  // Display 'H'
    localparam SEG_I = 7'b1111001;  // Display 'I' (same as 1)
    localparam SEG_J = 7'b1100001;  // Display 'J'
    localparam SEG_L = 7'b1000111;  // Display 'L'
    localparam SEG_n = 7'b0101011;  // Display 'n' (lowercase)
    localparam SEG_o = 7'b0100011;  // Display 'o' (lowercase)
    localparam SEG_P = 7'b0001100;  // Display 'P'
    localparam SEG_q = 7'b0011000;  // Display 'q' (lowercase)
    localparam SEG_r = 7'b0101111;  // Display 'r' (lowercase)
    localparam SEG_S = 7'b0010010;  // Display 'S' (same as 5)
    localparam SEG_t = 7'b0000111;  // Display 't' (lowercase)
    localparam SEG_U = 7'b1000001;  // Display 'U'
    localparam SEG_y = 7'b0010001;  // Display 'y' (lowercase)
    
    localparam SEG_DASH = 7'b0111111;  // Display '-'
    localparam SEG_BLANK = 7'b1111111; // Display nothing (all OFF)
    
    // Function to convert BCD digit to 7-segment
    function [6:0] digit_to_7seg;
        input [3:0] digit;
        begin
            case (digit)
                4'd0: digit_to_7seg = SEG_0;
                4'd1: digit_to_7seg = SEG_1;
                4'd2: digit_to_7seg = SEG_2;
                4'd3: digit_to_7seg = SEG_3;
                4'd4: digit_to_7seg = SEG_4;
                4'd5: digit_to_7seg = SEG_5;
                4'd6: digit_to_7seg = SEG_6;
                4'd7: digit_to_7seg = SEG_7;
                4'd8: digit_to_7seg = SEG_8;
                4'd9: digit_to_7seg = SEG_9;
                default: digit_to_7seg = SEG_BLANK;
            endcase
        end
    endfunction
    
    // Extract tens and units from time
    wire [3:0] time_tens = (game_time_seconds >= 8'd10) ? (game_time_seconds / 8'd10) : 4'd0;
    wire [3:0] time_units = game_time_seconds % 8'd10;
    
    always @(posedge clk_game or posedge reset) begin
        if (reset) begin
            hex0_out <= SEG_BLANK;
            hex1_out <= SEG_BLANK;
            hex2_out <= SEG_BLANK;
            hex3_out <= SEG_BLANK;
            hex4_out <= SEG_BLANK;
            hex5_out <= SEG_BLANK;
        end else begin
            case (current_game_state)
                STATE_MENU: begin
                    // Display "1P" or "2P" based on selected mode
                    if (game_mode_1p) begin
                        // Display "   1P " (1-Player mode)
                        hex5_out <= SEG_BLANK;
                        hex4_out <= SEG_BLANK;
                        hex3_out <= SEG_BLANK;
                        hex2_out <= SEG_1;        // '1'
                        hex1_out <= SEG_P;        // 'P'
                        hex0_out <= SEG_BLANK;
                    end else begin
                        // Display "   2P " (2-Player mode)
                        hex5_out <= SEG_BLANK;
                        hex4_out <= SEG_BLANK;
                        hex3_out <= SEG_BLANK;
                        hex2_out <= SEG_2;        // '2'
                        hex1_out <= SEG_P;        // 'P'
                        hex0_out <= SEG_BLANK;
                    end
                end
                
                STATE_COUNTDOWN, STATE_GAMEPLAY: begin
                    // Display "FIGHt " during countdown and gameplay
                    hex5_out <= SEG_F;            // 'F'
                    hex4_out <= SEG_I;            // 'I'
                    hex3_out <= SEG_G;            // 'G'
                    hex2_out <= SEG_H;            // 'H'
                    hex1_out <= SEG_t;            // 't'
                    hex0_out <= SEG_BLANK;
                end
                
                STATE_GAME_OVER: begin
                    if (game_is_draw) begin
                        // Display "Eq-XX-" for draw
                        hex5_out <= SEG_E;                    // 'E'
                        hex4_out <= SEG_q;                    // 'q'
                        hex3_out <= SEG_DASH;                 // '-'
                        hex2_out <= digit_to_7seg(time_tens); // Tens digit of time
                        hex1_out <= digit_to_7seg(time_units);// Units digit of time
                        hex0_out <= SEG_DASH;                 // '-'
                    end else if (winner_p1) begin
                        // Display "P1-XX-" for Player 1 win
                        hex5_out <= SEG_P;                    // 'P'
                        hex4_out <= SEG_1;                    // '1'
                        hex3_out <= SEG_DASH;                 // '-'
                        hex2_out <= digit_to_7seg(time_tens); // Tens digit of time
                        hex1_out <= digit_to_7seg(time_units);// Units digit of time
                        hex0_out <= SEG_DASH;                 // '-'
                    end else if (winner_p2) begin
                        // Display "P2-XX-" for Player 2 win
                        hex5_out <= SEG_P;                    // 'P'
                        hex4_out <= SEG_2;                    // '2'
                        hex3_out <= SEG_DASH;                 // '-'
                        hex2_out <= digit_to_7seg(time_tens); // Tens digit of time
                        hex1_out <= digit_to_7seg(time_units);// Units digit of time
                        hex0_out <= SEG_DASH;                 // '-'
                    end else begin
                        // Default case - should not happen
                        hex5_out <= SEG_E;                    // 'E'
                        hex4_out <= SEG_r;                    // 'r'
                        hex3_out <= SEG_r;                    // 'r'
                        hex2_out <= SEG_o;                    // 'o'
                        hex1_out <= SEG_r;                    // 'r'
                        hex0_out <= SEG_BLANK;
                    end
                end
                
                default: begin
                    // Error state - display "Err"
                    hex5_out <= SEG_E;        // 'E'
                    hex4_out <= SEG_r;        // 'r'
                    hex3_out <= SEG_r;        // 'r'
                    hex2_out <= SEG_BLANK;
                    hex1_out <= SEG_BLANK;
                    hex0_out <= SEG_BLANK;
                end
            endcase
        end
    end
    
endmodule
