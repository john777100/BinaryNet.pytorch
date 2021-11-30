module fp_PE(
    input clk,
    input rst,
    input signed [DATAWIDTH-1:0] INPUT,
    input signed [DATAWIDTH-1:0] W,
    output logic signed [2*DATAWIDTH-1:0] S
);
    parameter DATAWIDTH = 8;
    
    logic signed [2*DATAWIDTH-1:0] partial_mult;
    assign partial_mult = INPUT * W;

    always_ff @(posedge clk) begin
        if(!rst)
            S <= #1 partial_mult;
        else
            S <= #1 S + partial_mult;
    end
endmodule

module fp_fcl(
    input clk,
    input rst,
    input  signed [DATAWIDTH-1:0] INPUT,
    input  signed [PARALLEL_NUM-1:0][DATAWIDTH-1:0] W,
    output signed [PARALLEL_NUM-1:0][2*DATAWIDTH-1:0] OUTPUT
);
    parameter DATAWIDTH = 8;
    parameter PARALLEL_NUM = 4;
    
    genvar i;
    generate
        for(i = 0; i < PARALLEL_NUM; i++) begin
            fp_PE #(.DATAWIDTH(DATAWIDTH)) PE (
                .clk(clk),
                .rst(rst),
                .INPUT(INPUT),
                .W(W[i]),
                .S(OUTPUT[i])
            )
        end
    endgenerate
endmodule
