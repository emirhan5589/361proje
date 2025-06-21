module menu_screen (
    input  wire        display_enable,
    input  wire [9:0]  pixel_x,
    input  wire [9:0]  pixel_y,

    input  wire        sw0_mode_select,

    input  wire [3:0]  p1_buttons,

    output reg  [7:0]  color_out_332,

    output wire [3:0]  mode_hex,

    output wire [9:0]  leds_out,
    output wire        start_game
);

    // --- Constants ---
    localparam [7:0] COLOR_BLACK = 8'b00000000;
    localparam [7:0] COLOR_WHITE = 8'b11111111;
    localparam [7:0] COLOR_BG    = 8'b00000011; // dark blue background

    localparam integer SCALE    = 8;             // font pixel scale factor
    localparam integer CHAR_W   = 5 * SCALE;     // character width  (pixels)
    localparam integer CHAR_H   = 7 * SCALE;     // character height (pixels)
    localparam integer CHAR_SP  = 2 * SCALE;     // spacing between characters
    localparam integer MENU_TOP = 100;           // top-left of the word
    localparam integer MENU_LEFT = 228;          // approx center horizontally

    // Font helper function: returns 5-bit row data for one of the supported
    // characters. char_sel: 0=M, 1=E, 2=N, 3=U, 4='1', 5='2', 6='P'
    function [4:0] font_row;
        input [2:0] char_sel;
        input [2:0] row;
        begin
            case (char_sel)
                // --- "M" ---
                3'd0: case (row)
                    3'd0: font_row = 5'b10001;
                    3'd1: font_row = 5'b11011;
                    3'd2: font_row = 5'b10101;
                    3'd3: font_row = 5'b10001;
                    3'd4: font_row = 5'b10001;
                    3'd5: font_row = 5'b10001;
                    3'd6: font_row = 5'b10001;
                    default: font_row = 5'b00000;
                endcase
                // --- "E" ---
                3'd1: case (row)
                    3'd0: font_row = 5'b11111;
                    3'd1: font_row = 5'b10000;
                    3'd2: font_row = 5'b11110;
                    3'd3: font_row = 5'b10000;
                    3'd4: font_row = 5'b10000;
                    3'd5: font_row = 5'b10000;
                    3'd6: font_row = 5'b11111;
                    default: font_row = 5'b00000;
                endcase
                // --- "N" ---
                3'd2: case (row)
                    3'd0: font_row = 5'b10001;
                    3'd1: font_row = 5'b11001;
                    3'd2: font_row = 5'b10101;
                    3'd3: font_row = 5'b10011;
                    3'd4: font_row = 5'b10001;
                    3'd5: font_row = 5'b10001;
                    3'd6: font_row = 5'b10001;
                    default: font_row = 5'b00000;
                endcase
                // --- "U" ---
                3'd3: case (row)
                    3'd0: font_row = 5'b10001;
                    3'd1: font_row = 5'b10001;
                    3'd2: font_row = 5'b10001;
                    3'd3: font_row = 5'b10001;
                    3'd4: font_row = 5'b10001;
                    3'd5: font_row = 5'b10001;
                    3'd6: font_row = 5'b01110;
                    default: font_row = 5'b00000;
                endcase
                // --- "1" ---
                3'd4: case (row)
                    3'd0: font_row = 5'b00100;
                    3'd1: font_row = 5'b01100;
                    3'd2: font_row = 5'b00100;
                    3'd3: font_row = 5'b00100;
                    3'd4: font_row = 5'b00100;
                    3'd5: font_row = 5'b00100;
                    3'd6: font_row = 5'b01110;
                    default: font_row = 5'b00000;
                endcase
                // --- "2" ---
                3'd5: case (row)
                    3'd0: font_row = 5'b01110;
                    3'd1: font_row = 5'b10001;
                    3'd2: font_row = 5'b00001;
                    3'd3: font_row = 5'b00010;
                    3'd4: font_row = 5'b00100;
                    3'd5: font_row = 5'b01000;
                    3'd6: font_row = 5'b11111;
                    default: font_row = 5'b00000;
                endcase
                // --- "P" ---
                3'd6: case (row)
                    3'd0: font_row = 5'b11110;
                    3'd1: font_row = 5'b10001;
                    3'd2: font_row = 5'b10001;
                    3'd3: font_row = 5'b11110;
                    3'd4: font_row = 5'b10000;
                    3'd5: font_row = 5'b10000;
                    3'd6: font_row = 5'b10000;
                    default: font_row = 5'b00000;
                endcase
                default: font_row = 5'b00000;
            endcase
        end
    endfunction

    // ------------------------------------------------------------------
    // VGA output
    // ------------------------------------------------------------------
    integer i;
    integer col_idx;
    integer row_idx;
    integer char_left;
    reg pixel_on;

    always @(*) begin
        if (!display_enable) begin
            color_out_332 = COLOR_BLACK;
        end else begin
            color_out_332 = COLOR_BG;
            pixel_on = 1'b0;

            for (i = 0; i < 4; i = i + 1) begin
                char_left = MENU_LEFT + i * (CHAR_W + CHAR_SP);
                if (pixel_x >= char_left && pixel_x < char_left + CHAR_W &&
                    pixel_y >= MENU_TOP  && pixel_y < MENU_TOP + CHAR_H) begin
                    row_idx = (pixel_y - MENU_TOP) / SCALE;
                    col_idx = (pixel_x - char_left) / SCALE;
                    if (font_row(i[2:0], row_idx[2:0])[4 - col_idx])
                        pixel_on = 1'b1;
                end
            end

            if (pixel_on)
                color_out_332 = COLOR_WHITE;
        end
    end

    // ------------------------------------------------------------------
    // Game mode, LEDs and start signal
    // ------------------------------------------------------------------
    assign mode_hex = sw0_mode_select ? 4'h2 : 4'h1;

    assign leds_out = 10'b0000000000;

    // start_game asserted when any player 1 button is pressed
    assign start_game = |p1_buttons;

endmodule
