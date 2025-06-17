module game_clocks (
    input wire clk_50Mhz_in,
    input wire reset_in,
    output wire clk_25Mhz_out,
    output wire clk_60Hz_out,
	  input  wire sw1_in,         // SW[1]: 0 = auto-60 Hz, 1 = manual step
    input  wire key_step_in,
	 input wire frame_sync_in
);
	wire clk_60Hz_divided_internal; 
    
    our_clk_divider #(
        .D(2)
    ) vga_clk_divider_inst (
        .clk(clk_50Mhz_in),
        .rst(reset_in),
        .clk_divided(clk_25Mhz_out)
    );

    
    our_clk_divider #(
        .D(833334) 
    ) game_logic_clk_divider_inst (
        .clk(clk_50Mhz_in),
        .rst(reset_in),
        .clk_divided(clk_60Hz_divided_internal)
    );

	  assign clk_60Hz_out = sw1_in ? key_step_in : frame_sync_in ;

endmodule