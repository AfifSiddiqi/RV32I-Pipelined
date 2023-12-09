module forwarding_unit(
			input [4:0] rs1, rs2, EX_MEM_rd, MEM_WB_rd ,
			input EX_MEM_regwrite, MEM_WB_regwrite ,
			output reg [1:0] forward_A, forward_B
);

always@(*)
begin 
	// MUX A
	if(EX_MEM_regwrite==1'b1 && EX_MEM_rd!=5'b0 && EX_MEM_rd==rs1) //checking EX Hazard
			forward_A = 2'b10;
	else if(MEM_WB_regwrite==1'b1 && MEM_WB_rd!=5'b0 && MEM_WB_rd==rs1) //checking MEM Hazard
			forward_A = 2'b01;
	else forward_A = 2'b00;									//no fwding hazard
	
	
	// MUX B
	if(EX_MEM_regwrite==1'b1 && EX_MEM_rd!=5'b0 && EX_MEM_rd==rs2) //checking EX Hazard
			forward_B = 2'b10;
	else if(MEM_WB_regwrite==1'b1 && MEM_WB_rd!=5'b0 && MEM_WB_rd==rs2) //checking MEM Hazard
			forward_B = 2'b01;
	else forward_B = 2'b00;								//no fwding hazard

end

endmodule
