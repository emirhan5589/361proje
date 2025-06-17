// input_handler.v
// Debounces and synchronizes inputs for two players.

module input_handler (
    input  wire clk_fast,
    input  wire clk_game,
    input  wire reset,

    // Player 1 buttons from onboard keys (active low)
    input  wire key_p1_left_n,
    input  wire key_p1_right_n,
    input  wire key_p1_attack_n,

    // Player 2 buttons from external GPIO (active high)
    input  wire gpio_p2_left,
    input  wire gpio_p2_right,
    input  wire gpio_p2_attack,

    // Debounced, synchronized outputs (active high)
    output wire p1_left,
    output wire p1_right,
    output wire p1_attack,
    output wire p2_left,
    output wire p2_right,
    output wire p2_attack
);

    // Debounce player 1 (inputs are active low)
    wire p1_left_db_n;
    wire p1_right_db_n;
    wire p1_attack_db_n;

    button_debouncer db_p1_left(
        .clk_fast(clk_fast),
        .reset(reset),
        .btn_raw_in(key_p1_left_n),
        .btn_debounced_out(p1_left_db_n)
    );

    button_debouncer db_p1_right(
        .clk_fast(clk_fast),
        .reset(reset),
        .btn_raw_in(key_p1_right_n),
        .btn_debounced_out(p1_right_db_n)
    );

    button_debouncer db_p1_attack(
        .clk_fast(clk_fast),
        .reset(reset),
        .btn_raw_in(key_p1_attack_n),
        .btn_debounced_out(p1_attack_db_n)
    );

    // Debounce player 2 (inputs are active high -> invert for debouncer)
    wire p2_left_db_n;
    wire p2_right_db_n;
    wire p2_attack_db_n;

    button_debouncer db_p2_left(
        .clk_fast(clk_fast),
        .reset(reset),
        .btn_raw_in(~gpio_p2_left),
        .btn_debounced_out(p2_left_db_n)
    );

    button_debouncer db_p2_right(
        .clk_fast(clk_fast),
        .reset(reset),
        .btn_raw_in(~gpio_p2_right),
        .btn_debounced_out(p2_right_db_n)
    );

    button_debouncer db_p2_attack(
        .clk_fast(clk_fast),
        .reset(reset),
        .btn_raw_in(~gpio_p2_attack),
        .btn_debounced_out(p2_attack_db_n)
    );

    // Synchronize debounced levels to clk and convert to active high
    reg p1_left_sync1,  p1_left_sync2;
    reg p1_right_sync1, p1_right_sync2;
    reg p1_attack_sync1, p1_attack_sync2;
    reg p2_left_sync1,  p2_left_sync2;
    reg p2_right_sync1, p2_right_sync2;
    reg p2_attack_sync1, p2_attack_sync2;

    always @(posedge clk_game or posedge reset) begin
        if (reset) begin
            p1_left_sync1  <= 1'b0;
            p1_left_sync2  <= 1'b0;
            p1_right_sync1 <= 1'b0;
            p1_right_sync2 <= 1'b0;
            p1_attack_sync1<= 1'b0;
            p1_attack_sync2<= 1'b0;
            p2_left_sync1  <= 1'b0;
            p2_left_sync2  <= 1'b0;
            p2_right_sync1 <= 1'b0;
            p2_right_sync2 <= 1'b0;
            p2_attack_sync1<= 1'b0;
            p2_attack_sync2<= 1'b0;
        end else begin
            // Player 1
            p1_left_sync1  <= ~p1_left_db_n;
            p1_left_sync2  <= p1_left_sync1;
            p1_right_sync1 <= ~p1_right_db_n;
            p1_right_sync2 <= p1_right_sync1;
            p1_attack_sync1<= ~p1_attack_db_n;
            p1_attack_sync2<= p1_attack_sync1;

            // Player 2
            p2_left_sync1  <= ~p2_left_db_n;
            p2_left_sync2  <= p2_left_sync1;
            p2_right_sync1 <= ~p2_right_db_n;
            p2_right_sync2 <= p2_right_sync1;
            p2_attack_sync1<= ~p2_attack_db_n;
            p2_attack_sync2<= p2_attack_sync1;
        end
    end

    // Final outputs
    assign p1_left   = p1_left_sync2;
    assign p1_right  = p1_right_sync2;
    assign p1_attack = p1_attack_sync2;
    assign p2_left   = p2_left_sync2;
    assign p2_right  = p2_right_sync2;
    assign p2_attack = p2_attack_sync2;

endmodule

