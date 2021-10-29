module accumulation (
	input			[`KERNEL_SIZE-1:0][`CHANNEL_CNT-1:0]	xnor_i,
	output logic 	[`KERNEL_SIZE-1:0][`BIT_WIDTH-1:0]		result_o
);
	logic [`BIT_WIDTH-1:0]									initial_value;
	always_comb begin
		initial_value = {1'b1, {{`BIT_WIDTH-1{1'b0}}};
		result_o	= {`KERNEL_SIZE{initial_value};
		for(int i = 0; i < `KERNEL_SIZE; i++) 
			for( int j = 0; j < `CHANNEL_CNT; j++) 
				result_o[i]		= result_o[i] + xnor_i[i][j];
		
	end
endmodule
