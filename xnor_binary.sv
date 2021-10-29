module xnor_binary(
	input			[`KERNEL_SIZE-1:0] weight_i,
	input			[`KERNEL_SIZE-1:0] pixels_i,

	output logic	[`KERNEL_SIZE-1:0]	result_o
);
	assign result_o = weight_i ^~ pixels_i;
endmodule
