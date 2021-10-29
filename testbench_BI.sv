module testbench_BI();

	binarization_input(
		.pixel_in(pixel_in),
		.pixel_out(pixel_out)
	);
	
	logic [`KERNEL_SIZE-1:0][`BIT_WIDTH-1:0]		pixel_in;
	logic [`KERNEL_SIZE-1:0][`CHANNEL_CNT-1:0]		pixel_out;

	logic [`CHANNEL_CNT-1:0]						temp;
	
	initial begin
		pixel_in[0]	 	= -8'd128 ;
		#1
		if(pixel_out[0] != temp >> 128) $display("Fail!, output: %h, golden: %h",pixel_out[0],temp >> 128)
	end

endmodule
