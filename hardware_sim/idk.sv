module fixed_in_bin_weight (
	input	[`INPUT_DIM-1:0][7:0]			value_in,
	input	[`OUTPUT_DIM-1:0][`INPUT_DIM-1:0][7:0]	weight,
	output	[`OUTPUT_DIM-1:0][7:0]			value_out
);



	logic [9:0][9:0][15:0]		mult_result;
	logic [9:0][20:0] 			intermediate

	always_comb begin
		for (int i = 0; i < 10; i++) begin
			for (int j = 0; j < 10; j++) begin
				mult_result[i][j] = value_in[i] * weight[i][j];
			end
		end
		for (int i = 0; i < 10; i++) begin
			for (int j = 0; i < 10; j++) begin
			 	intermediate[i] = value_out[i] + mult_result[i][j];
			end 
		end
		for (int i = 0; i < 10; i++) begin
			value_out[i] = intermediate[7:0];
		end
	end


endmodule