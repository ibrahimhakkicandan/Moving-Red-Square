module vga_sync
  (input logic        clk,
   output logic       hsync,
   output logic       vsync,
   output logic [2:0] rgb,
	input logic [15:0] xPixel,
	input logic [15:0] yPixel
	);

   logic pixel_tick, video_on;
   logic [9:0] h_count;
   logic [9:0] v_count;
	logic x;
	logic y;
   localparam HD       = 640, //horizontal display area
              HF       = 48,  //horizontal front porch
              HB       = 16,  //horizontal back porch6
              HFB      = 96,  //horizontal flyback
              VD       = 480, //vertical display area
              VT       = 10,  //vertical top porch
              VB       = 33,  //vertical bottom porch
              VFB      = 2,   //vertical flyback
                  LINE_END = HF+HD+HB+HFB-1,
              PAGE_END = VT+VD+VB+VFB-1;

   always_ff @(posedge clk)
     pixel_tick <= ~pixel_tick; //25 MHZ signal is generated.

   always_ff @(posedge clk)
     if (pixel_tick) begin
        if (h_count == LINE_END)
          begin
              h_count <= 0;
                  if (v_count == PAGE_END)
                        v_count <= 0;
                  else
                     v_count <= v_count + 1;
                     end
        else
          h_count <= h_count + 1;
     end
	  
   // added by us -> creates square and background colors
   always_comb
        begin
            
             if((xPixel-5 <= h_count) && (h_count <= xPixel+6) && (yPixel-5 <= v_count) && (v_count <= yPixel+6))
                rgb = 3'b001;
				 else if((h_count < HD) && (v_count < VD))
					 rgb = 3'b010;
				 else
				    rgb = 3'b100;
					
        end
   // added by us
	 
   assign hsync = (h_count >= (HD+HB) && h_count <= (HFB+HD+HB-1));
   assign vsync = (v_count >= (VD+VB) && v_count <= (VD+VB+VFB-1));

   initial
     begin
		  
        h_count = 0;
        v_count = 0;
        pixel_tick = 0;
		 
     end

endmodule