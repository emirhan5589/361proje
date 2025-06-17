// game_timer.v
module game_timer (
    input wire clk_game,                    // 60Hz game clock
    input wire reset,                       // Active high reset
    input wire timer_enable,                // Enable counting (during gameplay)
    input wire timer_reset,                 // Reset timer to 0
    
    output reg [7:0] seconds_count          // Current seconds count (0-99)
);

    // Counter for 60Hz ticks (60 ticks = 1 second)
    reg [5:0] tick_counter;  // 0 to 59
    
    always @(posedge clk_game or posedge reset) begin
        if (reset) begin
            seconds_count <= 8'd0;
            tick_counter <= 6'd0;
        end else if (timer_reset) begin
            seconds_count <= 8'd0;
            tick_counter <= 6'd0;
        end else if (timer_enable) begin
            if (tick_counter == 6'd59) begin
                tick_counter <= 6'd0;
                if (seconds_count < 8'd99) begin
                    seconds_count <= seconds_count + 1;
                end
                // If we reach 99 seconds, stop counting (don't overflow)
            end else begin
                tick_counter <= tick_counter + 1;
            end
        end
    end
    
endmodule
