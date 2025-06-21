// text_renderer.v
module text_renderer (
    input wire pixel_clk,
    input wire reset,
    input wire display_enable,
    input wire [9:0] pixel_x,
    input wire [9:0] pixel_y,
    
    // Text configuration
    input wire text_enable,
    input wire [9:0] text_x_pos,        // Top-left X position
    input wire [9:0] text_y_pos,        // Top-left Y position
    input wire [7:0] text_color_332,    // Text color
    input wire [3:0] text_id,           // Which text to display
    
    // Output
    output reg [7:0] text_pixel_color_332,
    output reg text_pixel_visible
);

    // Font parameters - 8x16 characters
    localparam CHAR_WIDTH = 8;
    localparam CHAR_HEIGHT = 16;
    
    // Text IDs
    localparam TEXT_MENU = 4'd0;
    localparam TEXT_1_PLAYER = 4'd1;
    localparam TEXT_2_PLAYER = 4'd2;
    localparam TEXT_PRESS_BUTTON = 4'd3;
    localparam TEXT_COUNT_3 = 4'd4;
    localparam TEXT_COUNT_2 = 4'd5;
    localparam TEXT_COUNT_1 = 4'd6;
    localparam TEXT_START = 4'd7;
    
    // Calculate character position within text
    wire [9:0] rel_x = pixel_x - text_x_pos;
    wire [9:0] rel_y = pixel_y - text_y_pos;
    wire [3:0] char_x = rel_x[6:3];  // Which character (divide by 8)
    wire [2:0] pixel_in_char_x = rel_x[2:0];  // Which pixel in character
    wire [3:0] pixel_in_char_y = rel_y[3:0];  // Which row in character
    
    // Simple bitmap font data - each character is 8x16
    reg [7:0] font_data;
    wire font_pixel = font_data[7 - pixel_in_char_x];
    
    // Text boundaries based on text_id
    reg [3:0] text_width;  // Number of characters
    // Update the text width case statement:
always @(*) begin
    case (text_id)
        TEXT_MENU:        text_width = 4;   // "MENU"
        TEXT_1_PLAYER:    text_width = 3;   // "1-P" (simplified)
        TEXT_2_PLAYER:    text_width = 3;   // "2-P" (simplified)
        TEXT_PRESS_BUTTON: text_width = 11;  // "PRESS START"
        TEXT_COUNT_3:     text_width = 1;   // "3"
        TEXT_COUNT_2:     text_width = 1;   // "2"
        TEXT_COUNT_1:     text_width = 1;   // "1"
        TEXT_START:       text_width = 5;   // "START"
        default:          text_width = 0;
    endcase
