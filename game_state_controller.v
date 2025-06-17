// game_state_controller.v
module game_state_controller (
    input wire clk_game,                    // 60Hz game clock
    input wire reset,                       // Active high reset
    
    // Input from menu/game controls
    input wire p1_any_button_pressed,       // Any P1 button for menu confirmation
    input wire sw0_game_mode,               // SW[0]: 0=1P mode, 1=2P mode
    
    // Game over condition from gameplay
    input wire game_over_condition,         // From gameplay logic when health = 0
    input wire winner_p1,                   // Who won (if applicable)
    input wire winner_p2,
    
    // State outputs
    output reg [2:0] current_game_state,    // Current state for other modules
    output reg [7:0] countdown_value,       // Countdown display value
    output reg game_mode_1p,                // 0=2P mode, 1=1P mode
    output reg start_gameplay,              // Pulse to start gameplay
    output reg reset_gameplay,               // Reset signal for gameplay modules
	 output reg timer_enable,                // Enable game timer
output reg timer_reset                // Reset game timer

);

    // Game state definitions
    localparam STATE_MENU      = 3'b000;
    localparam STATE_COUNTDOWN = 3'b001;
    localparam STATE_GAMEPLAY  = 3'b010;
    localparam STATE_GAME_OVER = 3'b011;
    
    // Countdown parameters
    localparam COUNTDOWN_START = 8'd180;    // 3 seconds at 60Hz (3*60 = 180)
    localparam COUNTDOWN_2     = 8'd120;    // 2 seconds
    localparam COUNTDOWN_1     = 8'd60;     // 1 second
    localparam COUNTDOWN_START_TEXT = 8'd0; // "START" display
    
    // Internal registers
    reg [2:0] state_reg, state_next;
    reg [7:0] countdown_timer;
    reg prev_p1_button;
    
    // Edge detection for button press
    wire p1_button_edge = p1_any_button_pressed && !prev_p1_button;
    
    always @(posedge clk_game or posedge reset) begin
        if (reset) begin
            state_reg <= STATE_MENU;
            countdown_timer <= 8'd0;
            prev_p1_button <= 1'b0;
            game_mode_1p <= 1'b0;
        end else begin
            state_reg <= state_next;
            prev_p1_button <= p1_any_button_pressed;
            
            // Update game mode selection
            game_mode_1p <= sw0_game_mode;
            
            // Countdown timer logic
            if (state_reg == STATE_COUNTDOWN) begin
                if (countdown_timer > 0)
                    countdown_timer <= countdown_timer - 1;
            end else if (state_next == STATE_COUNTDOWN) begin
                countdown_timer <= COUNTDOWN_START;
            end
        end
    end
    
    // State transition logic
    always @(*) begin
        state_next = state_reg;
        
        case (state_reg)
            STATE_MENU: begin
                if (p1_button_edge) begin
                    state_next = STATE_COUNTDOWN;
                end
            end
            
            STATE_COUNTDOWN: begin
                if (countdown_timer == 0) begin
                    state_next = STATE_GAMEPLAY;
                end
            end
            
            STATE_GAMEPLAY: begin
                if (game_over_condition) begin
                    state_next = STATE_GAME_OVER;
                end
            end
            
            STATE_GAME_OVER: begin
                if (p1_button_edge) begin
                    state_next = STATE_MENU;
                end
            end
            
            default: state_next = STATE_MENU;
        endcase
    end
    
    // Add this to the output assignments section:
always @(*) begin
    current_game_state = state_reg;
    start_gameplay = (state_reg == STATE_COUNTDOWN && countdown_timer == 0);
    reset_gameplay = (state_reg == STATE_MENU || state_reg == STATE_COUNTDOWN);
    
    // Timer control
    timer_enable = (state_reg == STATE_GAMEPLAY);
    timer_reset = (state_reg == STATE_MENU) || (state_next == STATE_COUNTDOWN && state_reg != STATE_COUNTDOWN);
    
    // Countdown display logic (existing code)
    if (state_reg == STATE_COUNTDOWN) begin
        if (countdown_timer > COUNTDOWN_2)
            countdown_value = 8'd3;           // "3"
        else if (countdown_timer > COUNTDOWN_1)
            countdown_value = 8'd2;           // "2"
        else if (countdown_timer > COUNTDOWN_START_TEXT)
            countdown_value = 8'd1;           // "1"
        else
            countdown_value = 8'd0;           // "START"
    end else begin
        countdown_value = 8'd255;             // Invalid/no countdown
    end
end
    
endmodule
