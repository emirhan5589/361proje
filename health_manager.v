// health_manager.v
module health_manager (
    input wire clk_game,
    input wire reset,
    input wire game_active,  // Only process hits during gameplay
    
    // Hit detection inputs
    input wire p1_hit_p2,
    input wire p2_hit_p1,
    input wire p1_blocked_by_p2,
    input wire p2_blocked_by_p1,
    
    // Health and block counters
    output reg [2:0] p1_health,      // 3-bit health (0-3)
    output reg [2:0] p2_health,      // 3-bit health (0-3)
    output reg [2:0] p1_block_count, // 3-bit block count (0-3)
    output reg [2:0] p2_block_count, // 3-bit block count (0-3)
    
    // Game over conditions
    output wire game_over,
    output wire p1_wins,
    output wire p2_wins,
    output wire draw_game,
    
    // Stun state outputs
    output reg p1_in_hitstun,
    output reg p2_in_hitstun,
    output reg p1_in_blockstun,
    output reg p2_in_blockstun,
    
    // Stun timers (for external use)
    output reg [4:0] p1_stun_timer,
    output reg [4:0] p2_stun_timer
);

    // Stun durations based on project specification
    localparam HITSTUN_DURATION  = 5'd16;  // 16 frames + 1 frame advantage = 17 total
    localparam BLOCKSTUN_DURATION = 5'd14; // 14 frames + 3 frame advantage = 17 total
    
    // Initialize health and block counters
    always @(posedge clk_game or posedge reset) begin
        if (reset) begin
            p1_health <= 3'd3;
            p2_health <= 3'd3;
            p1_block_count <= 3'd3;
            p2_block_count <= 3'd3;
            p1_in_hitstun <= 1'b0;
            p2_in_hitstun <= 1'b0;
            p1_in_blockstun <= 1'b0;
            p2_in_blockstun <= 1'b0;
            p1_stun_timer <= 5'd0;
            p2_stun_timer <= 5'd0;
        end else if (game_active) begin
            
            // Handle P1 getting hit
            if (p2_hit_p1) begin
                if (p1_health > 0) begin
                    p1_health <= p1_health - 1;
                end
                p1_in_hitstun <= 1'b1;
                p1_stun_timer <= HITSTUN_DURATION;
                // Cancel any existing blockstun
                p1_in_blockstun <= 1'b0;
            end
            
            // Handle P2 getting hit
            if (p1_hit_p2) begin
                if (p2_health > 0) begin
                    p2_health <= p2_health - 1;
                end
                p2_in_hitstun <= 1'b1;
                p2_stun_timer <= HITSTUN_DURATION;
                // Cancel any existing blockstun
                p2_in_blockstun <= 1'b0;
            end
            
            // Handle P1 blocking
            if (p2_blocked_by_p1) begin
                if (p1_block_count > 0) begin
                    p1_block_count <= p1_block_count - 1;
                end
                p1_in_blockstun <= 1'b1;
                p1_stun_timer <= BLOCKSTUN_DURATION;
                // Cancel any existing hitstun
                p1_in_hitstun <= 1'b0;
            end
            
            // Handle P2 blocking
            if (p1_blocked_by_p2) begin
                if (p2_block_count > 0) begin
                    p2_block_count <= p2_block_count - 1;
                end
                p2_in_blockstun <= 1'b1;
                p2_stun_timer <= BLOCKSTUN_DURATION;
                // Cancel any existing hitstun
                p2_in_hitstun <= 1'b0;
            end
            
            // Handle stun timers for P1
            if (p1_in_hitstun || p1_in_blockstun) begin
                if (p1_stun_timer > 0) begin
                    p1_stun_timer <= p1_stun_timer - 1;
                end else begin
                    p1_in_hitstun <= 1'b0;
                    p1_in_blockstun <= 1'b0;
                end
            end
            
            // Handle stun timers for P2
            if (p2_in_hitstun || p2_in_blockstun) begin
                if (p2_stun_timer > 0) begin
                    p2_stun_timer <= p2_stun_timer - 1;
                end else begin
                    p2_in_hitstun <= 1'b0;
                    p2_in_blockstun <= 1'b0;
                end
            end
        end
    end
    
    // Game over logic
    assign game_over = (p1_health == 0) || (p2_health == 0);
    assign p1_wins = (p2_health == 0) && (p1_health != 0);
    assign p2_wins = (p1_health == 0) && (p2_health != 0);
    assign draw_game = (p1_health == 0) && (p2_health == 0);
    
endmodule