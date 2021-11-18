module original_model (
	input	[`INPUT_DIM-1][`BIT_WIDTH-1:0]		value_in,
	input	[`OUTPUT_DIM-1:0][`INPUT_DIM-1:0]	weight,
	output	[`OUTPUT_DIM-1][`BIT_WIDTH-1:0]		value_out

);

	logic	[`INPUT_DIM-1:0][`CHANNEL_CNT-1:0]					BI_out;
	logic	[`OUTPUT_DIM-1:0][`INPUT_DIM-1:0][`CHANNEL_CNT-1:0]	ACC_in;
	logic	[`OUTPUT_DIM-1:0][`BIT_WIDTH-1:0]					ACC_out;
	assign 	BI_out		= value_in;	
	assign 	value_out	= ACC_out; 


	accumulation a0 #(.PARAM_IN_CNT(`INPUT_DIM), .PARAM_IN_BIT(`BIT_WIDTH), .PARAM_CH_CNT(`CHANNEL_CNT))[`OUTPUT_DIM-1:0] (
		.xnor_i(ACC_in),
		.result_o(ACC_out)
	);
	
	always_comb begin
		for(int i = 0; i < `OUTPUT_DIM; i++) begin
			//weight[i] 	//input_dim
			//BI_out		//input_dim * channel cnt
			//ACC_in[i]		//input_dim * channel_cnt
			for(int j = 0; j < `INPUT_DIM; j++) begin
				ACC_in[i][j]	= {`CHANNEL_CNT{weight[i]}} ^~ BI_out;
			end
		end
	end


endmodule
