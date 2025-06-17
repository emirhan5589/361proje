
// graphics_mixer.v (Corrected)
module graphics_mixer (
    // VGA timing / display enable
    input  wire        display_enable,         // VGA "DE" signal
    input  wire [9:0]  pixel_x,                // current pixel X (0–639)
    input  wire [9:0]  pixel_y,                // current pixel Y (0–479)

    // Background generator output
    input  wire [7:0]  background_color_in_332, // RRRGGGBB format

    // Player 1 geometry & appearance
    input  wire [9:0]  char1_x_pos,
    input  wire [9:0]  char1_y_pos,
    input  wire [9:0]  char1_width,
    input  wire [9:0]  char1_height,
    input  wire [7:0]  char1_color_in_332,
    input  wire [1:0]  char1_attack_phase,

    // Player 2 geometry & appearance
    input  wire [9:0]  char2_x_pos,
    input  wire [9:0]  char2_y_pos,
    input  wire [9:0]  char2_width,
    input  wire [9:0]  char2_height,
    input  wire [7:0]  char2_color_in_332,
    input  wire [1:0]  char2_attack_phase,

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
    wire [7:0] sprite1_color;
    wire       sprite1_visible;
    wire [7:0] sprite2_color;
    wire       sprite2_visible;

    // Character renderer for player 1
    character_renderer char1_inst (
        .display_enable               (display_enable),
        .current_pixel_x              (pixel_x),
        .current_pixel_y              (pixel_y),
        .char_x_pos_in                (char1_x_pos),
        .char_y_pos_in                (char1_y_pos),
        .char_width_in                (char1_width),
        .char_height_in               (char1_height),
        .char_color_in_332            (char1_color_in_332),

        .attack_phase_in              (char1_attack_phase),

        .char_pixel_color_out_332     (sprite1_color),
        .char_is_visible_at_pixel_out (sprite1_visible)
    );

    // Character renderer for player 2
    character_renderer char2_inst (
        .display_enable               (display_enable),
        .current_pixel_x              (pixel_x),
        .current_pixel_y              (pixel_y),

        .char_x_pos_in                (char2_x_pos),
        .char_y_pos_in                (char2_y_pos),
        .char_width_in                (char2_width),
        .char_height_in               (char2_height),
        .char_color_in_332            (char2_color_in_332),

        .attack_phase_in              (char2_attack_phase),

        .char_pixel_color_out_332     (sprite2_color),
        .char_is_visible_at_pixel_out (sprite2_visible)
    );

    // Final mixing logic
    always @(*) begin
        if (!display_enable) begin
            final_pixel_color_out_332 = 8'b00000000;
        end else if (menu_pixel_visible) begin
            // Menu/countdown takes highest priority
            final_pixel_color_out_332 = menu_color_in_332;
        end else if (gameplay_active && sprite2_visible) begin
            // Player 2 sprite has priority
            final_pixel_color_out_332 = sprite2_color;
        end else if (gameplay_active && sprite1_visible) begin
            final_pixel_color_out_332 = sprite1_color;
        end else begin
            // Background
            final_pixel_color_out_332 = background_color_in_332;
        end
    end

endmodule
