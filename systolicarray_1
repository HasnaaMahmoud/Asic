module PE
  #(parameter width=8)(
  input clk_in, nrst_in, ctrl_in,
  input [width-1:0] weight_in, feature_in,
  output [width-1:0] partial_sum_out, feature_out
  );
  
  wire [width-1:0] partial_sum_w; //output from addition operation
  wire [width-1:0] mul_w;         //output from multiplication operation
  reg  [width-1:0] weight_reg;    //saved weight in it
  reg  [width-1:0] weight_rst;    //weight value in reset mode
  wire [width-1:0] partial_sum_in;

  //assign weight_in = (ctrl_in)? weight_reg : partial_sum_in;
  assign feature_out = feature_in;
  assign partial_sum_out = (ctrl_in)?  weight_reg : partial_sum_w; //ctrl=0 : partial_sum_w
                                                                   //ctrl=1 : weight_reg

  assign weight_reg=(ctrl_in)?weight_in:weight_rst;
  assign partial_sum_in=(ctrl_in)?partial_sum_in:weight_in;

	

  
  //multiplication and addition 
  Mul u1(weight_reg,feature_in,mul_w);
  Add u2(partial_sum_in,mul_w,partial_sum_w);

                                                             
 always@(posedge clk_in, negedge nrst_in)
  begin
    if(!nrst_in)
      weight_rst <= 0;
    else 
      weight_rst <= weight_reg; //no change

	
  end



//initial
//$monitor(" pe = clk= %b rst= %b ctrl= %b w_i= %b w_r= %b f_i= %b p_s_o= %b",clk_in,nrst_in,ctrl_in,weight_in,weight_reg,feature_in,partial_sum_out);

endmodule

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
module PE_test;

 	parameter width=8 ;
	`define delay 10
	
	 reg clk_in, nrst_in, ctrl_in;
	 reg [width-1:0] weight_in, feature_in;
	 wire[width-1:0] partial_sum_out, feature_out;
 

	PE pe_inst(.clk_in(clk_in) , 
		.nrst_in(nrst_in) , 
		.ctrl_in(ctrl_in) , 
		.weight_in(weight_in) , 
		.feature_in(feature_in) , 
		.partial_sum_out(partial_sum_out) , 
		.feature_out(feature_out)
		);

	initial clk_in = 0;
	always #`delay clk_in = ~clk_in;


	initial
	begin
	//ctrl_in=1 -->load weight in  PE
		#(`delay*2)
		nrst_in=1'b1;
		ctrl_in=1'b1;
		weight_in=8'h02;//PE weights
		feature_in=8'b01;

		//input partial_sum_in
		#(`delay*2)
		nrst_in=1'b1;
		ctrl_in=1'b0;
		weight_in=8'h03;//partial_sum_in
		feature_in=8'b01;


		//reset pe with ctrl=0
		#(`delay*2)
		nrst_in=1'b0;
		ctrl_in=1'b0;
		weight_in=8'h03;//PE weights
		feature_in=8'b01;


		//reset pe with ctrl=1
		#(`delay*2)
		nrst_in=1'b0;
		ctrl_in=1'b1;
		weight_in=8'h03;//PE weights
		feature_in=8'b01;
	

//$monitor(" pe_test = clk= %b rst= %b ctrl= %b w_i= %b f_i= %b p_s_o= %b",clk_in,nrst_in,ctrl_in,weight_in,feature_in,partial_sum_out);
	end
endmodule


////////////////////////////////////////////////////////////////////////////////////////
  
module systolic_vector
  #(parameter width=8 , row = 2)(
  input clk_in1, nrst_in1, ctrl_in1,[width-1:0] weight_input1,[width-1:0] feature_input[row-1:0],
  output [width-1:0] vec_out , [width-1:0] feature_out1[row-1:0]
  );

//wire [row-1:0][width-1:0] feature_output;
wire [width-1:0] weight[row:0];


assign weight[0] = weight_input1;

assign vec_out=weight[row];


genvar i;
generate
    for (i=0; i<=row-1; i=i+1) begin PE
         p1(
        .clk_in(clk_in1),
        .nrst_in(nrst_in1),
        .ctrl_in(ctrl_in1),
        .weight_in(weight[i]),
        .feature_in(feature_input[i]),
        .partial_sum_out(weight[i+1]),
        .feature_out(feature_out1[i])
    );
end 
endgenerate	


//initial 
//$monitor("vec clk=%b rst=%b ctrl=%b, w_i=%b f_i=%b p_s_o=%b f_o=%b",clk_in1,nrst_in1,ctrl_in1,weight_input1,feature_input,vec_out,feature_out1); 
endmodule


