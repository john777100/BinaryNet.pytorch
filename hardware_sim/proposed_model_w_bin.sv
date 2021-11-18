module proposed_model_w_bin (
	input	[`INPUT_DIM-1:0][`BIT_CNT-1:0]		value_in,
	input	[`OUTPUT_DIM-1:0][`INPUT_DIM-1:0]	weight,
	output	[`OUTPUT_DIM-1:0][`BIT_CNT-1:0]		value_out
);

	logic	[`INPUT_DIM-1:0][`BIT_CNT-1:0]						BI_in;
	logic	[`INPUT_DIM-1:0][`CHANNEL_CNT-1:0]					BI_out;
	logic	[`OUTPUT_DIM-1:0][`INPUT_DIM-1:0][`CHANNEL_CNT-1:0]	ACC_in;
	logic	[`OUTPUT_DIM-1:0][`BIT_CNT-1:0]						ACC_out;
	assign 	BI_in		= value_in;	
	assign 	value_out	= ACC_out; 

	binarization_input #(.PARAM_IN_CNT(`INPUT_DIM), .PARAM_IN_BIT(`BIT_CNT), .PARAM_CH_CNT(`CHANNEL_CNT)) b0(
		.pixel_in(BI_in),
		.pixel_out(BI_out)
	);

	

	accumulation #(.PARAM_IN_CNT(`INPUT_DIM), .PARAM_IN_BIT(`BIT_CNT), .PARAM_CH_CNT(`CHANNEL_CNT)) a0 [`OUTPUT_DIM-1:0] (
		.xnor_i(ACC_in),
		.result_o(ACC_out)
	);
	
	always_comb begin
		for(int i = 0; i < `OUTPUT_DIM; i++) begin
			//weight[i] 	//input_dim
			//BI_out		//input_dim * channel cnt
			//ACC_in[i]		//input_dim * channel_cnt
			for(int j = 0; j < `INPUT_DIM; j++) begin
				ACC_in[i][j]	= {`CHANNEL_CNT{weight[i][j]}} ^~ BI_out[j];
			end
		end
	end


endmodule
