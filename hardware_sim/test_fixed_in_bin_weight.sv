module test_proposed_model_w_bin ();

	logic	[`TEST_DATA_CNT-1:0][`INPUT_DIM-1:0][`BIT_CNT-1:0]		x;
	logic	[`OUTPUT_DIM-1:0][`INPUT_DIM-1:0]							weight;
	logic	[`TEST_DATA_CNT-1:0][`OUTPUT_DIM-1:0][`BIT_CNT-1:0]	y;

	logic	[`INPUT_DIM-1:0][`BIT_CNT-1:0]		value_in;
	logic	[`OUTPUT_DIM-1:0][`BIT_CNT-1:0]		value_out;
	integer	error_cnt, file_x, file_y, file_weight;

	fixed_in_bin_weight dut(
		.value_in(value_in),
		.weight(weight),
		.value_out(value_out)
	);


	initial begin
		error_cnt = 0;
		file_x 		= $fopen("./pattern/file_x.txt","r");
		file_y 		= $fopen("./pattern/file_y.txt","r");
		file_weight = $fopen("./pattern/file_weight.txt","r");
		
		for(int i = 0; i < `TEST_DATA_CNT; i++) begin
			for(int j = 0; j < `INPUT_DIM; j++) begin
				$fscanf(file_x,"%d",x[i][j]);
			end
		end

		for(int i = 0; i < `OUTPUT_DIM; i++) begin
			for(int j = 0; j < `INPUT_DIM; j++) begin
				$fscanf(file_weight,"%b",weight[i][j]);
			end
		end

		for(int i = 0; i < `TEST_DATA_CNT; i++) begin
			for(int j = 0; j < `OUTPUT_DIM; j++) begin
				$fscanf(file_y,"%d",y[i][j]);
			end
		end

		$fclose(file_x);
		$fclose(file_y);
		$fclose(file_weight);

		for(int i = 0; i < `TEST_DATA_CNT; i++) begin
			value_in = x[i];
			#10;
			if(value_out != y[i]) begin
				error_cnt ++;
			end
			#90;
		end
		$display("Total %d error in %d testing data",error_cnt,`TEST_DATA_CNT);
		$finish;
	end





endmodule