end

    
    // Check if pixel is within text bounds
    wire in_text_bounds = text_enable && display_enable &&
                         (pixel_x >= text_x_pos) && 
                         (pixel_x < text_x_pos + (text_width * CHAR_WIDTH)) &&
                         (pixel_y >= text_y_pos) && 
                         (pixel_y < text_y_pos + CHAR_HEIGHT);
    
    // Font ROM - simplified 8x16 font
    always @(*) begin
        font_data = 8'h00;  // Default blank
        
        if (in_text_bounds) begin
            case (text_id)
				
				
				
				TEXT_PRESS_BUTTON: begin
    case (char_x)
        0: begin  // 'P'
            case (pixel_in_char_y)
                0:  font_data = 8'b11111110;
                1:  font_data = 8'b11000011;
                2:  font_data = 8'b11000011;
                3:  font_data = 8'b11000011;
                4:  font_data = 8'b11111110;
                5:  font_data = 8'b11000000;
                6:  font_data = 8'b11000000;
                7:  font_data = 8'b11000000;
                8:  font_data = 8'b11000000;
                9:  font_data = 8'b11000000;
                10: font_data = 8'b11000000;
                11: font_data = 8'b11000000;
                12: font_data = 8'b11000000;
                13: font_data = 8'b11000000;
                14: font_data = 8'b11000000;
                15: font_data = 8'b00000000;
                default: font_data = 8'h00;
            endcase
        end
        1: begin  // 'R'
            case (pixel_in_char_y)
                0:  font_data = 8'b11111110;
                1:  font_data = 8'b11000011;
                2:  font_data = 8'b11000011;
                3:  font_data = 8'b11000011;
                4:  font_data = 8'b11111110;
                5:  font_data = 8'b11111000;
                6:  font_data = 8'b11001100;
                7:  font_data = 8'b11000110;
                8:  font_data = 8'b11000011;
                9:  font_data = 8'b11000011;
                10: font_data = 8'b11000011;
                11: font_data = 8'b11000011;
                12: font_data = 8'b11000011;
                13: font_data = 8'b11000011;
                14: font_data = 8'b11000011;
                15: font_data = 8'b00000000;
                default: font_data = 8'h00;
            endcase
        end
        2: begin  // 'E'
            case (pixel_in_char_y)
                0:  font_data = 8'b11111111;
                1:  font_data = 8'b11000000;
                2:  font_data = 8'b11000000;
                3:  font_data = 8'b11000000;
                4:  font_data = 8'b11111110;
                5:  font_data = 8'b11000000;
                6:  font_data = 8'b11000000;
                7:  font_data = 8'b11000000;
                8:  font_data = 8'b11000000;
                9:  font_data = 8'b11000000;
                10: font_data = 8'b11000000;
                11: font_data = 8'b11000000;
                12: font_data = 8'b11000000;
                13: font_data = 8'b11000000;
                14: font_data = 8'b11111111;
                15: font_data = 8'b00000000;
                default: font_data = 8'h00;
            endcase
        end
        3: begin  // 'S'
            case (pixel_in_char_y)
                0:  font_data = 8'b01111110;
                1:  font_data = 8'b11000011;
                2:  font_data = 8'b11000000;
                3:  font_data = 8'b11000000;
                4:  font_data = 8'b01111110;
                5:  font_data = 8'b00000011;
                6:  font_data = 8'b00000011;
                7:  font_data = 8'b00000011;
                8:  font_data = 8'b00000011;
                9:  font_data = 8'b00000011;
                10: font_data = 8'b00000011;
                11: font_data = 8'b11000011;
                12: font_data = 8'b01111110;
                13: font_data = 8'b00000000;
                14: font_data = 8'b00000000;
                15: font_data = 8'b00000000;
                default: font_data = 8'h00;
            endcase
        end
        4: begin  // 'S'
            case (pixel_in_char_y)
                0:  font_data = 8'b01111110;
                1:  font_data = 8'b11000011;
                2:  font_data = 8'b11000000;
                3:  font_data = 8'b11000000;
                4:  font_data = 8'b01111110;
                5:  font_data = 8'b00000011;
                6:  font_data = 8'b00000011;
                7:  font_data = 8'b00000011;
                8:  font_data = 8'b00000011;
                9:  font_data = 8'b00000011;
                10: font_data = 8'b00000011;
                11: font_data = 8'b11000011;
                12: font_data = 8'b01111110;
                13: font_data = 8'b00000000;
                14: font_data = 8'b00000000;
                15: font_data = 8'b00000000;
                default: font_data = 8'h00;
            endcase
        end
        5: begin  // ' ' (space)
            font_data = 8'h00;
        end
        6: begin  // 'S'
            case (pixel_in_char_y)
                0:  font_data = 8'b01111110;
                1:  font_data = 8'b11000011;
                2:  font_data = 8'b11000000;
                3:  font_data = 8'b11000000;
                4:  font_data = 8'b01111110;
                5:  font_data = 8'b00000011;
                6:  font_data = 8'b00000011;
                7:  font_data = 8'b00000011;
                8:  font_data = 8'b00000011;
                9:  font_data = 8'b00000011;
                10: font_data = 8'b00000011;
                11: font_data = 8'b11000011;
                12: font_data = 8'b01111110;
                13: font_data = 8'b00000000;
                14: font_data = 8'b00000000;
                15: font_data = 8'b00000000;
                default: font_data = 8'h00;
            endcase
        end
        7: begin  // 'T'
            case (pixel_in_char_y)
                0:  font_data = 8'b11111111;
                1:  font_data = 8'b00011000;
                2:  font_data = 8'b00011000;
                3:  font_data = 8'b00011000;
                4:  font_data = 8'b00011000;
                5:  font_data = 8'b00011000;
                6:  font_data = 8'b00011000;
                7:  font_data = 8'b00011000;
                8:  font_data = 8'b00011000;
                9:  font_data = 8'b00011000;
                10: font_data = 8'b00011000;
                11: font_data = 8'b00011000;
                12: font_data = 8'b00011000;
                13: font_data = 8'b00011000;
                14: font_data = 8'b00011000;
                15: font_data = 8'b00000000;
                default: font_data = 8'h00;
            endcase
        end
        8: begin  // 'A'
            case (pixel_in_char_y)
                0:  font_data = 8'b00111100;
                1:  font_data = 8'b01100110;
                2:  font_data = 8'b11000011;
                3:  font_data = 8'b11000011;
                4:  font_data = 8'b11000011;
                5:  font_data = 8'b11111111;
                6:  font_data = 8'b11000011;
                7:  font_data = 8'b11000011;
                8:  font_data = 8'b11000011;
                9:  font_data = 8'b11000011;
                10: font_data = 8'b11000011;
                11: font_data = 8'b11000011;
                12: font_data = 8'b11000011;
                13: font_data = 8'b11000011;
                14: font_data = 8'b11000011;
                15: font_data = 8'b00000000;
                default: font_data = 8'h00;
            endcase
        end
        9: begin  // 'R'
            case (pixel_in_char_y)
                0:  font_data = 8'b11111110;
                1:  font_data = 8'b11000011;
                2:  font_data = 8'b11000011;
                3:  font_data = 8'b11000011;
                4:  font_data = 8'b11111110;
                5:  font_data = 8'b11111000;
                6:  font_data = 8'b11001100;
                7:  font_data = 8'b11000110;
                8:  font_data = 8'b11000011;
                9:  font_data = 8'b11000011;
                10: font_data = 8'b11000011;
                11: font_data = 8'b11000011;
                12: font_data = 8'b11000011;
                13: font_data = 8'b11000011;
                14: font_data = 8'b11000011;
                15: font_data = 8'b00000000;
                default: font_data = 8'h00;
            endcase
        end
        10: begin  // 'T'
            case (pixel_in_char_y)
                0:  font_data = 8'b11111111;
                1:  font_data = 8'b00011000;
                2:  font_data = 8'b00011000;
                3:  font_data = 8'b00011000;
                4:  font_data = 8'b00011000;
                5:  font_data = 8'b00011000;
                6:  font_data = 8'b00011000;
                7:  font_data = 8'b00011000;
                8:  font_data = 8'b00011000;
                9:  font_data = 8'b00011000;
                10: font_data = 8'b00011000;
                11: font_data = 8'b00011000;
                12: font_data = 8'b00011000;
                13: font_data = 8'b00011000;
                14: font_data = 8'b00011000;
                15: font_data = 8'b00000000;
                default: font_data = 8'h00;
            endcase
        end
        default: font_data = 8'h00;
    endcase
