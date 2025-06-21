// graphics_mixer.v (Updated for Two Players)
module graphics_mixer (
    // VGA timing / display enable
    input  wire        display_enable,         // VGA "DE" signal
    input  wire [9:0]  pixel_x,                // current pixel X (0–639)
    input  wire [9:0]  pixel_y,                // current pixel Y (0–479)

    // Background generator output
    input  wire [7:0]  background_color_in_332, // RRRGGGBB format

    // Player 1 character geometry & appearance
    input  wire [9:0]  p1_char_x_pos,           // top-left X of P1 character
    input  wire [9:0]  p1_char_y_pos,           // top-left Y of P1 character
    input  wire [9:0]  p1_char_width,           // P1 width in pixels
    input  wire [9:0]  p1_char_height,          // P1 height in pixels
    input  wire [7:0]  p1_char_color_in_332,    // P1 body (hurtbox) color
    input  wire [1:0]  p1_attack_phase,         // P1 attack phase

    // Player 2 character geometry & appearance
    input  wire [9:0]  p2_char_x_pos,           // top-left X of P2 character
    input  wire [9:0]  p2_char_y_pos,           // top-left Y of P2 character
    input  wire [9:0]  p2_char_width,           // P2 width in pixels
    input  wire [9:0]  p2_char_height,          // P2 height in pixels
    input  wire [7:0]  p2_char_color_in_332,    // P2 body (hurtbox) color
    input  wire [1:0]  p2_attack_phase,         // P2 attack phase

    // Menu system inputs
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

    // Wires to capture character_renderer outputs for both players
    wire [7:0] p1_sprite_color;
    wire       p1_sprite_visible;
    wire [7:0] p2_sprite_color;
    wire       p2_sprite_visible;

    // Character renderer for Player 1
    character_renderer p1_char_inst (
        .display_enable               (display_enable),
        .current_pixel_x              (pixel_x),
        .current_pixel_y              (pixel_y),

        .char_x_pos_in                (p1_char_x_pos),
        .char_y_pos_in                (p1_char_y_pos),
        .char_width_in                (p1_char_width),
        .char_height_in               (p1_char_height),
        .char_color_in_332            (p1_char_color_in_332),

        .attack_phase_in              (p1_attack_phase),

        .char_pixel_color_out_332     (p1_sprite_color),
        .char_is_visible_at_pixel_out (p1_sprite_visible)
    );

    // Character renderer for Player 2
    character_renderer_p2 p2_char_inst (
        .display_enable               (display_enable),
        .current_pixel_x              (pixel_x),
        .current_pixel_y              (pixel_y),

        .char_x_pos_in                (p2_char_x_pos),
        .char_y_pos_in                (p2_char_y_pos),
        .char_width_in                (p2_char_width),
        .char_height_in               (p2_char_height),
        .char_color_in_332            (p2_char_color_in_332),

        .attack_phase_in              (p2_attack_phase),

        .char_pixel_color_out_332     (p2_sprite_color),
        .char_is_visible_at_pixel_out (p2_sprite_visible)
    );

    // Final mixing logic with priority: Menu > P2 > P1 > Background
    always @(*) begin
        if (!display_enable) begin
            final_pixel_color_out_332 = 8'b00000000;
        end else if (menu_pixel_visible) begin
            // Menu/countdown takes highest priority
            final_pixel_color_out_332 = menu_color_in_332;
        end else if (gameplay_active && p2_sprite_visible) begin
            // Player 2 sprites have priority over Player 1
            final_pixel_color_out_332 = p2_sprite_color;
        end else if (gameplay_active && p1_sprite_visible) begin
            // Player 1 sprites
            final_pixel_color_out_332 = p1_sprite_color;
        end else begin
            // Background
            final_pixel_color_out_332 = background_color_in_332;
        end
    end

endmodule
