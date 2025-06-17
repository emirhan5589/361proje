module vga_driver (
    input wire pixel_clk,         // ~25 MHz clock
    input wire reset,             // Active high reset
    input wire [7:0] color_in_332, // Pixel color data (RRRGGGBB)

    output wire [9:0] pixel_x,    // Current x-coordinate (0-639 in active)
    output wire [9:0] pixel_y,    // Current y-coordinate (0-479 in active)
    output wire display_enable,   // HIGH when in 640x480 active display area

    output wire vga_hsync,        // HSYNC (active LOW)
    output wire vga_vsync,        // VSYNC (active LOW)
    output wire [2:0] vga_r_out,      // RED (RRR)
    output wire [2:0] vga_g_out,      // GREEN (GGG)
    output wire [1:0] vga_b_out,       // BLUE (BB)
	 output wire frame_sync,       // Pulse at start of each new frame
    output wire vblank            // High during vertical blanking
);

    
    localparam [9:0] H_ACTIVE_CYCLES  = 10'd640;
    localparam [9:0] H_FRONT_CYCLES   = 10'd25;
    localparam [9:0] H_PULSE_CYCLES   = 10'd96;
    localparam [9:0] H_BACK_CYCLES    = 10'd39;

    localparam [9:0] H_ACTIVE_PARAM  = H_ACTIVE_CYCLES -1; 
    localparam [9:0] H_FRONT_PARAM   = H_FRONT_CYCLES -1;  
    localparam [9:0] H_PULSE_PARAM   = H_PULSE_CYCLES -1;  
    localparam [9:0] H_BACK_PARAM    = H_BACK_CYCLES -1;   

    // Vertical parameters (measured in lines)
    localparam [9:0] V_ACTIVE_LINES   = 10'd480;
    localparam [9:0] V_FRONT_LINES    = 10'd10;
    localparam [9:0] V_PULSE_LINES    = 10'd2;
    localparam [9:0] V_BACK_LINES     = 10'd33;

    localparam [9:0] V_ACTIVE_PARAM   = V_ACTIVE_LINES -1; // 479
    localparam [9:0] V_FRONT_PARAM    = V_FRONT_LINES -1;  // 9
    localparam [9:0] V_PULSE_PARAM    = V_PULSE_LINES -1;  // 1
    localparam [9:0] V_BACK_PARAM     = V_BACK_LINES -1;   // 32

    // States 
    localparam [1:0] S_H_ACTIVE    = 2'd0; 
    localparam [1:0] S_H_FRONT     = 2'd1;
    localparam [1:0] S_H_PULSE     = 2'd2;
    localparam [1:0] S_H_BACK      = 2'd3;

    localparam [1:0] S_V_ACTIVE    = 2'd0;
    localparam [1:0] S_V_FRONT     = 2'd1;
    localparam [1:0] S_V_PULSE     = 2'd2;
    localparam [1:0] S_V_BACK      = 2'd3;

    reg hsync_reg_internal; // Internal hsync
    reg vsync_reg_internal; // Internal vsync
    reg [2:0] r_reg;
    reg [2:0] g_reg;
    reg [1:0] b_reg;
    reg line_done_tick;

    reg [9:0] h_count;
    reg [9:0] v_count;
    reg [1:0] h_state_reg;
    reg [1:0] v_state_reg;

    
    initial begin
        hsync_reg_internal = 1'b1; vsync_reg_internal = 1'b1; // VGA sync is active LOW, so inactive is HIGH
        r_reg = 3'b0; g_reg = 3'b0; b_reg = 2'b0;
        line_done_tick = 1'b0;
        h_count = 0; v_count = 0;
        h_state_reg = S_H_ACTIVE; v_state_reg = S_V_ACTIVE;
    end

    assign display_enable = (h_state_reg == S_H_ACTIVE) && (v_state_reg == S_V_ACTIVE);
    assign pixel_x = (h_state_reg == S_H_ACTIVE) ? h_count : 10'd0; // h_count is 0..639 in active
    assign pixel_y = (v_state_reg == S_V_ACTIVE) ? v_count : 10'd0; // v_count is 0..479 in active

    always @(posedge pixel_clk or posedge reset) begin
        if (reset) begin
            h_count <= 0; v_count <= 0;
            h_state_reg <= S_H_ACTIVE; v_state_reg <= S_V_ACTIVE;
            hsync_reg_internal <= 1'b1; vsync_reg_internal <= 1'b1;
            line_done_tick <= 1'b0;
            r_reg <= 0; g_reg <= 0; b_reg <= 0;
        end else begin
            
            line_done_tick <= 1'b0;

            // Horizontal State Machine & Counter
            case (h_state_reg)
                S_H_ACTIVE: begin
                    hsync_reg_internal <= 1'b1; // HSYNC High during active/front/back
                    if (h_count == H_ACTIVE_PARAM) begin
                        h_count <= 0;
                        h_state_reg <= S_H_FRONT;
                    end else begin
                        h_count <= h_count + 1;
                    end
                end
                S_H_FRONT: begin
                    hsync_reg_internal <= 1'b1;
                    if (h_count == H_FRONT_PARAM) begin
                        h_count <= 0;
                        h_state_reg <= S_H_PULSE;
                    end else begin
                        h_count <= h_count + 1;
                    end
                end
                S_H_PULSE: begin
                    hsync_reg_internal <= 1'b0; // HSYNC LOW during pulse
                    if (h_count == H_PULSE_PARAM) begin
                        h_count <= 0;
                        h_state_reg <= S_H_BACK;
                    end else begin
                        h_count <= h_count + 1;
                    end
                end
                S_H_BACK: begin
                    hsync_reg_internal <= 1'b1;
                    if (h_count == H_BACK_PARAM) begin
                        h_count <= 0;
                        h_state_reg <= S_H_ACTIVE;
                        line_done_tick <= 1'b1; // Signal end of line
                    end else begin
                        h_count <= h_count + 1;
                    end
                end
                default: begin 
                    h_state_reg <= S_H_ACTIVE;
                    h_count <= 0;
                end
            endcase

            // Vertical State Machine & Counter (updates only on line_done_tick)
            if (line_done_tick) begin
                case (v_state_reg)
                    S_V_ACTIVE: begin
                        vsync_reg_internal <= 1'b1; // VSYNC High during active/front/back
                        if (v_count == V_ACTIVE_PARAM) begin
                            v_count <= 0;
                            v_state_reg <= S_V_FRONT;
                        end else begin
                            v_count <= v_count + 1;
                        end
                    end
                    S_V_FRONT: begin
                        vsync_reg_internal <= 1'b1;
                        if (v_count == V_FRONT_PARAM) begin
                            v_count <= 0;
                            v_state_reg <= S_V_PULSE;
                        end else begin
                            v_count <= v_count + 1;
                        end
                    end
                    S_V_PULSE: begin
                        vsync_reg_internal <= 1'b0; // VSYNC LOW during pulse
                        if (v_count == V_PULSE_PARAM) begin
                            v_count <= 0;
                            v_state_reg <= S_V_BACK;
                        end else begin
                            v_count <= v_count + 1;
                        end
                    end
                    S_V_BACK: begin
                        vsync_reg_internal <= 1'b1;
                        if (v_count == V_BACK_PARAM) begin
                            v_count <= 0;
                            v_state_reg <= S_V_ACTIVE;
                        end else begin
                            v_count <= v_count + 1;
                        end
                    end
                    default: begin // Should not happen
                        v_state_reg <= S_V_ACTIVE;
                        v_count <= 0;
                    end
                endcase
            end

            // Color Output Logic (based on *current* display_enable)
            if ((h_state_reg == S_H_ACTIVE) && (v_state_reg == S_V_ACTIVE)) begin
                r_reg <= color_in_332[7:5];
                g_reg <= color_in_332[4:2];
                b_reg <= color_in_332[1:0];
            end else begin
                r_reg <= 3'b0; // Black during blanking
                g_reg <= 3'b0;
                b_reg <= 2'b0;
            end
        end
    end

    assign vga_hsync = hsync_reg_internal;
    assign vga_vsync = vsync_reg_internal;
    assign vga_r_out = r_reg;
    assign vga_g_out = g_reg;
    assign vga_b_out = b_reg;

	 
	 
	 
	 reg frame_sync_reg;
    reg prev_vsync;
    
    // Frame sync pulse generation - triggers at the start of each new frame
    always @(posedge pixel_clk or posedge reset) begin
        if (reset) begin
            frame_sync_reg <= 1'b0;
            prev_vsync <= 1'b1;
        end else begin
            prev_vsync <= vsync_reg_internal;
            // Generate a single pulse when vsync goes from LOW to HIGH (end of vsync pulse)
            frame_sync_reg <= (~prev_vsync) & vsync_reg_internal;
        end
    end
    
    assign frame_sync = frame_sync_reg;
    assign vblank = (v_state_reg != S_V_ACTIVE); // High during vertical blanking periods

	 
	 
	 
	 
	 
endmodule