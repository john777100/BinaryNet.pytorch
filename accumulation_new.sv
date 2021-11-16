module accumulation (
	xnor_i,
	result_o
);

	parameter PARAM_IN_CNT		= 784;
	parameter PARAM_IN_BIT		= 2;
	parameter PARAM_CH_CNT		= 2 ** PARAM_IN_BIT; 


	input			[PARAM_IN_CNT-1:0][PARAM_CH_CNT-1:0]	xnor_i; 
	output logic	[PARAM_IN_BIT-1:0]						result_o;
	logic 			[$clog2(PARAM_IN_CNT*PARAM_CH_CNT):0]	initial_value, temp_result;
	always_comb begin
		temp_result	= 'b0;
		for(int i = 0; i < PARAM_IN_CNT; i++)
			for(int j = 0; j < PARAM_CH_CHT; j++)
				temp_result = xnor_i[i][j] ? temp_result + 1; temp_result - 1;
	
	/*	
		if(temp_result[$clog2(PARAM_IN_CNT*PARAM_CH_CNT):PARAM_IN_BIT-1] == {$clog2(PARAM_IN_CNT*PARAM_CH_CNT)-PARAM_IN_BIT{1'b1}})
			result_o 
	*/		
		if(temp_result[$clog2(PARAM_IN_CNT*PARAM_CH_CNT)]) begin
			result_o[PARAM_IN_BIT-1]	= 1'b1;
			result_o[PARAM_IN_BIT-2:0]  = temp_result[$clog2(PARAM_IN_CNT*PARAM_CH_CNT)-1:PARAM_IN_BIT-1] == {($clog2(PARAM_IN_CNT*PARAM_CH_CNT)-PARAM_IN_BIT+1){1'b1}} 
										  ? temp_result[PARAM_IN_BIT-2:0]
										  : {(PARAM_IN_BIT-1){1'b0}};
		end else begin
			result_o[PARAM_IN_BIT-1]	= 1'b0;
			result_o[PARAM_IN_BIT-2:0]  = temp_result[$clog2(PARAM_IN_CNT*PARAM_CH_CNT)-1:PARAM_IN_BIT-1] == {($clog2(PARAM_IN_CNT*PARAM_CH_CNT)-PARAM_IN_BIT+1){1'b0}} 
										  ? temp_result[PARAM_IN_BIT-2:0]
										  : {(PARAM_IN_BIT-1){1'b1}};

		end
	end
endmodule
