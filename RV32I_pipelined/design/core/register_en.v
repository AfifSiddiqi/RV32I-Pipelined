module register_en
#(parameter width = 32,  
parameter Default_val = 0)
(clk,reset,en,d,q,flush);

input clk, reset, en, flush;
input [width-1:0] d;
output reg [width-1:0] q;

always@(posedge clk or negedge reset)
begin
	if(!reset)
		q <= Default_val;
	else if(flush)
	 	q <= Default_val;
	else if(en)
		q <= d;
end

endmodule
