
module character_renderer (
    // Inputs from VGA timing and higher-level logic
    input  wire        display_enable,
    input  wire [9:0]  current_pixel_x,
    input  wire [9:0]  current_pixel_y,

    // Character positioning and appearance
    input  wire [9:0]  char_x_pos_in,
    input  wire [9:0]  char_y_pos_in,
    input  wire [9:0]  char_width_in,
    input  wire [9:0]  char_height_in,
    input  wire [7:0]  char_color_in_332,

    
    input  wire [1:0]  attack_phase_in,

    // Outputs for graphics mixer
    output reg  [7:0]  char_pixel_color_out_332,
    output reg         char_is_visible_at_pixel_out
);

    // Body (hurtbox) bounds
    wire [9:0] body_right  = char_x_pos_in + char_width_in  - 1;
    wire [9:0] body_bottom = char_y_pos_in + char_height_in - 1;
    wire        in_body_x  = (current_pixel_x >= char_x_pos_in) && (current_pixel_x <= body_right);
    wire        in_body_y  = (current_pixel_y >= char_y_pos_in) && (current_pixel_y <= body_bottom);

    // Hitbox (attack box) bounds: 8×32, placed directly to the right of the body
    localparam HITBOX_WIDTH  = 32;
    localparam HITBOX_HEIGHT = 8;
    wire [9:0] hitbox_left   = body_right + 1;
    wire [9:0] hitbox_right  = hitbox_left + HITBOX_WIDTH  - 1;
    wire [9:0] hitbox_top    = char_y_pos_in + (char_height_in >> 1) - (HITBOX_HEIGHT >> 1);
    wire [9:0] hitbox_bottom = hitbox_top   + HITBOX_HEIGHT - 1;
    wire        in_hitbox_x  = (current_pixel_x >= hitbox_left)  && (current_pixel_x <= hitbox_right);
    wire        in_hitbox_y  = (current_pixel_y >= hitbox_top)   && (current_pixel_y <= hitbox_bottom);

    always @(*) begin
        // Default: transparent
        char_is_visible_at_pixel_out = 1'b0;
        char_pixel_color_out_332    = 8'b00000000;

        // Draw hurtbox (body) — always visible
        if (display_enable && in_body_x && in_body_y) begin
            char_is_visible_at_pixel_out = 1'b1;
            char_pixel_color_out_332     = char_color_in_332;
        end

        // Draw hitbox during attack phases
        if (display_enable && (attack_phase_in != 2'b00) && in_hitbox_x && in_hitbox_y) begin
            char_is_visible_at_pixel_out = 1'b1;
            case (attack_phase_in)
                2'b01: char_pixel_color_out_332 = 8'b000_000_11; // Blue (Startup)
                2'b10: char_pixel_color_out_332 = 8'b111_000_00; // Red   (Active)
                2'b11: char_pixel_color_out_332 = 8'b000_111_00; // Green (Recovery)
                default: char_pixel_color_out_332 = 8'b00000000;
            endcase
        end
    end

endmodule
