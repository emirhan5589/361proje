
module input_handler (
    input  wire clk_50Mhz,          // fast clock for debouncing
    input  wire clk_60Hz_game,      // game logic clock
    input  wire reset,              // active-HIGH reset

    // Raw button inputs (active-LOW)
    input  wire p1_key_left_raw_in,
    input  wire p1_key_right_raw_in,
    input  wire p1_key_attack_raw_in,
    input  wire p1_key_confirm_raw_in,

    // Processed command outputs (active-HIGH)
    output wire p1_move_left_cmd_out,
    output wire p1_move_right_cmd_out,
    output wire p1_attack_cmd_out,
    output reg  p1_confirm_cmd_out
);

    // --- Debounced signals (active-LOW) ---
    wire p1_left_db_n;
    wire p1_right_db_n;
    wire p1_confirm_db_n;

    // Instantiate debouncers for left, right, confirm
    button_debouncer db_left (
        .clk_fast        (clk_50Mhz),
        .reset           (reset),
        .btn_raw_in      (p1_key_left_raw_in),
        .btn_debounced_out(p1_left_db_n)
    );
    button_debouncer db_right (
        .clk_fast        (clk_50Mhz),
        .reset           (reset),
        .btn_raw_in      (p1_key_right_raw_in),
        .btn_debounced_out(p1_right_db_n)
    );
    button_debouncer db_confirm (
        .clk_fast        (clk_50Mhz),
        .reset           (reset),
        .btn_raw_in      (p1_key_confirm_raw_in),
        .btn_debounced_out(p1_confirm_db_n)
    );

    // --- Synchronizers and outputs for left/right/confirm ---
    reg p1_left_sync1, p1_left_sync2;
    reg p1_right_sync1, p1_right_sync2;
    reg p1_confirm_sync1, p1_confirm_sync2;

    always @(posedge clk_60Hz_game or posedge reset) begin
        if (reset) begin
            p1_left_sync1     <= 1'b0;
            p1_left_sync2     <= 1'b0;
            p1_right_sync1    <= 1'b0;
            p1_right_sync2    <= 1'b0;
            p1_confirm_sync1  <= 1'b0;
            p1_confirm_sync2  <= 1'b0;
            p1_confirm_cmd_out<= 1'b0;
        end else begin
            // left/right inverted to active-HIGH, then two-flop synced
            p1_left_sync1     <= ~p1_left_db_n;
            p1_left_sync2     <= p1_left_sync1;
            p1_right_sync1    <= ~p1_right_db_n;
            p1_right_sync2    <= p1_right_sync1;
            // confirm inverted and synced
            p1_confirm_sync1  <= ~p1_confirm_db_n;
            p1_confirm_sync2  <= p1_confirm_sync1;
            p1_confirm_cmd_out<= p1_confirm_sync2;
        end
    end

    // Movement commands driven from first sync stage (1-tick latency)
    assign p1_move_left_cmd_out   = p1_left_sync1;
    assign p1_move_right_cmd_out  = p1_right_sync1;

    // --- Attack path: bypass debounce, single-flop sync ---
    reg p1_attack_sync1;
    always @(posedge clk_60Hz_game or posedge reset) begin
        if (reset)
            p1_attack_sync1 <= 1'b0;
        else
            p1_attack_sync1 <= ~p1_key_attack_raw_in; // direct raw inversion
    end
    assign p1_attack_cmd_out = p1_attack_sync1;

endmodule