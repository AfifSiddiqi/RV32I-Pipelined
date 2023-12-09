module register 
#(parameter width = 32,
  parameter Default_val = 0)
(clk,reset,d,q,flush);
input clk, reset,flush;

input [width-1:0] d;
output reg [width-1:0] q;

always@(posedge clk or negedge reset)
begin
	if(!reset)
		q <= Default_val;
	else if(flush)
		q <= Default_val;
	else
		q <= d;
end

endmodule
