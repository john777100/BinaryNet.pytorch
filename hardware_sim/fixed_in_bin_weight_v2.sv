module fixed_in_bin_weight_v2 (
	input	[`INPUT_DIM-1:0][`BIT_CNT-1:0]				value_in,
	input	[`OUTPUT_DIM-1:0][`INPUT_DIM-1:0]			weight,
	output logic	[`OUTPUT_DIM-1:0][`BIT_CNT-1:0]		value_out
);
	logic	[`OUTPUT_DIM-1:0][`INPUT_DIM-1:0][`BIT_CNT:0]		ACC_in_bit;
	logic	[BIT_CNT:0]											sign_extended;
	always_comb begin
		ACC_in_bit	= 'b0;
		for(int i = 0; i < `OUTPUT_DIM; i++) begin
			for(int j = 0; j < `INPUT_DIM; j++) begin
				sign_extended		 	= {value_in[j][`BIT_CNT-1] ,value_in[j]};
				ACC_in_bit[i][j]	= weight[i][j] ? sign_extended : ~sign_extended + 1; 
			end
		end
	end
	accumulation_w_add_1 #(.PARAM_IN_CNT(`INPUT_DIM), .PARAM_IN_BIT(`BIT_CNT), .PARAM_CH_CNT(`CHANNEL_CNT)) a0 [`OUTPUT_DIM-1:0] (
		.value_i(ACC_in_bit),
		.result_o(value_out)
	);



endmodule
