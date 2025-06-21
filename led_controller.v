// led_controller.v
module led_controller (
    input wire clk_game,
    input wire reset,
    input wire [2:0] current_game_state,
    input wire [2:0] p1_health,
    input wire [2:0] p2_health,
    input wire game_over,
    
    output reg [9:0] led_output
);

    // Game state definitions
    localparam STATE_MENU      = 3'b000;
    localparam STATE_COUNTDOWN = 3'b001;
    localparam STATE_GAMEPLAY  = 3'b010;
    localparam STATE_GAME_OVER = 3'b011;
    
    // Blink counter for game over state
    reg [25:0] blink_counter;
    reg blink_state;
    
    // Generate blink signal (approximately 2Hz)
    always @(posedge clk_game or posedge reset) begin
        if (reset) begin
            blink_counter <= 26'd0;
            blink_state <= 1'b0;
        end else begin
            if (blink_counter >= 26'd30) begin  // Adjust for desired blink rate
                blink_counter <= 26'd0;
                blink_state <= ~blink_state;
            end else begin
                blink_counter <= blink_counter + 1;
            end
        end
    end
    
    // LED output logic
    always @(*) begin
        case (current_game_state)
            STATE_MENU: begin
                // All LEDs off during menu
                led_output = 10'b0000000000;
            end
            
            STATE_COUNTDOWN: begin
                // All LEDs off during countdown
                led_output = 10'b0000000000;
            end
            
            STATE_GAMEPLAY: begin
                // Display health: P1 on left (LEDs 9,8,7), P2 on right (LEDs 2,1,0)
                led_output = 10'b0000000000;
                
                // Player 1 health (leftmost 3 LEDs)
                case (p1_health)
                    3'd3: led_output[9:7] = 3'b111;  // All 3 LEDs on
                    3'd2: led_output[9:7] = 3'b110;  // 2 LEDs on
                    3'd1: led_output[9:7] = 3'b100;  // 1 LED on
                    3'd0: led_output[9:7] = 3'b000;  // All LEDs off
                    default: led_output[9:7] = 3'b000;
                endcase
                
                // Player 2 health (rightmost 3 LEDs)
                case (p2_health)
                    3'd3: led_output[2:0] = 3'b111;  // All 3 LEDs on
                    3'd2: led_output[2:0] = 3'b011;  // 2 LEDs on
                    3'd1: led_output[2:0] = 3'b001;  // 1 LED on
                    3'd0: led_output[2:0] = 3'b000;  // All LEDs off
                    default: led_output[2:0] = 3'b000;
                endcase
            end
            
            STATE_GAME_OVER: begin
                // All LEDs blink together
                if (blink_state) begin
                    led_output = 10'b1111111111;  // All LEDs on
                end else begin
                    led_output = 10'b0000000000;  // All LEDs off
                end
            end
            
            default: begin
                led_output = 10'b0000000000;
            end
        endcase
    end
    
endmodule