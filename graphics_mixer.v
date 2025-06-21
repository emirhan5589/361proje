
// graphics_mixer.v (Corrected)
module graphics_mixer (
    // VGA timing / display enable
    input  wire        display_enable,         // VGA "DE" signal
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

    // Menu system inputs - ADD THESE
    input  wire [2:0]  current_game_state,      // Game state
    input  wire [7:0]  menu_color_in_332,       // Menu graphics color
    input  wire        menu_pixel_visible,      // Menu visibility flag

    // Final VGA pixel output
    output reg  [7:0]  final_pixel_color_out_332
);

    // Game state definitions
    localparam STATE_MENU      = 3'b000;
    localparam STATE_COUNTDOWN = 3'b001;
    localparam STATE_GAMEPLAY  = 3'b010;
    localparam STATE_GAME_OVER = 3'b011;

    // Determine current mode
    wire gameplay_active = (current_game_state == STATE_GAMEPLAY);

    // Wires to capture character_renderer outputs
    wire [7:0] sprite_color;
    wire       sprite_visible;

    // Character renderer (only for gameplay)
    character_renderer char_inst (
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

    // Final mixing logic
    always @(*) begin
        if (!display_enable) begin
            final_pixel_color_out_332 = 8'b00000000;
        end else if (menu_pixel_visible) begin
            // Menu/countdown takes highest priority
            final_pixel_color_out_332 = menu_color_in_332;
        end else if (gameplay_active && sprite_visible) begin
            // Character sprites only in gameplay mode
            final_pixel_color_out_332 = sprite_color;
        end else begin
            // Background
            final_pixel_color_out_332 = background_color_in_332;
        end
    end

endmodule
