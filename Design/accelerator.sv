module accelerator (
    input  logic                clock,        
    input  logic                reset_n,  
    input  logic signed [7:0]   vector_a,          
    input  logic signed [7:0]   vector_b,        
    input  logic                start,     
    output logic signed [31:0]  vector_c,     
	input logic clear_vec_c      
);
    // internal signals  
	logic signed [31:0]  vector_c_internal;

	always_comb begin
		vector_c_internal = vector_c; 
	    if (start) begin
            vector_c_internal  = vector_c  + (vector_a * vector_b);
		end
    end

	//driving the output data
	always_ff @(posedge clock or negedge reset_n) begin
		if(!reset_n) begin
			vector_c <= 32'b0;
		end//if 
		else if (clear_vec_c) begin
			vector_c <= 0;
		end
		else begin
			vector_c <= vector_c_internal;
		end	
		end               
endmodule
  
  
  