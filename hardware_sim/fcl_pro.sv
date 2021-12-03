module pro_PE
(    
    input clk,
    input rst,
    input signed [`PRO_CH_CNT-1:0] 	INPUT,
    input signed  					W,
    input [$clog2(`ACC_WIDTH)-1:0] 	shift,
    output logic signed [`PRO_WIDTH-1:0] S
);
    
    logic [`PRO_CH_CNT-1:0] 		partial_xnor;

    logic signed [`PRO_WIDTH+1:0] 	local_acc;
    logic signed [`PRO_WIDTH:0] 	actual_acc;
	logic signed [`ACC_WIDTH-1:0] 	acc;

    assign S = acc >> shift;

	always_comb begin
		if(W)
			partial_xnor = INPUT;
		else
			partial_xnor = ~INPUT+1;
		local_acc = 'b0
		for (int i = 0; i < `PRO_CH_CNT; i++) begin
			if(partial_xnor[i])
				local_acc = local_acc + 1;
			else
				local_acc = local_acc - 1;
		end
		actual_acc = local_acc[`PRO_WIDTH+1:1];
	end

    always_ff @(posedge clk) begin
        if(!rst)
            acc <= #1 actual_acc;
        else
            acc <= #1 acc + actual_acc;
    end
endmodule

module fcl_pro
(
    input 												clk,
    input 												rst,
    input  signed [`PRO_WIDTH-1:0] 						INPUT,
    input  signed [`PRO_PARALLEL-1:0] 					W,
    input [$clog2(`ACC_WIDTH)-1:0] 						shift,
    output signed [`PRO_PARALLEL-1:0][`PRO_WIDTH-1:0] 	OUTPUT
);
  
	logic [`PRO_CH_CNT-1:0]		BIN_INPUT;
	logic [`PRO_WIDTH-1:0] 	negative_cnt;	// range 1 - 256 mapping to 0 - 255
	always_comb begin
		BIN_INPUT = 'b0-1;
		negative_cnt	= (`PRO_CH_CNT/2 - {INPUT[`PRO_WIDTH-1],INPUT}); // (256 - pixel * 2) >> 1 === 128 - pixel
		BIN_INPUT = BIN_INPUT >> negative_cnt;
	end
	
    genvar i;
    generate
        for(i = 0; i < `PRO_PARALLEL; i++) begin
            pro_PE  PE (
                .clk(clk),
                .rst(rst),
                .INPUT(BIN_INPUT),
                .W(W[i]),
                .shift(shift),
				.S(OUTPUT[i])
            );
        end
    endgenerate
endmodule

