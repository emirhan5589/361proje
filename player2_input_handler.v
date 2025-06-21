// player2_input_handler.v
module player2_input_handler (
    input  wire clk_50Mhz,          // fast clock for debouncing
    input  wire clk_60Hz_game,      // game logic clock
    input  wire reset,              // active-HIGH reset

    // Raw button inputs (active-LOW) - using GPIO pins for external keypad
    input  wire p2_key_left_raw_in,
    input  wire p2_key_right_raw_in,
    input  wire p2_key_attack_raw_in,

    // Processed command outputs (active-HIGH)
    output wire p2_move_left_cmd_out,
    output wire p2_move_right_cmd_out,
    output wire p2_attack_cmd_out
);

    // --- Debounced signals (active-LOW) ---
    wire p2_left_db_n;
    wire p2_right_db_n;

    // Instantiate debouncers for left, right
    button_debouncer db_p2_left (
        .clk_fast        (clk_50Mhz),
        .reset           (reset),
        .btn_raw_in      (p2_key_left_raw_in),
        .btn_debounced_out(p2_left_db_n)
    );
    
    button_debouncer db_p2_right (
        .clk_fast        (clk_50Mhz),
        .reset           (reset),
        .btn_raw_in      (p2_key_right_raw_in),
        .btn_debounced_out(p2_right_db_n)
    );

    // --- Synchronizers and outputs for left/right ---
    reg p2_left_sync1, p2_left_sync2;
    reg p2_right_sync1, p2_right_sync2;

    always @(posedge clk_60Hz_game or posedge reset) begin
        if (reset) begin
            p2_left_sync1     <= 1'b0;
            p2_left_sync2     <= 1'b0;
            p2_right_sync1    <= 1'b0;
            p2_right_sync2    <= 1'b0;
        end else begin
            // left/right inverted to active-HIGH, then two-flop synced
            p2_left_sync1     <= ~p2_left_db_n;
            p2_left_sync2     <= p2_left_sync1;
            p2_right_sync1    <= ~p2_right_db_n;
            p2_right_sync2    <= p2_right_sync1;
        end
    end

    // Movement commands driven from first sync stage (1-tick latency)
    assign p2_move_left_cmd_out   = p2_left_sync1;
    assign p2_move_right_cmd_out  = p2_right_sync1;

    // --- Attack path: bypass debounce, single-flop sync ---
    reg p2_attack_sync1;
    always @(posedge clk_60Hz_game or posedge reset) begin
        if (reset)
            p2_attack_sync1 <= 1'b0;
        else
            p2_attack_sync1 <= ~p2_key_attack_raw_in; // direct raw inversion
    end
    assign p2_attack_cmd_out = p2_attack_sync1;

endmodule