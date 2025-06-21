// menu_controller.v (Updated with proper countdown logic)
module menu_controller (
    input wire pixel_clk,                   // 25MHz pixel clock
    input wire reset,
    input wire display_enable,              // VGA display enable
    input wire [9:0] pixel_x,
    input wire [9:0] pixel_y,
    
    // Menu state inputs
    input wire menu_active,                 // High when in menu state
    input wire countdown_active,            // High when in countdown state
    input wire [7:0] countdown_value,       // Current countdown value (3, 2, 1, 0 for START)
    input wire game_mode_1p,                // Current selected mode
    
    // Graphics output
    output reg [7:0] menu_color_out_332,    // Menu graphics color
    output reg menu_pixel_visible           // High when menu should be displayed
);

    // Screen dimensions
    localparam SCREEN_WIDTH = 640;
    localparam SCREEN_HEIGHT = 480;
    
    // Text positions
    localparam MENU_TITLE_X = 296;          // Center "MENU" (4 chars * 8 = 32, center = 320-16)
    localparam MENU_TITLE_Y = 150;
    
    localparam MODE_TEXT_X = 276;           // Center mode text (8 chars * 8 = 64, center = 320-32)
    localparam MODE_TEXT_Y = 220;
    
    localparam INSTRUCTION_X = 264;         // Center "PRESS START"
    localparam INSTRUCTION_Y = 280;
    
    localparam COUNTDOWN_X = 316;           // Center countdown (single character)
    localparam COUNTDOWN_Y = 200;
    
    localparam START_TEXT_X = 296;          // Center "START" (5 chars * 8 = 40, center = 320-20)
    localparam START_TEXT_Y = 200;
    
    // Colors
    localparam COLOR_MENU_BG = 8'b001_001_01;      // Dark blue background
    localparam COLOR_TITLE = 8'b111_111_11;        // White for "MENU"
    localparam COLOR_MODE_1P = 8'b000_111_00;      // Green for 1P mode 
    localparam COLOR_MODE_2P = 8'b111_100_00;      // Orange for 2P mode
    localparam COLOR_INSTRUCTION = 8'b110_110_10;   // Light gray for instruction
    localparam COLOR_COUNTDOWN = 8'b111_000_00;     // Red for countdown
    
    // Text renderer instances
    wire [7:0] title_color, mode_color, instruction_color, countdown_color;
    wire title_visible, mode_visible, instruction_visible, countdown_visible;
    
    // Title text ("MENU")
    text_renderer title_renderer (
        .pixel_clk(pixel_clk),
        .reset(reset),
        .display_enable(display_enable),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .text_enable(menu_active),
        .text_x_pos(MENU_TITLE_X),
        .text_y_pos(MENU_TITLE_Y),
        .text_color_332(COLOR_TITLE),
        .text_id(4'd0),  // TEXT_MENU
        .text_pixel_color_332(title_color),
        .text_pixel_visible(title_visible)
    );
    
    // Mode selection text
    text_renderer mode_renderer (
        .pixel_clk(pixel_clk),
        .reset(reset),
        .display_enable(display_enable),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .text_enable(menu_active),
        .text_x_pos(MODE_TEXT_X),
        .text_y_pos(MODE_TEXT_Y),
        .text_color_332(game_mode_1p ? COLOR_MODE_1P : COLOR_MODE_2P),
        .text_id(game_mode_1p ? 4'd1 : 4'd2),  // TEXT_1_PLAYER or TEXT_2_PLAYER
        .text_pixel_color_332(mode_color),
        .text_pixel_visible(mode_visible)
    );
    
    // Instruction text
    text_renderer instruction_renderer (
        .pixel_clk(pixel_clk),
        .reset(reset),
        .display_enable(display_enable),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .text_enable(menu_active),
        .text_x_pos(INSTRUCTION_X),
        .text_y_pos(INSTRUCTION_Y),
        .text_color_332(COLOR_INSTRUCTION),
        .text_id(4'd3),  // TEXT_PRESS_BUTTON
        .text_pixel_color_332(instruction_color),
        .text_pixel_visible(instruction_visible)
    );
    
    // Countdown text - updated logic
    reg [3:0] countdown_text_id;
    reg [9:0] countdown_x_pos;
    
    always @(*) begin
        case (countdown_value)
            8'd3: begin
                countdown_text_id = 4'd4;    // TEXT_COUNT_3
                countdown_x_pos = COUNTDOWN_X;
            end
            8'd2: begin
                countdown_text_id = 4'd5;    // TEXT_COUNT_2
                countdown_x_pos = COUNTDOWN_X;
            end
            8'd1: begin
                countdown_text_id = 4'd6;    // TEXT_COUNT_1
                countdown_x_pos = COUNTDOWN_X;
            end
            8'd0: begin
                countdown_text_id = 4'd7;    // TEXT_START
                countdown_x_pos = START_TEXT_X;  // Different position for longer text
            end
            default: begin
                countdown_text_id = 4'd4;
                countdown_x_pos = COUNTDOWN_X;
            end
        endcase
    end
    
    text_renderer countdown_renderer (
        .pixel_clk(pixel_clk),
        .reset(reset),
        .display_enable(display_enable),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .text_enable(countdown_active),
        .text_x_pos(countdown_x_pos),
        .text_y_pos(COUNTDOWN_Y),
        .text_color_332(COLOR_COUNTDOWN),
        .text_id(countdown_text_id),
        .text_pixel_color_332(countdown_color),
        .text_pixel_visible(countdown_visible)
    );
    
    // Output priority logic
    always @(*) begin
        menu_pixel_visible = 1'b0;
        menu_color_out_332 = COLOR_MENU_BG;
        
        if (display_enable && (menu_active || countdown_active)) begin
            menu_pixel_visible = 1'b1;
            
            // Priority: countdown > title > mode > instruction > background
            if (countdown_visible) begin
                menu_color_out_332 = countdown_color;
            end else if (title_visible) begin
                menu_color_out_332 = title_color;
            end else if (mode_visible) begin
                menu_color_out_332 = mode_color;
            end else if (instruction_visible) begin
                menu_color_out_332 = instruction_color;
            end else begin
                menu_color_out_332 = COLOR_MENU_BG;  // Background
            end
        end
    end
    
endmodule