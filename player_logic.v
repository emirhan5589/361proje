// player_logic.v (Updated with stun states)
module player_logic (
    input  wire        clk_game,           
    input  wire        reset,              

    input  wire        move_left_cmd_in,
    input  wire        move_right_cmd_in,
    input  wire        p1_attack_cmd_in,
    
    // Stun state inputs
    input  wire        in_hitstun,
    input  wire        in_blockstun,
    
    // Player 2 position for boundary checking
    input  wire [9:0]  p2_x_pos,
    input  wire [9:0]  p2_width,
    
    output reg  [9:0]  char_x_pos_out,     // horizontal pixel position
    output wire [9:0]  char_y_pos_out,     // vertical pixel position (static)
    output wire [9:0]  char_width_out,     // sprite width
    output wire [9:0]  char_height_out,    // sprite height
    output reg  [7:0]  char_color_out_332, // sprite color (3-3-2)
    output wire [1:0]  attack_phase_out,
    output wire        attack_active,
    output wire        moving_backward     // For blocking detection
);

    localparam P_SCREEN_W   = 10'd640;
    localparam P_SCREEN_H   = 10'd480;
    localparam P_CHAR_W     = 10'd32;
    localparam P_CHAR_H     = 10'd60;
    localparam P_FLOOR_OFF  = 10'd40;
    localparam P_INIT_X     = (P_SCREEN_W - P_CHAR_W) >> 1;
    localparam P_INIT_Y     = P_SCREEN_H - P_CHAR_H - P_FLOOR_OFF;

    localparam P_FWD_SPD    = 10'd3;
    localparam P_BAK_SPD    = 10'd2;

    // Attack timing parameters
    localparam N_STARTUP = 8'd5, N_ACTIVE = 8'd2,  N_RECOV = 8'd16;
    localparam D_STARTUP = 8'd4, D_ACTIVE = 8'd3,  D_RECOV = 8'd15;

    // Colors for different states
    localparam COL_IDLE    = 8'b11111110; // cream
    localparam COL_START   = 8'b00011111; // blue
    localparam COL_ACTIVE  = 8'b11100000; // red
    localparam COL_RECOV   = 8'b00111000; // green
    localparam COL_HITSTUN = 8'b11100100; // orange - hit stun color
    localparam COL_BLOCKSTUN = 8'b11011000; // yellow - block stun color

    // State definitions
    localparam S_IDLE     = 3'd0;
    localparam S_STARTUP  = 3'd1;
    localparam S_ACTIVE   = 3'd2;
    localparam S_RECOVERY = 3'd3;
    localparam S_HITSTUN  = 3'd4;
    localparam S_BLOCKSTUN = 3'd5;

    reg [2:0] state_reg;
    reg [7:0] timer_reg;
    reg       dir_latch;       // captures direction held in Idle
    reg       dir_attack;      // which timing to use
    reg       prev_attack;

    assign attack_phase_out = (state_reg == S_IDLE)     ? 2'b00 :
                              (state_reg == S_STARTUP)  ? 2'b01 :
                              (state_reg == S_ACTIVE)   ? 2'b10 :
                              (state_reg == S_RECOVERY) ? 2'b11 :
                              2'b00; 

    wire attack_trig = p1_attack_cmd_in && !prev_attack;

    // Static assigns
    assign char_width_out   = P_CHAR_W;
    assign char_height_out  = P_CHAR_H;
    assign char_y_pos_out   = P_INIT_Y;
    assign attack_active    = (state_reg == S_ACTIVE);
    assign moving_backward  = move_left_cmd_in; // For P1, moving left is backward

    // Calculate P2's left boundary
    wire [9:0] p2_left_boundary = p2_x_pos;

    // Latch previous attack level
    always @(posedge clk_game or posedge reset) begin
        if (reset) prev_attack <= 1'b0;
        else       prev_attack <= p1_attack_cmd_in;
    end

    // Capture direction held while Idle
    always @(posedge clk_game or posedge reset) begin
        if (reset) dir_latch <= 1'b0;
        else if (state_reg == S_IDLE)
            dir_latch <= move_left_cmd_in || move_right_cmd_in;
    end

    // Main FSM + movement
    always @(posedge clk_game or posedge reset) begin
        if (reset) begin
            char_x_pos_out     <= P_INIT_X;
            char_color_out_332 <= COL_IDLE;
            state_reg          <= S_IDLE;
            timer_reg          <= 8'd0;
            dir_attack         <= 1'b0;
        end else begin
            // Handle stun state transitions first
            if (in_hitstun && state_reg != S_HITSTUN) begin
                state_reg <= S_HITSTUN;
                char_color_out_332 <= COL_HITSTUN;
            end else if (in_blockstun && state_reg != S_BLOCKSTUN) begin
                state_reg <= S_BLOCKSTUN;
                char_color_out_332 <= COL_BLOCKSTUN;
            end else if (!in_hitstun && !in_blockstun && (state_reg == S_HITSTUN || state_reg == S_BLOCKSTUN)) begin
                // Exit stun states
                state_reg <= S_IDLE;
                char_color_out_332 <= COL_IDLE;
            end
            // Normal state logic (only if not stunned)
            else if (!in_hitstun && !in_blockstun) begin
                // Attack start in Idle on edge
                if (attack_trig && state_reg == S_IDLE) begin
                    dir_attack         <= dir_latch;
                    state_reg          <= S_STARTUP;
                    timer_reg          <= dir_latch ? D_STARTUP-1 : N_STARTUP-1;
                    char_color_out_332 <= COL_START;
                end else begin
                    case (state_reg)
                        // IDLE: movement only
                        S_IDLE: begin
                            char_color_out_332 <= COL_IDLE;
                            if (move_left_cmd_in) begin
                                // Moving left is backward for P1
                                if (char_x_pos_out >= P_BAK_SPD)
                                    char_x_pos_out <= char_x_pos_out - P_BAK_SPD;
                                else
                                    char_x_pos_out <= 10'd0;
                            end else if (move_right_cmd_in) begin
                                // Moving right is forward for P1 (toward P2)
                                // Don't allow P1 to cross over P2
                                if (char_x_pos_out + P_CHAR_W + P_FWD_SPD < p2_left_boundary)
                                    char_x_pos_out <= char_x_pos_out + P_FWD_SPD;
                                else if (char_x_pos_out + P_CHAR_W < p2_left_boundary)
                                    char_x_pos_out <= p2_left_boundary - P_CHAR_W;
                            end
                        end

                        // STARTUP Phase
                        S_STARTUP: begin
                            char_color_out_332 <= COL_START;
                            if (timer_reg == 0) begin
                                state_reg          <= S_ACTIVE;
                                timer_reg          <= dir_attack ? D_ACTIVE-1 : N_ACTIVE-1;
                                char_color_out_332 <= COL_ACTIVE;
                            end else
                                timer_reg <= timer_reg - 1;
                        end

                        // ACTIVE Phase
                        S_ACTIVE: begin
                            char_color_out_332 <= COL_ACTIVE;
                            if (timer_reg == 0) begin
                                state_reg          <= S_RECOVERY;
                                timer_reg          <= dir_attack ? D_RECOV-1 : N_RECOV-1;
                                char_color_out_332 <= COL_RECOV;
                            end else
                                timer_reg <= timer_reg - 1;
                        end

                        // RECOVERY Phase
                        S_RECOVERY: begin
                            char_color_out_332 <= COL_RECOV;
                            if (timer_reg == 0) begin
                                state_reg          <= S_IDLE;
                                char_color_out_332 <= COL_IDLE;
                            end else
                                timer_reg <= timer_reg - 1;
                        end

                        default: state_reg <= S_IDLE;
                    endcase
                end
            end
        end
    end
endmodule