// -------------------------------------------------------------
// Menu screen logic for the DE1-SoC fighting game
// -------------------------------------------------------------
// Renders the word "MENU" using a simple bitmap font and drives the
// seven-segment displays with "1P" or "2P" depending on SW[0].  A
// rising edge on `key_pressed` causes the module to deassert
// `in_menu_state` and generate a one-cycle `start_game` pulse.
// -------------------------------------------------------------

module menu_screen (
    input  wire        clk,
    input  wire        reset,
    input  wire        video_on,
    input  wire [9:0]  x,
    input  wire [9:0]  y,

    input  wire        sw0_mode_select,
    input  wire        key_pressed,

    output reg  [2:0]  vga_r,
    output reg  [2:0]  vga_g,
    output reg  [1:0]  vga_b,

    output wire [6:0]  HEX0,
    output wire [6:0]  HEX1,
    output wire [6:0]  HEX2,
    output wire [6:0]  HEX3,
    output wire [6:0]  HEX4,
    output wire [6:0]  HEX5,

    output wire [9:0]  LEDR,

    output reg         in_menu_state,
    output reg         start_game
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
    reg [7:0] color_out_332;

    always @(*) begin
        if (!video_on) begin
            color_out_332 = COLOR_BLACK;
        end else begin
            color_out_332 = COLOR_BG;
            pixel_on = 1'b0;

            for (i = 0; i < 4; i = i + 1) begin
                char_left = MENU_LEFT + i * (CHAR_W + CHAR_SP);
                if (x >= char_left && x < char_left + CHAR_W &&
                    y >= MENU_TOP  && y < MENU_TOP + CHAR_H) begin
                    row_idx = (y - MENU_TOP) / SCALE;
                    col_idx = (x - char_left) / SCALE;
                    if (font_row(i[2:0], row_idx[2:0])[4 - col_idx])
                        pixel_on = 1'b1;
                end
            end

            if (pixel_on)
                color_out_332 = COLOR_WHITE;
        end
    end

    // ------------------------------------------------------------------
    // VGA colour channel mapping
    // ------------------------------------------------------------------
    always @(*) begin
        vga_r = color_out_332[7:5];
        vga_g = color_out_332[4:2];
        vga_b = color_out_332[1:0];
    end

    // ------------------------------------------------------------------
    // Seven-segment displays and LEDs
    // ------------------------------------------------------------------
    wire [3:0] mode_digit = sw0_mode_select ? 4'h2 : 4'h1;
    hexto7seg hex0_inst (.hexn(HEX0), .hex(mode_digit));

    localparam [6:0] SEG_P   = 7'b0001100;
    localparam [6:0] SEG_OFF = 7'b1111111;

    assign HEX1 = SEG_P;
    assign HEX2 = SEG_OFF;
    assign HEX3 = SEG_OFF;
    assign HEX4 = SEG_OFF;
    assign HEX5 = SEG_OFF;

    assign LEDR = 10'b0000000000;

    // ------------------------------------------------------------------
    // Menu state and start signal generation
    // ------------------------------------------------------------------
    reg prev_key;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            in_menu_state <= 1'b1;
            start_game    <= 1'b0;
            prev_key      <= 1'b0;
        end else begin
            prev_key <= key_pressed;
            if (in_menu_state && key_pressed && !prev_key) begin
                start_game    <= 1'b1;
                in_menu_state <= 1'b0;
            end else begin
                start_game <= 1'b0;
            end
        end
    end

endmodule
