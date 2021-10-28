module binarization_input(
	input	[`KERNEL_SIZE-1:0][`BIT_WIDTH-1:0]		pixel_in,
	output	[`KERNEL_SIZE-1:0][`CHANNEL_CNT-1:0]	pixel_out
);
	logic	[`BIT_WIDTH-1:0] 						positive_cnt;	// range 0 - 256
	input	[`KERNEL_SIZE-1:0][`BIT_WIDTH-1:0]		pixel_in,
	always_comb begin
		pixel_out		= 'b0;
		for(int i = 0; i<`KERNEL_SIZE; i++) begin
			positive_cnt	= (pixel_in[i]+(`BIT_WIDTH-1)'d128); // (pixel * 2 + 256) >> 1 === pixel + 128
			if(!positive_cnt) pixel_out[0:positive_cnt]	= 'b1;
		end
	end
endmodule
