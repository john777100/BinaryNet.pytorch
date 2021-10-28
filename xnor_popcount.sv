
module xnor_popcount (
	input						clock,
	input						reset,
	input						weight_wr,
	input 						input_plugin,
	input	[`KERNEL_SIZE-1:0] weight_in,
	input	[`KERNEL_SIZE-1:0] pixels_in,

	output	logic				ready_out,
	output	logic				result_out
);

	logic [`KERNEL_SIZE-1:0]			weight_reserve, next_weight_reserve;
	logic [`KERNEL_SIZE-1:0]			xnor_result;
	logic [$clog2(`KERNEL_SIZE):0]		pop_result;
	logic								next_result;
	logic								next_ready;

	always_comb begin
		next_weight_reserve = weight_reserve;
		xnor_result 		= 0;
		pop_result			= 0;
		next_result			= 0;
		next_ready			= 0;
		if (weight_wr) begin
			next_weight_reserve = weight_in;
		end
		if (input_plugin) begin
			next_ready 	= 1;
			xnor_result = pixels_in ^~ weight_reserve;
			for (int i = 0; i < `KERNEL_SIZE; i++) begin
				pop_result = pop_result + xnor_result[i];
			end
			if (pop_result >= RELU_THRESHOLD) begin
				next_result = 1;
			end
		end
	end

	always_ff @(posedge clock) begin
		if (reset) begin
			weight_reserve 	<= 0;
			result_out		<= 0;
			ready_out 		<= 0;
		end
		else begin
			weight_reserve 	<= next_weight_reserve;
			result_out 		<= next_result;
			ready_out		<= next_ready;
		end
	end

endmodule
