
module graphics_mixer (
    // VGA timing / display enable
    input  wire        display_enable,         // VGA “DE” signal
    input  wire [9:0]  pixel_x,                // current pixel X (0–639)
    input  wire [9:0]  pixel_y,                // current pixel Y (0–479)

    // Background generator output
    input  wire [7:0]  background_color_in_332, // RRRGGGBB format

    // Character geometry & appearance from player_logic
    input  wire [9:0]  char_x_pos,              // top-left X of character
    input  wire [9:0]  char_y_pos,              // top-left Y of character
    input  wire [9:0]  char_width,              // width in pixels
    input  wire [9:0]  char_height,             // height in pixels
    input  wire [7:0]  char_color_in_332,       // body (hurtbox) color
    input  wire [1:0]  attack_phase,            // 00=none, 01=startup, 10=active, 11=recovery

    // Final VGA pixel output
    output reg  [7:0]  final_pixel_color_out_332
);

    // Wires to capture character_renderer outputs
    wire [7:0] sprite_color;
    wire       sprite_visible;

    
    character_renderer mixer_inst (
        .display_enable               (display_enable),
        .current_pixel_x              (pixel_x),
        .current_pixel_y              (pixel_y),

        .char_x_pos_in                (char_x_pos),
        .char_y_pos_in                (char_y_pos),
        .char_width_in                (char_width),
        .char_height_in               (char_height),
        .char_color_in_332            (char_color_in_332),

        .attack_phase_in              (attack_phase),

        .char_pixel_color_out_332     (sprite_color),
        .char_is_visible_at_pixel_out (sprite_visible)
    );

    
    always @(*) begin
        if (!display_enable) begin
            final_pixel_color_out_332 = 8'b00000000;
        end else if (sprite_visible) begin
            final_pixel_color_out_332 = sprite_color;
        end else begin
            final_pixel_color_out_332 = background_color_in_332;
        end
    end

endmodule
