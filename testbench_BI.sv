module testbench_BI();

	binarization_input(
		.pixel_in(pixel_in),
		.pixel_out(pixel_out)
	);
	
	logic [`KERNEL_SIZE-1:0][`BIT_WIDTH-1:0]		pixel_in;
	logic [`KERNEL_SIZE-1:0][`CHANNEL_CNT-1:0]		pixel_out;

	for(int i  = 0; i < `KERNEL_SIZE; i++) begin
		pixel_in[i]	 	= $signed(
	end


endmodule