end
				
				
				
				
                TEXT_MENU: begin
                    case (char_x)
                        0: begin  // 'M'
                            case (pixel_in_char_y)
                                0:  font_data = 8'b11000011;
                                1:  font_data = 8'b11100111;
                                2:  font_data = 8'b11111111;
                                3:  font_data = 8'b11011011;
                                4:  font_data = 8'b11000011;
                                5:  font_data = 8'b11000011;
                                6:  font_data = 8'b11000011;
                                7:  font_data = 8'b11000011;
                                8:  font_data = 8'b11000011;
                                9:  font_data = 8'b11000011;
                                10: font_data = 8'b11000011;
                                11: font_data = 8'b11000011;
                                12: font_data = 8'b11000011;
                                13: font_data = 8'b11000011;
                                14: font_data = 8'b11000011;
                                15: font_data = 8'b00000000;
                                default: font_data = 8'h00;
                            endcase
                        end
                        1: begin  // 'E'
                            case (pixel_in_char_y)
                                0:  font_data = 8'b11111111;
                                1:  font_data = 8'b11000000;
                                2:  font_data = 8'b11000000;
                                3:  font_data = 8'b11000000;
                                4:  font_data = 8'b11111110;
                                5:  font_data = 8'b11000000;
                                6:  font_data = 8'b11000000;
                                7:  font_data = 8'b11000000;
                                8:  font_data = 8'b11000000;
                                9:  font_data = 8'b11000000;
                                10: font_data = 8'b11000000;
                                11: font_data = 8'b11000000;
                                12: font_data = 8'b11000000;
                                13: font_data = 8'b11000000;
                                14: font_data = 8'b11111111;
                                15: font_data = 8'b00000000;
                                default: font_data = 8'h00;
                            endcase
                        end
                        2: begin  // 'N'
                            case (pixel_in_char_y)
                                0:  font_data = 8'b11000011;
                                1:  font_data = 8'b11100011;
                                2:  font_data = 8'b11110011;
                                3:  font_data = 8'b11111011;
                                4:  font_data = 8'b11011111;
                                5:  font_data = 8'b11001111;
                                6:  font_data = 8'b11000111;
                                7:  font_data = 8'b11000011;
                                8:  font_data = 8'b11000011;
                                9:  font_data = 8'b11000011;
                                10: font_data = 8'b11000011;
                                11: font_data = 8'b11000011;
                                12: font_data = 8'b11000011;
                                13: font_data = 8'b11000011;
                                14: font_data = 8'b11000011;
                                15: font_data = 8'b00000000;
                                default: font_data = 8'h00;
                            endcase
                        end
                        3: begin  // 'U'
                            case (pixel_in_char_y)
                                0:  font_data = 8'b11000011;
                                1:  font_data = 8'b11000011;
                                2:  font_data = 8'b11000011;
                                3:  font_data = 8'b11000011;
                                4:  font_data = 8'b11000011;
                                5:  font_data = 8'b11000011;
                                6:  font_data = 8'b11000011;
                                7:  font_data = 8'b11000011;
                                8:  font_data = 8'b11000011;
                                9:  font_data = 8'b11000011;
                                10: font_data = 8'b11000011;
                                11: font_data = 8'b11000011;
                                12: font_data = 8'b01100110;
                                13: font_data = 8'b00111100;
                                14: font_data = 8'b00011000;
                                15: font_data = 8'b00000000;
                                default: font_data = 8'h00;
                            endcase
                        end
                        default: font_data = 8'h00;
                    endcase
                end
                
                TEXT_1_PLAYER: begin
                    case (char_x)
                        0: begin  // '1'
                            case (pixel_in_char_y)
                                0:  font_data = 8'b00011000;
                                1:  font_data = 8'b00111000;
                                2:  font_data = 8'b00011000;
                                3:  font_data = 8'b00011000;
                                4:  font_data = 8'b00011000;
                                5:  font_data = 8'b00011000;
                                6:  font_data = 8'b00011000;
                                7:  font_data = 8'b00011000;
                                8:  font_data = 8'b00011000;
                                9:  font_data = 8'b00011000;
                                10: font_data = 8'b00011000;
                                11: font_data = 8'b00011000;
                                12: font_data = 8'b00011000;
                                13: font_data = 8'b00011000;
                                14: font_data = 8'b01111110;
                                15: font_data = 8'b00000000;
                                default: font_data = 8'h00;
                            endcase
                        end
                        1: begin  // '-'
                            case (pixel_in_char_y)
                                7:  font_data = 8'b11111111;
                                8:  font_data = 8'b11111111;
                                default: font_data = 8'h00;
                            endcase
                        end
                        2: begin  // 'P' (start of PLAYER)
                            case (pixel_in_char_y)
                                0:  font_data = 8'b11111110;
                                1:  font_data = 8'b11000011;
                                2:  font_data = 8'b11000011;
                                3:  font_data = 8'b11000011;
                                4:  font_data = 8'b11111110;
                                5:  font_data = 8'b11000000;
                                6:  font_data = 8'b11000000;
                                7:  font_data = 8'b11000000;
                                8:  font_data = 8'b11000000;
                                9:  font_data = 8'b11000000;
                                10: font_data = 8'b11000000;
                                11: font_data = 8'b11000000;
                                12: font_data = 8'b11000000;
                                13: font_data = 8'b11000000;
                                14: font_data = 8'b11000000;
                                15: font_data = 8'b00000000;
                                default: font_data = 8'h00;
                            endcase
                        end
                        // Add more characters for "LAYER" if needed, or simplify to "1P"
                        default: font_data = 8'h00;
                    endcase
                end
                
                TEXT_2_PLAYER: begin
                    case (char_x)
                        0: begin  // '2'
                            case (pixel_in_char_y)
                                0:  font_data = 8'b01111110;
                                1:  font_data = 8'b11000011;
                                2:  font_data = 8'b00000011;
                                3:  font_data = 8'b00000011;
                                4:  font_data = 8'b00000110;
                                5:  font_data = 8'b00001100;
                                6:  font_data = 8'b00011000;
                                7:  font_data = 8'b00110000;
                                8:  font_data = 8'b01100000;
                                9:  font_data = 8'b11000000;
                                10: font_data = 8'b11000000;
                                11: font_data = 8'b11000000;
                                12: font_data = 8'b11000011;
                                13: font_data = 8'b11000011;
                                14: font_data = 8'b11111111;
                                15: font_data = 8'b00000000;
                                default: font_data = 8'h00;
                            endcase
                        end
                        1: begin  // '-'
                            case (pixel_in_char_y)
                                7:  font_data = 8'b11111111;
                                8:  font_data = 8'b11111111;
                                default: font_data = 8'h00;
                            endcase
                        end
                        2: begin  // 'P' (start of PLAYER)
                            case (pixel_in_char_y)
                                0:  font_data = 8'b11111110;
                                1:  font_data = 8'b11000011;
                                2:  font_data = 8'b11000011;
                                3:  font_data = 8'b11000011;
                                4:  font_data = 8'b11111110;
                                5:  font_data = 8'b11000000;
                                6:  font_data = 8'b11000000;
                                7:  font_data = 8'b11000000;
                                8:  font_data = 8'b11000000;
                                9:  font_data = 8'b11000000;
                                10: font_data = 8'b11000000;
                                11: font_data = 8'b11000000;
                                12: font_data = 8'b11000000;
                                13: font_data = 8'b11000000;
                                14: font_data = 8'b11000000;
                                15: font_data = 8'b00000000;
                                default: font_data = 8'h00;
                            endcase
                        end
                        default: font_data = 8'h00;
                    endcase
                end
                
                // Countdown numbers
                TEXT_COUNT_3: begin
                    case (pixel_in_char_y)
                        1:  font_data = 8'b01111110;
                        2:  font_data = 8'b11000011;
                        3:  font_data = 8'b00000011;
                        4:  font_data = 8'b00000011;
                        5:  font_data = 8'b00111110;
                        6:  font_data = 8'b00000011;
                        7:  font_data = 8'b00000011;
                        8:  font_data = 8'b00000011;
                        9:  font_data = 8'b00000011;
                        10: font_data = 8'b00000011;
                        11: font_data = 8'b11000011;
                        12: font_data = 8'b01111110;
                        default: font_data = 8'h00;
                    endcase
                end
                
                TEXT_COUNT_2: begin
                    case (pixel_in_char_y)
                        1:  font_data = 8'b01111110;
                        2:  font_data = 8'b11000011;
                        3:  font_data = 8'b00000011;
                        4:  font_data = 8'b00000110;
                        5:  font_data = 8'b00001100;
                        6:  font_data = 8'b00011000;
                        7:  font_data = 8'b00110000;
                        8:  font_data = 8'b01100000;
                        9:  font_data = 8'b11000000;
                        10: font_data = 8'b11000011;
                        11: font_data = 8'b11111111;
                        default: font_data = 8'h00;
                    endcase
                end
                
                TEXT_COUNT_1: begin
                    case (pixel_in_char_y)
                        1:  font_data = 8'b00011000;
                        2:  font_data = 8'b00111000;
                        3:  font_data = 8'b00011000;
                        4:  font_data = 8'b00011000;
                        5:  font_data = 8'b00011000;
                        6:  font_data = 8'b00011000;
                        7:  font_data = 8'b00011000;
                        8:  font_data = 8'b00011000;
                        9:  font_data = 8'b00011000;
                        10: font_data = 8'b00011000;
                        11: font_data = 8'b01111110;
                        default: font_data = 8'h00;
                    endcase
                end
                
                default: font_data = 8'h00;
            endcase
        end
    end
    
    // Output logic
    always @(*) begin
        if (in_text_bounds && font_pixel) begin
            text_pixel_visible = 1'b1;
            text_pixel_color_332 = text_color_332;
        end else begin
            text_pixel_visible = 1'b0;
            text_pixel_color_332 = 8'b00000000;
        end
    end
    
endmodule
