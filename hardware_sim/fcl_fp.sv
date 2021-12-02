module fp_PE
#(
    parameter DATAWIDTH = 8
)
(    
    input clk,
    input rst,
    input signed [DATAWIDTH-1:0] INPUT,
    input signed [DATAWIDTH-1:0] W,
    output logic signed [DATAWIDTH-1:0] S
);
    
    logic signed [2*DATAWIDTH-1:0] partial_mult;
    assign partial_mult = INPUT * W;

    always_ff @(posedge clk) begin
        if(!rst)
            S <= #1 partial_mult;
        else
            S <= #1 S + partial_mult;
    end
endmodule

module fp_fcl
(
    input clk,
    input rst,
    input  signed [7:0] INPUT,
    input  signed [`FP_PARALLEL-1:0][7:0] W,
    output signed [`FP_PARALLEL-1:0][7:0] OUTPUT
);
    
    genvar i;
    generate
        for(i = 0; i < `FP_PARALLEL; i++) begin
            fp_PE #(.DATAWIDTH(8)) PE (
                .clk(clk),
                .rst(rst),
                .INPUT(INPUT),
                .W(W[i]),
                .S(OUTPUT[i])
            );
        end
    endgenerate
endmodule
