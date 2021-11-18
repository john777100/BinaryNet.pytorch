module proposed_model_w_bin_v2 (
	input	[`INPUT_DIM-1:0][`BIT_CNT-1:0]		value_in,
	input	[`OUTPUT_DIM-1:0][`INPUT_DIM-1:0]	weight,
	output	[`OUTPUT_DIM-1:0][`BIT_CNT-1:0]		value_out
);

	logic	[`INPUT_DIM-1:0][`BIT_CNT-1:0]						BI_in;
	logic	[`INPUT_DIM-1:0][`CHANNEL_CNT-1:0]					BI_out;
	logic	[`OUTPUT_DIM-1:0][`INPUT_DIM-1:0][`CHANNEL_CNT-1:0]	ACC_in_ch;
	logic	[`OUTPUT_DIM-1:0][`INPUT_DIM-1:0][`BIT_CNT:0]		ACC_in_bit;
	logic	[`BIT_CNT:0]										sign_extended;
	assign 	BI_in		= value_in;	

	binarization_input #(.PARAM_IN_CNT(`INPUT_DIM), .PARAM_IN_BIT(`BIT_CNT), .PARAM_CH_CNT(`CHANNEL_CNT)) b0(
		.pixel_in(BI_in),
		.pixel_out(BI_out)
	);
	always_comb begin
		for(int i = 0; i < `OUTPUT_DIM; i++) begin
			//weight[i] 	//input_dim
			//BI_out		//input_dim * channel cnt
			//ACC_in_ch[i]	//input_dim * channel_cnt
			for(int j = 0; j < `INPUT_DIM; j++) begin
				ACC_in_ch[i][j]	= {`CHANNEL_CNT{weight[i][j]}} ^~ BI_out[j];
			end
		end
	end

	always_comb begin
		ACC_in_bit	= 'b0;
		for(int i = 0; i < `OUTPUT_DIM; i++) begin
			for(int j = 0; j < `INPUT_DIM; j++) begin
				for(int k = 0; k < `CHANNEL_CNT; k++) begin
					ACC_in_bit[i][j]	= ACC_in_ch[i][j][k] ? ACC_in_bit[i][j]+1 : ACC_in_bit[i][j] - 1; 
				end
			
			end
		end
	end

	
	accumulation_w_add_1 #(.PARAM_IN_CNT(`INPUT_DIM), .PARAM_IN_BIT(`BIT_CNT), .PARAM_CH_CNT(`CHANNEL_CNT)) a0 [`OUTPUT_DIM-1:0] (
		.value_i(ACC_in_bit),
		.result_o(value_out)
	);



endmodule

