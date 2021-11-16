module binarization_input(
	pixel_in,
	pixel_out
);
	parameter PARAM_IN_CNT		= 784;
	parameter PARAM_IN_BIT		= 2;
	parameter PARAM_CH_CNT		= 2 ** PARAM_IN_BIT; 

	input			[`PARAM_IN_CNT-1:0][`PARAM_IN_BIT-1:0]	pixel_in;
	output logic	[`PARAM_IN_CNT-1:0][`PARAM_CH_CNT-1:0]	pixel_out;


	logic	[`PARAM_IN_BIT:0] 							negative_cnt;	// range 1 - 256 mapping to 0 - 255
	always_comb begin
		pixel_out		= 'b0 - 1;
		for(int i = 0; i<`PARAM_IN_CNT; i++) begin
			negative_cnt	= (`PARAM_CH_CNT/2 - {pixel_in[i][`PARAM_IN_BIT-1],pixel_in[i]}); // (256 - pixel * 2) >> 1 === 128 - pixel
			pixel_out[i] = pixel_out[i] >> negative_cnt;
		end
	end
endmodule
