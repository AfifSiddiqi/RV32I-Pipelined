	import risc_v_core_pkg::*;
	import tracer_pkg::*;

	module RISCV32I(
	input 										clk_in,
	input											rst_in,
	mem_ntv_interface_if			mem_ntv_interface_imem,
	mem_ntv_interface_if			mem_ntv_interface_dmem
	);

	instruction_t							instruction_o;
	controls_t								controls_o;

	wire [31:0] PC_out, PCout_plus4;
	wire [31:0] inst_mem_out, data_mem_out;
	wire [31:0] rs1_out, rs2_out, inst_out_imm, alu_result;

	wire [31:0] mux_out1,mux_out3,mux_outA,mux_outB,mux_out4,mux_out5,mux_out6,mux_outjalr;
	wire [17:0] mux_out2, cntrl_out_ID_EX;
	wire RegWrite, MemtoReg, MemRead, MemWrite, jal, jalr;
	wire [1:0] ALUOp, ALUSrcA, ALUSrcB;
	wire [5:0] Branch;
	wire PCSrc, PCWrite, IF_DWrite, hazard_out;
	wire [63:0] IF_ID_out;
	wire [31:0] PC_out_IF_ID, inst_out_IF_ID;
	wire [31:0] PC_out_ID_EX, inst_out_ID_EX, imm_out_ID_EX, ADDSum_out ,rs1_out_ID_EX, rs2_out_ID_EX;
	wire [31:0] ADDSum_out_EX_MEM, alu_result_EX_MEM, rs2_out_EX_MEM, inst_out_EX_MEM;
	wire [31:0] dataout_MEM_WB, alu_result_MEM_WB, inst_out_MEM_WB, load_store_unit_out, data_mem_fwd;
	wire [1:0] forwardA, forwardB;
	wire [3:0] alu_contrl, byte_en;
	wire zero, nzero, less, greater, lessun, greaterun;
	wire [3:0] cntrl_out_Ex_MEM;
	wire [1:0] cntrl_out_MEM_WB,forwardjalr;
	reg PCSrc_reg;
	reg [31:0] PC_out_reg;
	reg [31:0] mux_outpc, mux_outpcreg;
	reg	valid, hazard_out_reg, IF_Dwrite_reg;

	wire a_n_d_1, a_n_d_2, a_n_d_3, a_n_d_4, a_n_d_5, a_n_d_6;

	///////////////////////////////////////////////////////////////////////////////////////////////
	//////assigning values to IMEM

	assign mem_ntv_interface_imem.addr          = PC_out;
	assign mem_ntv_interface_imem.r_en          = PCWrite;  
	assign inst_mem_out 										    = mem_ntv_interface_imem.rdata;

	///////////////////////////////////////////////////////////////////////////////////////////////
	//////assigning values to DMEM

	assign mem_ntv_interface_dmem.addr         	= alu_result_EX_MEM  ; 					
	assign mem_ntv_interface_dmem.wdata      	  = data_mem_fwd;   			
	assign mem_ntv_interface_dmem.w_en       	  = cntrl_out_Ex_MEM[2]; 	
	assign mem_ntv_interface_dmem.r_en       	  = cntrl_out_Ex_MEM[3];		
	assign mem_ntv_interface_dmem.byteenable    = byte_en;
	assign data_mem_out      			     	  			= mem_ntv_interface_dmem.rdata;

	/////////////////////////////////FETCH STAGE//////////////////////////////////////////////////
	always@(posedge clk_in or negedge rst_in)
	begin
		if (!rst_in)
				PCSrc_reg <= 1'b0;
		else PCSrc_reg <= PCSrc;
	end

	//for synchronisation of PC with Instruction(PC_out-4)
	always@(posedge clk_in or negedge rst_in)
	begin
		if (!rst_in)
				PC_out_reg <= 32'b0;
		else PC_out_reg <= PC_out;        
	end

	adder pc_adder(
									.a(PC_out			),
									.b(32'd4			),
									.c(PCout_plus4)
	);

	mux mux1 (
									.a(PCout_plus4), 
									.b(ADDSum_out	), 						
									.s(PCSrc			), 
									.c(mux_out1		)
	);

	//register_en 	#(.Default_val(32'h80000000))		PC (
	register_en 	PC (
																										.clk	(clk_in								), 
																										.reset(rst_in								),
																										.en		(PCWrite							), 
																										.d		({mux_out1[31:1],1'b0}), 
																										.q		(PC_out								)
	);

	/*memory memory (	.address_a(PC_out>>2),
							.address_b(alu_result_EX_MEM),   //alu_result>>2
							.byteena_b(byte_en),
							.clock(clk_in),
							.data_a(0),
							.data_b(rs2_out_EX_MEM), // rs2_out
							.rden_a(1'b1),
							.rden_b(cntrl_out_Ex_MEM[3]),
							.wren_a(1'b0),
							.wren_b(cntrl_out_Ex_MEM[2]),
							.q_a(inst_mem_out),
							.q_b(data_mem_out)
	);*/

	Instruction_reg inst_decoder (.instruction(inst_mem_out),
																.instruction_o(instruction_o)

	);

	//////////////////////////Decode Stage//////////////////////////////////////////////
	//-> we will register pc_out and instruction

	register_en IF_ID_pcout (
														.clk				(clk_in								), 
														.reset			(rst_in								),
														.flush			(PCSrc | PCSrc_reg		), 
														.en					(IF_Dwrite_reg				),
														.d					(PC_out_reg						),
														.q					(PC_out_IF_ID					)
	);
	register_en IF_ID_instout(
														.clk				(clk_in								), 
														.reset			(rst_in								), 
														.flush			(PCSrc | PCSrc_reg		),  
														.en					(IF_Dwrite_reg				),	
														.d					(inst_mem_out					), 
														.q					(inst_out_IF_ID				)
	);

	register_file reg_file(
														.write_data	(mux_out6							), 
														.rs1				(inst_out_IF_ID[19:15]),  
														.rs2				(inst_out_IF_ID[24:20]),   
														.rd					(inst_out_MEM_WB[11:7]),     
														.we					(cntrl_out_MEM_WB[1]	), 
														.clk				(clk_in								), 
														.rst				(rst_in								),
														.read_data1	(rs1_out							), 
														.read_data2	(rs2_out							)
	);

	Imm_Gen imm_gen				(
														.Inst_In		(inst_out_IF_ID				),			
										 				.Inst_Out		(inst_out_imm					)
	);

	control_unit control_unit(
														.Op					(inst_out_IF_ID[6:0]	),							
														.funct3			(inst_out_IF_ID[14:12]),				
														.funct7			(inst_out_IF_ID[31:25]),
														.ALUOp			(ALUOp								), 
														.ALUSrcA		(ALUSrcA							), 
														.ALUSrcB		(ALUSrcB							),
														.Branch			(Branch								),
														.RegWrite		(RegWrite							), 
														.MemtoReg		(MemtoReg							), 
														.MemRead		(MemRead							), 
														.MemWrite		(MemWrite							),
														.jal				(jal									), 
														.jalr				(jalr									),
														.valid			(valid								)
	);

	hazard_detection_unit hazard_unit(
														.ID_EX_rd		(inst_out_IF_ID[11:7]	), 
														.IF_ID_rs1	(inst_mem_out[19:15]),  
														.IF_ID_rs2	(inst_mem_out[24:20]),  
														.ID_EX_memread(MemRead						),  
														.PCWrite		(PCWrite							),  
														.IF_Dwrite	(IF_Dwrite						),  
														.hazard_out	(hazard_out						)		

	);

	always@(posedge clk_in or negedge rst_in)
	begin
		if (!rst_in)
				hazard_out_reg <= 1'b0;
		else hazard_out_reg <= hazard_out;
	end
	always@(posedge clk_in or negedge rst_in)
	begin
		if (!rst_in)
				IF_Dwrite_reg  <= 1'b0;
		else IF_Dwrite_reg <= IF_Dwrite;
	end

	mux_18 mux2 (
								.a({ALUOp[1:0], ALUSrcA[1:0], ALUSrcB[1:0], jalr, Branch[5:0], jal, MemRead, MemWrite, RegWrite, MemtoReg}), 
								.b(18'd0), 
								.s(hazard_out_reg | PCSrc), 
								.c(mux_out2)
	);

	///////////////////////////////////////execute/////////////////////////////////////
	//-> we will register, register file outputs (rs1 data and rs2 out)
	//-> we will register pc_out, controls, immediate_out and whole instruction for further use

	register ID_EX_pcout(
														.clk				(clk_in									), 
														.reset			(rst_in									),
														.flush			(PCSrc | hazard_out_reg	), 				
														.d					(PC_out_IF_ID						), 
														.q					(PC_out_ID_EX						)
	);

	register ID_EX_instout(
														.clk				(clk_in									), 
														.reset			(rst_in									), 
														.flush			(PCSrc | hazard_out_reg ), 				
														.d					(inst_out_IF_ID					),   
														.q					(inst_out_ID_EX					)
	);

	register ID_EX_imm(
														.clk				(clk_in								), 
														.reset			(rst_in								), 
														.flush			(PCSrc								), 
														.d					(inst_out_imm					), 
														.q					(imm_out_ID_EX				)
	);

	register #(18) ID_EX_controls(
														.clk				(clk_in								), 
														.reset			(rst_in								), 
														.flush			(PCSrc								), 
														.d					(mux_out2							),
														.q					(cntrl_out_ID_EX			)
	);

	register ID_EX_rs1out(
														.clk				(clk_in								), 
														.reset			(rst_in								), 
														.flush			(PCSrc								), 
														.d					(rs1_out							), 
														.q					(rs1_out_ID_EX				)
	);

	register ID_EX_rs2out(
														.clk				(clk_in								), 
														.reset			(rst_in								), 
														.flush			(PCSrc								), 
														.d					(rs2_out							), 
														.q					(rs2_out_ID_EX				)
	);

	forwarding_unit forwarding_unit_jalr(
														.rs1				(inst_out_ID_EX[19:15]), 
														//.rs2			(inst_out_ID_EX[24:20]), 
														.EX_MEM_rd	(inst_out_EX_MEM[11:7]), 
														.MEM_WB_rd	(inst_out_MEM_WB[11:7]),
														.EX_MEM_regwrite(cntrl_out_Ex_MEM[1]), 
														.MEM_WB_regwrite(cntrl_out_MEM_WB[1]),
														.forward_A	(forwardjalr) 
														//.forward_B(forwardB)
	);

	mux_3x1 jal_jalr (
														.a					(rs1_out_ID_EX				), 
														.b					(mux_out6							), // mem hazard        
														.c					(alu_result_EX_MEM		), // execute hazard
														.s					(forwardjalr					),
														.q					(mux_outjalr					)
	);


	mux mux3 (
														.a					(PC_out_ID_EX					), 
														.b					(mux_outjalr					),   
														.s					(cntrl_out_ID_EX[11]	), 
														.c					(mux_out3							)
	);

	adder ADDSum(
														.a					(mux_out3							),
														.b					(imm_out_ID_EX				),
														.c					(ADDSum_out						)
	);

	mux_3x1 muxA (
														.a					(rs1_out_ID_EX				),  
														.b					(mux_out6							), // mem hazard   
														.c					(alu_result_EX_MEM		), // execute hazard
														.s					(forwardA							), 
														.q					(mux_outA							)
	);

	mux_3x1 muxB (
														.a					(rs2_out_ID_EX				),  
														.b					(mux_out6							), // mem hazard  
														.c					(alu_result_EX_MEM		), // execute hazard
														.s					(forwardB							),  
														.q					(mux_outB							)
	);


	mux_3x1 mux4 (
														.a					(mux_outA							 	), 
														.b					(PC_out_ID_EX					 	), 
														.c					(32'd0								 	),
														.s					(cntrl_out_ID_EX[15:14]	),  //ALUSrcA
														.q					(mux_out4							 	)
	);

	mux_3x1 mux5 (
														.a					(mux_outB							 	), 
														.b					(imm_out_ID_EX				 	), 
														.c					(32'd4								 	),
														.s					(cntrl_out_ID_EX[13:12]	), //ALUSRCB
														.q					(mux_out5							 	)
	);

	forwarding_unit forwarding_unit(
														.rs1				(inst_out_ID_EX[19:15]	), 
														.rs2				(inst_out_ID_EX[24:20]	), 
														.EX_MEM_rd	(inst_out_EX_MEM[11:7]	), 
														.MEM_WB_rd	(inst_out_MEM_WB[11:7]	),
														.EX_MEM_regwrite(cntrl_out_Ex_MEM[1]), 
														.MEM_WB_regwrite(cntrl_out_MEM_WB[1]),
														.forward_A	(forwardA								), 
														.forward_B	(forwardB								)
	);

	ALUControl alu_control(
														.ALUOp			(cntrl_out_ID_EX[17:16]	), 
														.funct3			(inst_out_ID_EX[14:12]	), 
														.funct7			(inst_out_ID_EX[31:25]	),
														.OP					(inst_out_ID_EX[6:0]		),
														.ALUCtl			(alu_contrl							)
	);

	ALU alu (
														.ALUctl			(alu_contrl							), 
														.A					(mux_out4								), 
														.B					(mux_out5								), 
														.ALUOut			(alu_result							), 
														.Zero				(zero										),
														.n_zero			(nzero									),
														.less_than	(less										),
														.greater_than(greater								),
														.less_than_u(lessun									),
														.greater_than_u(greaterun						)
	);

	////data forwarding for memory////
	register data_mem_fwding(
														.clk					(clk_in								), 
														.reset				(rst_in								), 
														.d						(mux_outB							), 
														.q						(data_mem_fwd					)
	);

	assign a_n_d_1 = zero 			& cntrl_out_ID_EX[5];
	assign a_n_d_2 = nzero 			& cntrl_out_ID_EX[6];
	assign a_n_d_3 = less	    	& cntrl_out_ID_EX[7];
	assign a_n_d_4 = greater 		& cntrl_out_ID_EX[8];
	assign a_n_d_5 = lessun	    & cntrl_out_ID_EX[9];
	assign a_n_d_6 = greaterun  & cntrl_out_ID_EX[10];

	assign PCSrc = a_n_d_1 | a_n_d_2 |a_n_d_3 |a_n_d_4 |a_n_d_5 |a_n_d_6 | cntrl_out_ID_EX[11] | cntrl_out_ID_EX[4];

	///////////////////////////////////////memory/////////////////////////////////////
	//-> we will register wb and mem controls, ALU_result and rs2 out
	//   and whole instruction for further use



	register #(4) EX_MEM_controls(
														.clk				(clk_in								), 
														.reset			(rst_in								), 
														.d					(cntrl_out_ID_EX[3:0]	),
														.q					(cntrl_out_Ex_MEM			)
	);

	register EX_MEM_ALU(
														.clk				(clk_in								), 
														.reset			(rst_in								), 
														.d					(alu_result						), 
														.q					(alu_result_EX_MEM		)
	);

	register EX_MEM_rs2out(
														.clk				(clk_in								), 
														.reset			(rst_in								), 
														.d					(rs2_out_ID_EX				), 
														.q					(rs2_out_EX_MEM				)
	);

	register EX_MEM_instout(
														.clk				(clk_in								), 
														.reset			(rst_in								), 
														.d					(inst_out_ID_EX				), 
														.q					(inst_out_EX_MEM			)
	);
////////////||
//store_unit||
////////////||
	store_unit store_unit(
														.fu3					(inst_out_EX_MEM[14:12]			), 			
														.dmem_address	(alu_result_EX_MEM	[1:0]		),			
														.byte_en			(byte_en										)
	);
//
	///////////////////////////////////////writeback/////////////////////////////////////
	//-> we will register wb controls(regwrite,memtoreg), data_mem_out, alu_result_EX_MEM,
	//  and whole instruction 

	register #(2) MEM_WB_controls(
														.clk					(clk_in								), 
														.reset				(rst_in								), 
														.d						(cntrl_out_Ex_MEM[1:0]),
														.q						(cntrl_out_MEM_WB			)
	);

	register MEM_WB_datamem(
														.clk					(clk_in								), 
														.reset				(rst_in								), 
														.d						(data_mem_out					), 
														.q						(dataout_MEM_WB				)
	);

	register MEM_WB_ALU(
														.clk					(clk_in								), 
														.reset				(rst_in								), 
														.d						(alu_result_EX_MEM		), 
														.q						(alu_result_MEM_WB		)
	);

	register MEM_WB_instout(
														.clk					(clk_in								), 
														.reset				(rst_in								), 
														.d						(inst_out_EX_MEM			), 
														.q						(inst_out_MEM_WB			)
	);

	load_unit load_unit(
														.int_in_load	(data_mem_out				 ), 
														.fu3					(inst_out_MEM_WB[14:12]),
														.addr					(alu_result_MEM_WB[1:0]),
														.int_out_load	(load_store_unit_out	 )
	);

	mux mux6 (
														.a						(alu_result_MEM_WB		),  
														.b						(load_store_unit_out	),  
														.s						(cntrl_out_MEM_WB[0]	),
														.c						(mux_out6							)
	);

/*
/////////////////////////////////////////////////TRACER WORK///////////////////////////////////////////////////////////
////////////////////////////////////////////  FOR GOOGLE DV VERIFICATION ///////////////////////////
	
	//wires for tracer
	wire [31:0] rs1_out_EX_MEM, rs1_out_MEM_WB, rs2_out_MEM_WB, PC_out_EX_MEM, PC_out_MEM_WB;
	//reg	valid;
	reg valid_ie;
	reg valid_dmem;
	reg valid_wback;
	//registers for tracer

	register EX_MEM_rs1out(.clk(clk_in), 
								.reset(rst_in), 
								.d(rs1_out_ID_EX), 
								.q(rs1_out_EX_MEM)
	);

	register MEM_WB_rs1out(.clk(clk_in), 
								.reset(rst_in), 
								.d(rs1_out_EX_MEM), 
								.q(rs1_out_MEM_WB)
	);

	register MEM_WB_rs2out(.clk(clk_in), 
								.reset(rst_in), 
								.d(rs2_out_EX_MEM), 
								.q(rs2_out_MEM_WB)
	);

	register EX_MEM_pcout(.clk(clk_in), 
												.reset(rst_in),
												.d(PC_out_ID_EX), 
												.q(PC_out_EX_MEM)
	);
	register MEM_WB_pcout(.clk(clk_in), 
												.reset(rst_in),
												.d(PC_out_EX_MEM), 
												.q(PC_out_MEM_WB)
	);
	always @ (posedge clk_in , negedge rst_in)
	begin
		if (!rst_in)
		begin
			valid_ie<=0;
			valid_dmem<=0;
			valid_wback<=0;
		end
		else
		begin
			valid_ie<=valid;
			valid_dmem<=valid_ie;
			valid_wback<=valid_dmem;
		end

	end


	//tracer instantiated 
		tracer tracer_inst(
						.clk_i(clk_in),
						.rst_ni(rst_in),
						.hart_id_i(0),
						.rvfi_valid(valid_wback),
							.rvfi_insn_t(inst_out_MEM_WB),
							.rvfi_rs1_addr_t(inst_out_MEM_WB[19:15]),
							.rvfi_rs2_addr_t(inst_out_MEM_WB[24:20]),
							.rvfi_rs3_addr_t(),
							.rvfi_rs1_rdata_t(rs1_out_MEM_WB),
							.rvfi_rs2_rdata_t(rs2_out_MEM_WB),
							.rvfi_rs3_rdata_t(),
							.rvfi_rd_addr_t(inst_out_MEM_WB[11:7]),
							.rvfi_rd_wdata_t(mux_out6),
							.rvfi_pc_rdata_t(PC_out_MEM_WB),
							.rvfi_pc_wdata_t(PC_out_reg),//PC_out_reg
							.rvfi_mem_addr(alu_result_MEM_WB),
							.rvfi_mem_rmask(),
							.rvfi_mem_wmask(),
							.rvfi_mem_rdata(dataout_MEM_WB),
							.rvfi_mem_wdata(rs2_out_MEM_WB)
		);
*/
	endmodule
