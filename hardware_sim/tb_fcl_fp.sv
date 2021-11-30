`timescale 1ns / 1ps
module tb_fp_fcl ();

	logic clk;
    logic rst;
    logic [`FP_WIDTH-1:0] INPUT;
    logic [`PARALLEL-1:0][`FP_WIDTH-1:0] W;
    logic [`PARALLEL-1:0][`FP_WIDTH-1:0] OUTPUT;
    logic [`FP_MODEL_WIDTH-1:0][`FP_WIDTH-1:0] hidden_neuron, pre_neuron;
	
    int [3:0] num_neuron;
    integer	error_cnt, file_x, file_y, file_weight;

	fp_fcl dut(
		.clk(clk),
        .rst(rst),
        .INPUT(INPUT),
        .W(W),
        .OUTPUT(OUTPUT)
	);

    always begin
        clk = #(`FP_CLOCK) ~clk;
    end

	initial begin
        $dumpfile("fcl_fp.vcd");
        $dumpvars(0, dut);
		error_cnt = 0;
        clk = 0;
		file_x 		= $fopen("./pattern/file_x.txt","r");
		file_y 		= $fopen("./pattern/file_y.txt","r");
		file_weight = $fopen("./pattern/file_weight.txt","r");

        // Model Config
        num_neuron = {28, 16, 16, 16, 10};
		
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

        int w_idx = 0;

		for(int i = 0; i < `TEST_DATA_CNT; i++) begin
            pre_neuron[num_neuron[0]-1:0] = x[i];
            for(int layer = 1; layer < num_neuron.size; layer++) begin // loop through layer
                reset = 0;
                for(int out = 0; out < num_neuron[layer]; out = out+`PARALLEL) begin // loop through output neuron
                    for(int in = 0; in < num_neuron[layer-1]; in++ ) begin // loop through input neuron
                        INPUT = pre_neuron[in];
                        W = weights[w_idx+`PARALLEL-1: w_idx];
                        if(!reset) begin
                            @(negedge clk);
                            reset = 1;
                        end
                        @(posedge clk);
                        w_idx = w_idx + `PARALLEL;
                    end
                    hidden_neuron[out+`PARALLEL-1:out] = OUTPUT;
                end
                pre_neuron = hidden_neuron;
            end
		end
		$display("Total %d error in %d testing data",error_cnt,`TEST_DATA_CNT);
		$finish;
	end





endmodule
