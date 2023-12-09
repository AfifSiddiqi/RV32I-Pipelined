module hazard_detection_unit(
input [4:0]  ID_EX_rd, IF_ID_rs1, IF_ID_rs2,
input ID_EX_memread,
output reg PCWrite, IF_Dwrite, hazard_out

);

always@(*)
begin
	if(ID_EX_memread && ( ID_EX_rd==IF_ID_rs1 || ID_EX_rd==IF_ID_rs2 ))  begin
			//stall the pipeline
			hazard_out = 1'b1;
			PCWrite = 1'b0;
			IF_Dwrite = 1'b0;
			end
	else begin 
			//no need to stall the pipeline
			hazard_out = 1'b0;
			PCWrite = 1'b1;
			IF_Dwrite = 1'b1;
			end

end

endmodule