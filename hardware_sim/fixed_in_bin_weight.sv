module fixed_in_bin_weight (
	input	[`INPUT_DIM-1:0][`BIT_CNT-1:0]		value_in,
	input	[`OUTPUT_DIM-1:0][`INPUT_DIM-1:0]	weight,
	output logic	[`OUTPUT_DIM-1:0][`BIT_CNT-1:0]		value_out
);
	logic	[`OUTPUT_DIM-1:0][$clog2(`INPUT_DIM * `CHANNEL_CNT)-1:0]		temp_value_out;
	logic	[$clog2(`INPUT_DIM * `CHANNEL_CNT)-1:0]							to_add;
	always_comb begin
		temp_value_out	= 'b0;
		value_out		= 'b0;
		for(int i = 0; i < `OUTPUT_DIM; i++) begin
			for(int j = 0; j < `INPUT_DIM; j++) begin
				to_add = value_in[j][`BIT_CNT-1] ? 'b0 - 1 : 'b0;
				to_add[`BIT_CNT-1:0] = value_in[j];
				temp_value_out[i] = temp_value_out[i] + (weight[i][j] ?  to_add : ~to_add + 1); 
			end
			
			if(temp_value_out[i][$clog2(`INPUT_DIM * `CHANNEL_CNT)-1]) begin
				value_out[i][`BIT_CNT-1]	= 1'b1;
				value_out[i][`BIT_CNT-2:0]  = temp_value_out[i][$clog2(`INPUT_DIM*`CHANNEL_CNT)-2:`BIT_CNT-1] == {($clog2(`INPUT_DIM*`CHANNEL_CNT)-`BIT_CNT){1'b1}} 
											  ? temp_value_out[i][`BIT_CNT-2:0]
											  : {(`BIT_CNT-1){1'b0}};
			end else begin
				value_out[i][`BIT_CNT-1]	= 1'b0;
				value_out[i][`BIT_CNT-2:0]  = temp_value_out[i][$clog2(`INPUT_DIM*`CHANNEL_CNT)-2:`BIT_CNT-1] == {($clog2(`INPUT_DIM*`CHANNEL_CNT)-`BIT_CNT){1'b0}} 
											  ? temp_value_out[i][`BIT_CNT-2:0]
											  : {(`BIT_CNT-1){1'b1}};
			end
		end
	end



endmodule
