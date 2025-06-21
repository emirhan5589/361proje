// hit_detection.v
module hit_detection (
    input wire clk_game,
    input wire reset,
    
    // Player 1 data
    input wire [9:0] p1_x_pos,
    input wire [9:0] p1_y_pos,
    input wire [9:0] p1_width,
    input wire [9:0] p1_height,
    input wire [1:0] p1_attack_phase,
    input wire p1_moving_backward,  // For blocking detection
    
    // Player 2 data
    input wire [9:0] p2_x_pos,
    input wire [9:0] p2_y_pos,
    input wire [9:0] p2_width,
    input wire [9:0] p2_height,
    input wire [1:0] p2_attack_phase,
    input wire p2_moving_backward,  // For blocking detection
    
    // Output hit events
    output reg p1_hit_p2,        // P1's attack hit P2
    output reg p2_hit_p1,        // P2's attack hit P1
    output reg p1_blocked_by_p2, // P1's attack was blocked by P2
    output reg p2_blocked_by_p1  // P2's attack was blocked by P1
);

    // Hitbox dimensions
    localparam HITBOX_WIDTH = 32;
    localparam HITBOX_HEIGHT = 8;
    
    // Attack phase definitions
    localparam PHASE_IDLE     = 2'b00;
    localparam PHASE_STARTUP  = 2'b01;
    localparam PHASE_ACTIVE   = 2'b10;
    localparam PHASE_RECOVERY = 2'b11;
    
    // Calculate P1's hitbox (extends to the right)
    wire [9:0] p1_hitbox_left   = p1_x_pos + p1_width;
    wire [9:0] p1_hitbox_right  = p1_hitbox_left + HITBOX_WIDTH - 1;
    wire [9:0] p1_hitbox_top    = p1_y_pos + (p1_height >> 1) - (HITBOX_HEIGHT >> 1);
    wire [9:0] p1_hitbox_bottom = p1_hitbox_top + HITBOX_HEIGHT - 1;
    
    // Calculate P2's hitbox (extends to the left)
    wire [9:0] p2_hitbox_right  = p2_x_pos - 1;
    wire [9:0] p2_hitbox_left   = p2_hitbox_right - HITBOX_WIDTH + 1;
    wire [9:0] p2_hitbox_top    = p2_y_pos + (p2_height >> 1) - (HITBOX_HEIGHT >> 1);
    wire [9:0] p2_hitbox_bottom = p2_hitbox_top + HITBOX_HEIGHT - 1;
    
    // Calculate hurtboxes (character bodies)
    wire [9:0] p1_hurtbox_left   = p1_x_pos;
    wire [9:0] p1_hurtbox_right  = p1_x_pos + p1_width - 1;
    wire [9:0] p1_hurtbox_top    = p1_y_pos;
    wire [9:0] p1_hurtbox_bottom = p1_y_pos + p1_height - 1;
    
    wire [9:0] p2_hurtbox_left   = p2_x_pos;
    wire [9:0] p2_hurtbox_right  = p2_x_pos + p2_width - 1;
    wire [9:0] p2_hurtbox_top    = p2_y_pos;
    wire [9:0] p2_hurtbox_bottom = p2_y_pos + p2_height - 1;
    
    // Collision detection functions
    function overlap_check;
        input [9:0] box1_left, box1_right, box1_top, box1_bottom;
        input [9:0] box2_left, box2_right, box2_top, box2_bottom;
        begin
            overlap_check = (box1_left <= box2_right) && 
                           (box1_right >= box2_left) && 
                           (box1_top <= box2_bottom) && 
                           (box1_bottom >= box2_top);
        end
    endfunction
    
    // Check if P1's hitbox overlaps with P2's hurtbox
    wire p1_hitbox_hits_p2 = overlap_check(
        p1_hitbox_left, p1_hitbox_right, p1_hitbox_top, p1_hitbox_bottom,
        p2_hurtbox_left, p2_hurtbox_right, p2_hurtbox_top, p2_hurtbox_bottom
    );
    
    // Check if P2's hitbox overlaps with P1's hurtbox
    wire p2_hitbox_hits_p1 = overlap_check(
        p2_hitbox_left, p2_hitbox_right, p2_hitbox_top, p2_hitbox_bottom,
        p1_hurtbox_left, p1_hurtbox_right, p1_hurtbox_top, p1_hurtbox_bottom
    );
    
    // Previous frame attack phases for edge detection
    reg [1:0] p1_attack_phase_prev;
    reg [1:0] p2_attack_phase_prev;
    
    always @(posedge clk_game or posedge reset) begin
        if (reset) begin
            p1_attack_phase_prev <= PHASE_IDLE;
            p2_attack_phase_prev <= PHASE_IDLE;
            p1_hit_p2 <= 1'b0;
            p2_hit_p1 <= 1'b0;
            p1_blocked_by_p2 <= 1'b0;
            p2_blocked_by_p1 <= 1'b0;
        end else begin
            // Update previous phases
            p1_attack_phase_prev <= p1_attack_phase;
            p2_attack_phase_prev <= p2_attack_phase;
            
            // Default to no hits/blocks
            p1_hit_p2 <= 1'b0;
            p2_hit_p1 <= 1'b0;
            p1_blocked_by_p2 <= 1'b0;
            p2_blocked_by_p1 <= 1'b0;
            
            // Check for P1 hitting P2 (on transition to active phase)
            if ((p1_attack_phase == PHASE_ACTIVE) && 
                (p1_attack_phase_prev != PHASE_ACTIVE) && 
                p1_hitbox_hits_p2) begin
                
                if (p2_moving_backward) begin
                    // P2 is blocking
                    p1_blocked_by_p2 <= 1'b1;
                end else begin
                    // P2 takes a hit
                    p1_hit_p2 <= 1'b1;
                end
            end
            
            // Check for P2 hitting P1 (on transition to active phase)
            if ((p2_attack_phase == PHASE_ACTIVE) && 
                (p2_attack_phase_prev != PHASE_ACTIVE) && 
                p2_hitbox_hits_p1) begin
                
                if (p1_moving_backward) begin
                    // P1 is blocking
                    p2_blocked_by_p1 <= 1'b1;
                end else begin
                    // P1 takes a hit
                    p2_hit_p1 <= 1'b1;
                end
            end
        end
    end
    
endmodule