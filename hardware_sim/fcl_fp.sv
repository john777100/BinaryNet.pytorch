module fp_PE
(    
    input clk,
    input rst,
    input signed [`FP_WIDTH-1:0] INPUT,
    input signed [`FP_WIDTH-1:0] W,
    input [$clog2(`ACC_WIDTH)-1:0] shift,
    output logic signed [`FP_WIDTH-1:0] S
);
    
    logic signed [2*`FP_WIDTH-1:0] partial_mult;
    logic signed [`ACC_WIDTH-1:0] acc;
    assign partial_mult = INPUT * W;
    assign S = acc >> shift;

    always_ff @(posedge clk) begin
        if(!rst)
            acc <= #1 partial_mult;
        else
            acc <= #1 acc + partial_mult;
    end
endmodule

module fcl_fp
(
    input clk,
    input rst,
    input  signed [`FP_WIDTH-1:0] INPUT,
    input  signed [`FP_PARALLEL-1:0][`FP_WIDTH-1:0] W,
    input [$clog2(4*`FP_WIDTH)-1:0] shift,
    output signed [`FP_PARALLEL-1:0][`FP_WIDTH-1:0] OUTPUT
);
    
    genvar i;
    generate
        for(i = 0; i < `FP_PARALLEL; i++) begin
            fp_PE  PE (
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
