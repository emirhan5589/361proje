module our_clk_divider #(
    parameter D = 10000)(
	 
input clk,
input rst,
output reg clk_divided
 
	 

	 
);

reg [31:0] counter;

always @(posedge clk) begin
        if (rst) begin
            counter <= 0;
            clk_divided <= 1'b0;
        end else begin
            
            if (counter == (D/2 - 1)) begin
                counter <= 0;
                clk_divided <= ~clk_divided;
            end else begin
                counter <= counter + 1;
            end
        end
    end



endmodule