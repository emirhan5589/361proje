
module button_debouncer (
    input wire clk_fast,            // System clock (e.g., 50MHz) for the debouncer's timer
    input wire reset,               // Active-HIGH synchronous reset
    input wire btn_raw_in,          // Raw, bouncy button input (active-LOW)
    output reg btn_debounced_out    // Debounced button output (active-LOW)
);


    localparam CLK_FREQ_HZ = 50_000_000; // 50 MHz
    localparam DEBOUNCE_TIME_MS = 10;    // 10 ms

    
    localparam DEBOUNCE_CYCLES_THRESHOLD = (CLK_FREQ_HZ / 1000) * DEBOUNCE_TIME_MS;

    
    localparam COUNTER_WIDTH = $clog2(DEBOUNCE_CYCLES_THRESHOLD);

    // --- Internal Registers ---
    reg [COUNTER_WIDTH-1:0] debounce_counter_reg; // Timer for stability check
    reg                     btn_intermediate_reg; // Stores the current candidate for the stable state
    reg                     btn_sync1_reg;        // First stage synchronizer for btn_raw_in
    reg                     btn_sync2_reg;        // Second stage synchronizer for btn_raw_in (stable raw input)

    // --- Initial state for simulation ---
    initial begin
        btn_debounced_out = 1'b1; // Assume button is not pressed initially (HIGH for active-LOW)
        btn_intermediate_reg = 1'b1;
        debounce_counter_reg = 0;
        btn_sync1_reg = 1'b1;
        btn_sync2_reg = 1'b1;
    end

    
    always @(posedge clk_fast or posedge reset) begin
        if (reset) begin
            btn_sync1_reg <= 1'b1; // Default to not pressed
            btn_sync2_reg <= 1'b1; // Default to not pressed
        end else begin
            btn_sync1_reg <= btn_raw_in;
            btn_sync2_reg <= btn_sync1_reg;
        end
    end

    
    always @(posedge clk_fast or posedge reset) begin
        if (reset) begin
            btn_intermediate_reg <= 1'b1; // Assume button is not pressed
            debounce_counter_reg <= 0;
            btn_debounced_out    <= 1'b1; // Debounced output also not pressed
        end else begin
            
            if (btn_sync2_reg != btn_intermediate_reg) begin
                
                btn_intermediate_reg <= btn_sync2_reg;
                
                debounce_counter_reg <= 0;
            end
            
            else begin
                
                if (debounce_counter_reg < (DEBOUNCE_CYCLES_THRESHOLD - 1)) begin
                    debounce_counter_reg <= debounce_counter_reg + 1;
                end
                
                else begin
                    btn_debounced_out <= btn_intermediate_reg;
                    
                end
            end
        end
    end

endmodule