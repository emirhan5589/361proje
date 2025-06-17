module test_pattern_generator (
    input wire pixel_clk,           
    input wire reset,               
    input wire display_enable,      
    input wire [9:0] pixel_x,       
    input wire [9:0] pixel_y,       
    
    output wire [7:0] color_out_332  // Changed to wire
);

    localparam [7:0] COLOR_RED   = 8'b11100000;
    localparam [7:0] COLOR_GREEN = 8'b00011100;
    localparam [7:0] COLOR_BLUE  = 8'b00000011;
    localparam [7:0] COLOR_BLACK = 8'b00000000;

    localparam [9:0] RED_GREEN_BOUNDARY = 10'd213;
    localparam [9:0] GREEN_BLUE_BOUNDARY = 10'd426;

    // Combinational logic - no clock edge
    assign color_out_332 = (!display_enable) ? COLOR_BLACK :
                          (pixel_x < RED_GREEN_BOUNDARY) ? COLOR_RED :
                          (pixel_x < GREEN_BLUE_BOUNDARY) ? COLOR_GREEN :
                          COLOR_BLUE;

endmodule
