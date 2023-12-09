import risc_v_core_pkg::*;

module soc_top(
				input logic clk,
				input logic rst
);

mem_ntv_interface_if		mem_ntv_interface_imem();
mem_ntv_interface_if		mem_ntv_interface_dmem();

RISCV32I rv32_inst(			
							.clk_in									(clk												),
							.rst_in									(rst												),
							.mem_ntv_interface_imem	(mem_ntv_interface_imem.core),
							.mem_ntv_interface_dmem	(mem_ntv_interface_dmem.core)
);							

mem mem_inst(	
							.address_a							(mem_ntv_interface_imem.addr>>2		),
							.address_b							(mem_ntv_interface_dmem.addr>>2		),
							.byteena_b							(mem_ntv_interface_dmem.byteenable),
							.byteena_a							(1'b0															),
							.clock_a								(clk															),
							.clock_b								(clk															),
							.data_a									(0																),
							.data_b									(mem_ntv_interface_dmem.wdata			),
							.enable_a								(mem_ntv_interface_imem.r_en			), //1'b1
							.enable_b								( mem_ntv_interface_dmem.r_en			),
							.wren_a									(1'b0															),
							.wren_b									( mem_ntv_interface_dmem.w_en			),
							.q_a										(mem_ntv_interface_imem.rdata			),
							.q_b										(mem_ntv_interface_dmem.rdata			)
	
);


logic uart_en;
assign	uart_en	=	mem_ntv_interface_dmem.addr == 32'h800000 & mem_ntv_interface_dmem.w_en == 1;

always@(*)
begin
	if(uart_en)
			$write("%c",mem_ntv_interface_dmem.wdata[7:0]);
end

endmodule
					

