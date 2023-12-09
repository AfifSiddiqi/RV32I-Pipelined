module pcregister
#(parameter width = 32,  
parameter Default_val = 0)
(clk,reset,en,d,q,e,flush);

input clk, reset, en, flush;
input [width-1:0] d,e;
output reg [width-1:0] q;

always@(posedge clk or negedge reset )
begin
	if(!reset)
		q <= Default_val;
	else if(!flush)
	 	q <= e;
	else
		q <= d;
end

endmodule
