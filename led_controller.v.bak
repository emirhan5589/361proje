// led_controller.v
module led_controller (
    input wire clk_game,                    // 60Hz game clock
    input wire reset,                       // Active high reset
    
    // Game state inputs
    input wire [2:0] current_game_state,    // Current game state
    input wire [2:0] p1_health,             // Player 1 health (0-3)
    input wire [2:0] p2_health,             // Player 2 health (0-3)
    
    // LED outputs
    output reg [9:0] leds_out               // 10 LEDs on FPGA
);

    // Game state definitions
    localparam STATE_MENU      = 3'b000;
    localparam STATE_COUNTDOWN = 3'b001;
    localparam STATE_GAMEPLAY  = 3'b010;
    localparam STATE_GAME_OVER = 3'b011;
    
    // Blinking counter for game over state
    reg [5:0] blink_counter;  // 6 bits for ~1Hz blink at 60Hz (0-63)
    wire blink_state = blink_counter[5];  // MSB gives ~1Hz blink
    
    always @(posedge clk_game or posedge reset) begin
        if (reset) begin
            blink_counter <= 6'd0;
        end else begin
            blink_counter <= blink_counter + 1;
        end
    end
    
    always @(*) begin
        case (current_game_state)
            STATE_MENU: begin
                // All LEDs off in menu mode
                leds_out = 10'b0000000000;
            end
            
            STATE_COUNTDOWN: begin
                // All LEDs off during countdown
                leds_out = 10'b0000000000;
            end
            
            STATE_GAMEPLAY: begin
                // P1 health on leftmost 3 LEDs (9,8,7)
                // P2 health on rightmost 3 LEDs (2,1,0)
                // Middle LEDs (6,5,4,3) off
                leds_out[9] = (p1_health >= 3'd3) ? 1'b1 : 1'b0;
                leds_out[8] = (p1_health >= 3'd2) ? 1'b1 : 1'b0;
                leds_out[7] = (p1_health >= 3'd1) ? 1'b1 : 1'b0;
                leds_out[6] = 1'b0;
                leds_out[5] = 1'b0;
                leds_out[4] = 1'b0;
                leds_out[3] = 1'b0;
                leds_out[2] = (p2_health >= 3'd3) ? 1'b1 : 1'b0;
                leds_out[1] = (p2_health >= 3'd2) ? 1'b1 : 1'b0;
                leds_out[0] = (p2_health >= 3'd1) ? 1'b1 : 1'b0;
            end
            
            STATE_GAME_OVER: begin
                // All LEDs blink simultaneously
                if (blink_state) begin
                    leds_out = 10'b1111111111;
                end else begin
                    leds_out = 10'b0000000000;
                end
            end
            
            default: begin
                leds_out = 10'b0000000000;
            end
        endcase
    end
    
endmodule
