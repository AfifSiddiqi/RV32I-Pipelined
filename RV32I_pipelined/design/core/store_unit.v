module store_unit(
input [2:0] fu3,
input [1:0]dmem_address,
output reg [3:0]byte_en
);

always@(*)
begin
	case(fu3)
		//sb
		3'd0 : case(dmem_address)										
				 2'd0 : byte_en = 4'b0001;	
				 2'd1 : byte_en = 4'b0010;
				 2'd2 : byte_en = 4'b0100;
				 2'd3 : byte_en = 4'b1000;	
				 default : byte_en = 4'b0001;	
             endcase
	
		//sh
		3'd1 : case(dmem_address)									
				 2'd0 : byte_en = 4'b0011;	
				 2'd2 : byte_en = 4'b1100;	
				 default : byte_en = 4'b0011;	
             endcase
		
		//sw
		3'd2 : byte_en = 4'b1111;						 
		
		default : byte_en = 4'b1111;
		endcase
end

endmodule