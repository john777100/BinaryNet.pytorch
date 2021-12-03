module bin_PE
(    
    input clk,
    input rst,
    input signed  INPUT,
    input signed  W,
    input [$clog2(`ACC_WIDTH)-1:0] shift,
    output logic signed  S
);
    
    logic signed partial_mult;
    logic signed [`ACC_WIDTH-1:0] acc;
    assign partial_mult = INPUT ^~ W;
    assign S = acc >> shift;

    always_ff @(posedge clk) begin
        if(!rst)
            acc <= #1 partial_mult;
        else
			if(partial_mult)
            	acc <= #1 acc + 1;
			else
				acc <= #1 acc - 1;
    end
endmodule

module fcl_bin
(
    input clk,
    input rst,
    input  signed INPUT,
    input  signed [`BIN_PARALLEL-1:0]W,
    input [$clog2(`ACC_WIDTH)-1:0] shift,
    output signed [`BIN_PARALLEL-1:0] OUTPUT
);
    
    genvar i;
    generate
        for(i = 0; i < `BIN_PARALLEL; i++) begin
            bin_PE  PE (
                .clk(clk),
                .rst(rst),
                .INPUT(INPUT),
                .W(W[i]),
                .shift(shift),
				.S(OUTPUT[i])
            );
        end
    endgenerate
endmodule