/////////////////////////////////////////////////////////////////////
module vec_test;

 	parameter width=8,row=2 ;
	`define delay 10
	
	reg [row-1:0]clk_in1;
	reg [row-1:0]nrst_in1;
	reg [row-1:0]ctrl_in1;
	reg[width-1:0] weight_input1;
	reg[row-1:0][width-1:0] feature_input;
  	wire [width-1:0] vec_out ;
	wire [row-1:0][width-1:0] feature_out1;

	systolic_vector vec_inst(.clk_in1(clk_in1) , 
		.nrst_in1(nrst_in1) , 
		.ctrl_in1(ctrl_in1) , 
		.weight_input1(weight_input1) , 
		.feature_input(feature_input) , 
		.vec_out(vec_out) , 
		.feature_out1(feature_out1)
		);

	initial clk_in1 = 0;
	always #`delay clk_in1 = ~clk_in1;


	initial
	begin
	//ctrl_in=1 -->load weight in  2 PE
		#(`delay*2)
		nrst_in1=2'b11;
		ctrl_in1=2'b11;
		weight_input1=8'h02;//PE weights
		feature_input=16'b0101;

		
		#(`delay*2)
		nrst_in1=2'b11;
		ctrl_in1=2'b01;
		weight_input1=8'h03;
		feature_input=16'b0101;


	//input partial_sum_in
		#(`delay*2)
		nrst_in1=2'b11;
		ctrl_in1=2'b00;
		weight_input1=8'h06;//partial_sum_in
		feature_input=16'b0101;


		#(`delay*2)
		nrst_in1=2'b11;
		ctrl_in1=2'b00;
		weight_input1=8'h07;//partial_sum_in
		feature_input=16'b0101;
	


	end
endmodule

/////////////////////////////////////////////////////////////////////////////////////////////////////////////

module systolic_array
  #(parameter width=8 , row=2 ,  col=2)(//[row*col-1:0][col-1:0]ctrl_in2
  input clk_in2, nrst_in2,ctrl_in2, [width-1:0] weight_input2 [col-1:0] ,[width-1:0] feature_input2 [row-1:0],
  output [width-1:0] systolic_out [col-1:0]
  );

//wire [row-1:0][width-1:0] out;
//assign systolic_out = out[row-1];

wire  [width-1:0]feature_wires[row*(col+1):0];
//wire [row*col-1:0] [width-1:0]weight_wires;

assign feature_wires[row-1:0]=feature_input2;
//assign weight_wires[row-1:0]=weight_input2;

genvar j;
//genvar k;

generate
	for (j=0; j<=col-1; j=j+1) begin 
		
			systolic_vector p2(
        		.clk_in1(clk_in2),
        		.nrst_in1(nrst_in2),
       			.ctrl_in1(ctrl_in2),
        		.weight_input1(weight_input2[j]),
        		.feature_input(feature_wires[(j+1)*row-1:j*row]),
        		.vec_out(systolic_out[j]),
        		.feature_out1(feature_wires[(j+2)*row-1:(j+1)*row])
		 );
		
	end 


endgenerate
		 
endmodule
//////////////////////////////////////////////////////

module systolic_test;

 parameter width=8 , row=2 ,  col=2;
`define delay 10

 reg    [row*col-1:0]clk_in2;
 reg	[row*col-1:0]nrst_in2;
 reg	[row*col-1:0]ctrl_in2;
 reg	[col-1:0][width-1:0] weight_input2 ;
 reg	[row-1:0][width-1:0] feature_input2;
 wire	[col-1:0][width-1:0] systolic_out ;
 



systolic_array inst1(.clk_in2(clk_in2) , .nrst_in2(nrst_in2) , .ctrl_in2(ctrl_in2) , .weight_input2(weight_input2) , .feature_input2(feature_input2) , .systolic_out(systolic_out));

initial clk_in2 = 0;
always #`delay clk_in2 = ~clk_in2;


initial
begin
//ctrl_in=1 -->load weight in each PE

nrst_in2=4'b1111;
ctrl_in2=4'b1111;
weight_input2=16'h0201;//PE weights
feature_input2=16'b0;


#(`delay*4)
nrst_in2=4'b1111;
ctrl_in2=4'b0011;
weight_input2=16'h0403;//PE weights
feature_input2=16'b0;


//ctrl_in=0 -->start partial_sum_in 
#(`delay*4)
nrst_in2=4'b1111;
ctrl_in2=4'b0000;
weight_input2=16'h0101;//partial sum in
feature_input2=16'b0;



$monitor("array  clk= %b reset= %b ctrl= %b weight_in= %b f_i= %b out= %b",clk_in2,nrst_in2,ctrl_in2,weight_input2,feature_input2,systolic_out);

end
endmodule
