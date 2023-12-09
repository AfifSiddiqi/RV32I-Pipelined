onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/dut/rv32_inst/clk_in
add wave -noupdate /testbench/dut/rv32_inst/rst_in
add wave -noupdate /testbench/dut/rv32_inst/PCWrite
add wave -noupdate -radix decimal /testbench/dut/rv32_inst/PC_out
add wave -noupdate -radix hexadecimal /testbench/dut/rv32_inst/PC_out_reg
add wave -noupdate -divider Instruction_stages
add wave -noupdate /testbench/dut/rv32_inst/inst_decoder/instruction_o
add wave -noupdate /testbench/dut/rv32_inst/inst_decoder/instruction_o.opcode
add wave -noupdate -radix hexadecimal /testbench/dut/rv32_inst/inst_mem_out
add wave -noupdate -radix hexadecimal /testbench/dut/rv32_inst/inst_out_IF_ID
add wave -noupdate -radix hexadecimal /testbench/dut/rv32_inst/inst_out_ID_EX
add wave -noupdate -radix hexadecimal /testbench/dut/rv32_inst/inst_out_EX_MEM
add wave -noupdate -radix hexadecimal /testbench/dut/rv32_inst/inst_out_MEM_WB
add wave -noupdate -divider data_memory
add wave -noupdate -radix hexadecimal /testbench/dut/rv32_inst/mem_ntv_interface_dmem/addr
add wave -noupdate -radix hexadecimal /testbench/dut/rv32_inst/mem_ntv_interface_dmem/wdata
add wave -noupdate -radix hexadecimal /testbench/dut/rv32_inst/mem_ntv_interface_dmem/rdata
add wave -noupdate /testbench/dut/rv32_inst/mem_ntv_interface_dmem/w_en
add wave -noupdate /testbench/dut/rv32_inst/mem_ntv_interface_dmem/r_en
add wave -noupdate -radix binary /testbench/dut/rv32_inst/mem_ntv_interface_dmem/byteenable
add wave -noupdate -divider Store_Unit
add wave -noupdate /testbench/dut/rv32_inst/store_unit/fu3
add wave -noupdate -radix binary /testbench/dut/rv32_inst/store_unit/dmem_address
add wave -noupdate -radix binary /testbench/dut/rv32_inst/store_unit/byte_en
add wave -noupdate -divider Load_unit
add wave -noupdate -radix hexadecimal /testbench/dut/rv32_inst/load_unit/int_in_load
add wave -noupdate /testbench/dut/rv32_inst/load_unit/fu3
add wave -noupdate /testbench/dut/rv32_inst/load_unit/addr
add wave -noupdate -radix hexadecimal /testbench/dut/rv32_inst/load_unit/int_out_load
add wave -noupdate -divider register_file
add wave -noupdate /testbench/dut/rv32_inst/reg_file/we
add wave -noupdate -radix decimal /testbench/dut/rv32_inst/reg_file/write_data
add wave -noupdate -radix hexadecimal /testbench/dut/rv32_inst/reg_file/ram
add wave -noupdate -radix unsigned /testbench/dut/rv32_inst/reg_file/rs1
add wave -noupdate -radix unsigned /testbench/dut/rv32_inst/reg_file/rs2
add wave -noupdate -radix unsigned /testbench/dut/rv32_inst/reg_file/rd
add wave -noupdate -radix unsigned /testbench/dut/rv32_inst/rs1_out
add wave -noupdate -radix unsigned /testbench/dut/rv32_inst/rs2_out
add wave -noupdate -radix unsigned /testbench/dut/rv32_inst/inst_out_imm
add wave -noupdate -divider ALU
add wave -noupdate -radix hexadecimal /testbench/dut/rv32_inst/alu/A
add wave -noupdate -radix hexadecimal /testbench/dut/rv32_inst/alu/B
add wave -noupdate -radix hexadecimal /testbench/dut/rv32_inst/alu/ALUOut
add wave -noupdate /testbench/dut/rv32_inst/alu/ALUctl
add wave -noupdate -divider Hazard_unit
add wave -noupdate -radix unsigned /testbench/dut/rv32_inst/hazard_unit/ID_EX_rd
add wave -noupdate -radix unsigned /testbench/dut/rv32_inst/hazard_unit/IF_ID_rs1
add wave -noupdate -radix unsigned /testbench/dut/rv32_inst/hazard_unit/IF_ID_rs2
add wave -noupdate /testbench/dut/rv32_inst/hazard_unit/ID_EX_memread
add wave -noupdate /testbench/dut/rv32_inst/hazard_unit/PCWrite
add wave -noupdate /testbench/dut/rv32_inst/hazard_unit/IF_Dwrite
add wave -noupdate /testbench/dut/rv32_inst/hazard_unit/hazard_out
add wave -noupdate /testbench/dut/rv32_inst/PCSrc
add wave -noupdate /testbench/dut/rv32_inst/PCSrc_reg
add wave -noupdate -radix unsigned /testbench/dut/rv32_inst/ADDSum_out
add wave -noupdate /testbench/dut/mem_inst/address_a
add wave -noupdate /testbench/dut/mem_inst/address_b
add wave -noupdate /testbench/dut/mem_inst/byteena_a
add wave -noupdate /testbench/dut/mem_inst/byteena_b
add wave -noupdate /testbench/dut/mem_inst/clock_a
add wave -noupdate /testbench/dut/mem_inst/clock_b
add wave -noupdate /testbench/dut/mem_inst/data_a
add wave -noupdate /testbench/dut/mem_inst/data_b
add wave -noupdate /testbench/dut/mem_inst/enable_a
add wave -noupdate /testbench/dut/mem_inst/enable_b
add wave -noupdate /testbench/dut/mem_inst/wren_a
add wave -noupdate /testbench/dut/mem_inst/wren_b
add wave -noupdate /testbench/dut/mem_inst/q_a
add wave -noupdate /testbench/dut/mem_inst/q_b
add wave -noupdate /testbench/dut/mem_inst/i
add wave -noupdate /testbench/dut/dmem_en
add wave -noupdate /testbench/dut/rv32_inst/ADDSum/a
add wave -noupdate /testbench/dut/rv32_inst/ADDSum/b
add wave -noupdate /testbench/dut/rv32_inst/ADDSum/c
add wave -noupdate -divider Uart
add wave -noupdate -radix hexadecimal /testbench/dut/mem_ntv_interface_dmem/addr
add wave -noupdate /testbench/dut/we
add wave -noupdate /testbench/dut/uart_en
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {9050 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 277
configure wave -valuecolwidth 94
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {8570 ps} {8756 ps}
