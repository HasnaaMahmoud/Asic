module PE
  #(parameter width=8)(
  input clk_in, nrst_in, ctrl_in,
  input [width-1:0] weight_in, feature_in,
  output [width-1:0] partial_sum_out, feature_out
  );
  
  wire [width-1:0] partial_sum_w; //output from addition operation
  wire [width-1:0] mul_w;         //output from multiplication operation
  reg  [width-1:0] weight_reg;    //saved weight in it
  wire [width-1:0] partial_sum_in;

  assign weight_in = (ctrl_in)? weight_reg : partial_sum_in;
  assign feature_out = feature_in;
  assign partial_sum_out = (ctrl_in)?  weight_reg : partial_sum_w; //ctrl=0 : partial_sum_w
                                                                   //ctrl=1 : weight_reg
  
  //multiplication and addition 
  Mul u1(weight_reg,feature_in,mul_w);
  Add u2(partial_sum_in,mul_w,partial_sum_w);
                                                             
  always@(posedge clk_in, negedge nrst_in)
  begin
    if(!nrst_in)
      weight_reg <= 0;
    else
      weight_reg <= weight_in;
  end
endmodule

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
module systolic_vector
  #(parameter width=8 , row = 2)(
  input [row-1:0]clk_in1, [row-1:0]nrst_in1, [row-1:0]ctrl_in1,[width-1:0] weight_input1,[row-1:0][width-1:0] feature_input,
  output [width-1:0] vec_out , [row-1:0][width-1:0] feature_out1
  );

wire [row-1:0][width-1:0] feature_output;
wire [row:0][width-1:0] weight;


assign weight[0] = weight_input1;
assign weight[row] = vec_out;


genvar i;
generate
    for (i=0; i<=row-1; i=i+1) begin PE
         p1(
        .clk_in(clk_in1[i]),
        .nrst_in(nrst_in1[i]),
        .ctrl_in(ctrl_in1[i]),
        .weight_in(weight[i]),
        .feature_in(feature_input[i]),
        .partial_sum_out(weight[i+1]),
        .feature_out(feature_out1[i])
    );
end 
endgenerate	 
endmodule

/////////////////////////////////////////////////////////////////////////////////////////////////////////////

module systolic_array
  #(parameter width=8 , row=2 ,  col=2)(//[row*col-1:0][col-1:0]ctrl_in2
  input [row*col-1:0]clk_in2, [row*col-1:0]nrst_in2, [row*col-1:0]ctrl_in2, [row-1:0][width-1:0] weight_input2 ,[row-1:0][width-1:0] feature_input2,
  output [col-1:0][width-1:0] systolic_out 
  );

wire [row-1:0][width-1:0] out;
assign systolic_out = out[row-1];

wire [row*(col+1):0] [width-1:0]feature_wires;
wire [row*col-1:0] [width-1:0]weight_wires;

assign feature_wires[row-1:0]=feature_input2;
assign weight_wires[row-1:0]=weight_input2;

genvar j;
//genvar k;

generate
	for (j=0; j<=col-1; j=j+1) begin 
		
			systolic_vector p2(
        		.clk_in1(clk_in2[(j+1)*row-1:j*row]),//  2:0  5:3  9:6
        		.nrst_in1(nrst_in2[(j+1)*row-1:j*row]),
       			.ctrl_in1(ctrl_in2[(j+1)*row-1:j*row]),
        		.weight_input1(weight_wires[j]),
        		.feature_input(feature_wires[(j+1)*row-1:j*row]),
        		.vec_out(out[j]),
        		.feature_out1(feature_wires[(j+2)*row-1:(j+1)*row])
		 );
		
	end 


endgenerate
		 
endmodule
//////////////////////////////////////////////////////
module systolic_test;
 parameter width=8 , row=2 ,  col=2;

 reg    [row*col-1:0]clk_in2;
 reg	[row*col-1:0]nrst_in2;
 reg	[row*col-1:0]ctrl_in2;
 reg	[col-1:0][width-1:0] weight_input2 ;
 reg	[row-1:0][width-1:0] feature_input2;
 wire	[col-1:0][width-1:0] sys_out ;
 



systolic_array inst1(.clk_in2(clk_in2) , .nrst_in2(nrst_in2) , .ctrl_in2(ctrl_in2) , .weight_input2(weight_input2) , .feature_input2(feature_input2) , .systolic_out(sys_out));

initial clk_in2 = 0;
always #10 clk_in2 = ~clk_in2;


initial
begin
#20
nrst_in2=9'b111111111;
ctrl_in2=9'b0;
weight_input2=72'h090807060504031111;
feature_input2=24'h010101;





$monitor("%b %b %b %b %b %b",clk_in2,nrst_in2,ctrl_in2,weight_input2,feature_input2,sys_out);

end
endmodule
