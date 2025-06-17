// player_state_static.v
// Provides static (fixed) properties for a single character object.
// For Milestone Objective 2: "A single character rendered as an arbitrary object."

module player_state_static (
    // Outputs: Character properties
    // These are effectively constants for this static version.
    // We use 'output wire' and assign them using 'localparam' via 'assign'
    // or directly use 'localparam' if the instantiating module can access them.
    // Using output ports is cleaner for module interface.

    output wire [9:0] char_x_pos_out,    // Top-left X position
    output wire [9:0] char_y_pos_out,    // Top-left Y position
    output wire [9:0] char_width_out,    // Width of the character
    output wire [9:0] char_height_out,   // Height of the character
    output wire [7:0] char_color_out_332 // Color in RRRGGGBB format
);

    // --- Define Character Parameters ---

    // Dimensions (example values, can be adjusted)
    localparam P_CHAR_WIDTH  = 10'd32;  // Character width in pixels
    localparam P_CHAR_HEIGHT = 10'd60; // Character height in pixels

    // Position (example values, can be adjusted)
    // Screen is 640x480. (0,0) is top-left.
    // Let's center it horizontally and place it some distance from the bottom.
    localparam SCREEN_WIDTH  = 10'd640;
    localparam SCREEN_HEIGHT = 10'd480;
    localparam FLOOR_OFFSET  = 10'd40;   // How far from the "bottom" of active display

    localparam P_CHAR_X_POS = (SCREEN_WIDTH / 2) - (P_CHAR_WIDTH / 2); // Approx. (640/2)-(32/2) = 320-16 = 304
    localparam P_CHAR_Y_POS = SCREEN_HEIGHT - P_CHAR_HEIGHT - FLOOR_OFFSET; // 480 - 60 - 40 = 380

    // Color (RRRGGGBB format)
    // Example: A light yellow/cream color (R=7, G=7, B=2)
    // RRR = 111
    // GGG = 111
    // BB  = 10
    localparam P_CHAR_COLOR_332 = 8'b11111110;
    // Another option: White (R=7, G=7, B=3) -> 8'b11111111
    // Another option: Bright Green (R=0, G=7, B=0) -> 8'b00011100

    // --- Assign parameters to output ports ---
    assign char_x_pos_out    = P_CHAR_X_POS;
    assign char_y_pos_out    = P_CHAR_Y_POS;
    assign char_width_out    = P_CHAR_WIDTH;
    assign char_height_out   = P_CHAR_HEIGHT;
    assign char_color_out_332 = P_CHAR_COLOR_332;

endmodule