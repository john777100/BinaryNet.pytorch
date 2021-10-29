module binarization_input(
	input	[`KERNEL_SIZE-1:0][`BIT_WIDTH-1:0]		pixel_in,
	output	[`KERNEL_SIZE-1:0][`CHANNEL_CNT-1:0]	pixel_out
);
	logic	[`BIT_WIDTH:0] 							negative_cnt;	// range 1 - 256 mapping to 0 - 255
	input	[`KERNEL_SIZE-1:0][`BIT_WIDTH-1:0]		pixel_in,
	always_comb begin
		pixel_out		= 'b1;
		for(int i = 0; i<`KERNEL_SIZE; i++) begin
			negative_cnt	= ((`BIT_WIDTH)'d128 - {pixel_in[i][`BIT_WIDTH-1],pixel_in[i]}); // (256 - pixel * 2) >> 1 === 128 - pixel
			pixel_out[i] = pixel_out[i] >> negative_cnt;
		end
	end
endmodule
