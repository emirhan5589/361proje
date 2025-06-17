
module background_generator (
    input wire pixel_clk,         
    input wire reset,             
    input wire display_enable,   
    input wire [9:0] pixel_x,    
    input wire [9:0] pixel_y,    
    output reg [7:0] color_out_332 
);

    // Define colors in RRRGGGBB format
    localparam COLOR_BLACK      = 8'b00000000;
    localparam BACKGROUND_COLOR = 8'b00100101; 
                                               

    always @(*) begin // Combinational logic
        if (display_enable) begin
            color_out_332 = BACKGROUND_COLOR;
        end else begin
            color_out_332 = COLOR_BLACK; // Output black when not in display area
        end
    end

endmodule