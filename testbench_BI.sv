module testbench_BI();

	
	logic [`KERNEL_SIZE-1:0][`BIT_WIDTH-1:0]		pixel_in;
	logic [`KERNEL_SIZE-1:0][`CHANNEL_CNT-1:0]		pixel_out;

	binarization_input b0(
		.pixel_in(pixel_in),
		.pixel_out(pixel_out)
	);
	logic [`CHANNEL_CNT-1:0]						temp;
	
	initial begin
		temp			= 'b0 - 1;
		pixel_in[0]	 	= 8'd127 ;
		
		#1
		$display("output: %h, golden: %h",pixel_out[0],temp >> 128);
		
		if(pixel_out[0] != temp >> 1) $display("Fail!, output: %h, golden: %h",pixel_out[0],temp >> 1);
		else $display("PASS!!!!!!");
	end

endmodule
