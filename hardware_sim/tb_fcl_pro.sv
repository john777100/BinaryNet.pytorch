`timescale 1ns / 1ps

module tb_fcl_pro ();
	logic clk;
    logic rst;
    logic [`PRO_WIDTH-1:0] INPUT;
    logic [`PRO_PARALLEL-1:0][`PRO_WIDTH-1:0] W;
    logic [`PRO_PARALLEL-1:0][`PRO_WIDTH-1:0] OUTPUT;
    logic [`PRO_MODEL_WIDTH/`PRO_PARALLEL-1:0][`PRO_PARALLEL-1:0][`PRO_WIDTH-1:0] hidden_neuron;
    logic [`PRO_MODEL_WIDTH-1:0][`PRO_WIDTH-1:0] pre_neuron;
    logic [$clog2(`ACC_WIDTH)-1:0] shift;
    logic	[`TEST_DATA_CNT-1:0][`INPUT_DIM-1:0][`BIT_CNT-1:0]		x;
	logic	[3303:0][`PRO_PARALLEL-1:0][`PRO_WIDTH-1:0]                  weight;
	logic	[`TEST_DATA_CNT-1:0][`OUTPUT_DIM-1:0][`BIT_CNT-1:0]	    y;
    integer num_neuron  [0:4] = '{784, 16, 16, 16, 10}; // Model Config
    integer	error_cnt, file_x, file_y, file_weight;
    int i, layer, out, in, clk_num;

	fcl_pro dut(
		.clk(clk),
        .rst(rst),
        .INPUT(INPUT),
        .W(W),
        .shift(shift),
        .OUTPUT(OUTPUT)
	);

    always begin
        #(`PRO_CLOCK/2);
        clk = ~clk;
        if(clk) clk_num ++;
    end

	initial begin
        $dumpfile("fcl_pro.vcd");
        $dumpvars(0, dut);
	error_cnt = 0;
	clk_num = 0;
        clk = 0;
	file_x 		= $fopen("./pattern/file_x.txt","r");
	file_y 		= $fopen("./pattern/file_y.txt","r");
	file_weight = $fopen("./pattern/file_weight.txt","r");
		
	//	for(int i = 0; i < `TEST_DATA_CNT; i++) begin
	//		for(int j = 0; j < `INPUT_DIM; j++) begin
	//			$fscanf(file_x,"%d",x[i][j]);
	//		end
	//	end

	//	for(int i = 0; i < `TEST_DATA_CNT; i++) begin
	//		for(int j = 0; j < `OUTPUT_DIM; j++) begin
	//			$fscanf(file_y,"%d",y[i][j]);
	//		end
	//	end

	//	$fclose(file_x);
	//	$fclose(file_y);

	for(i = 0; i < `TEST_DATA_CNT; i++) begin
            for(int l = 0; l < num_neuron[0]; l++) pre_neuron[l] =  $urandom;
            for(layer = 1; layer < $size(num_neuron); layer++) begin // loop through layer
                rst = 0;
                shift = $urandom;
                for(out = 0; out < num_neuron[layer]/`PRO_PARALLEL; out ++) begin // loop through output neuron
                    for(in = 0; in < num_neuron[layer-1]; in++) begin // loop through input neuron
                        INPUT = pre_neuron[in];
                        for(int w = 0; w < `PRO_PARALLEL; w++) begin
                            // $fscanf(file_weight, "%b", W[w]);
                            W[w] = $urandom;
                        end
                        if(!rst) begin
                            @(negedge clk);
                            rst = 1;
                        end
                        @(posedge clk);
                    end
                    hidden_neuron[out] = OUTPUT;
                end
                pre_neuron = hidden_neuron;
            end
		end
		$display("Total %d error in %d testing data",error_cnt,`TEST_DATA_CNT);
		$fclose(file_weight);
		$finish;
	end





endmodule

