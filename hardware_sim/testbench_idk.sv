module testbench ();
	logic	[`INPUT_DIM-1:0][7:0]					value_in;
	logic	[`OUTPUT_DIM-1:0][`INPUT_DIM-1:0][7:0]	weight;
	logic	[`OUTPUT_DIM-1:0][7:0]					value_out;

	logic	[`INPUT_DIM-1:0][7:0]					v;
	logic	[`OUTPUT_DIM-1:0][`INPUT_DIM-1:0][7:0]	w;



	fixed_in_bin_weight dut(
		.value_in(value_in),
		.weight(weight),
		.value_out(value_out)
	);

	initial begin
		$dumpfile("fixed_in_bin_weight.vcd");
        $dumpvars(0, dut);
		for (int z = 0; z < 50; z++) begin
			for (int i = 0; i < 10; i++) begin
				v = $random();
			end
			for (int j = 0; j < 10; j++) begin
				w = $random();
			end

			value_in = v;
			weight = w;
			#100;
		end
	end

endmodule : testbench