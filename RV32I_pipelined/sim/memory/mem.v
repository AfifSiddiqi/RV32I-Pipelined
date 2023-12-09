module mem (
	address_a,
	address_b,
	byteena_a,
	byteena_b,
	clock_a,
	clock_b,
	data_a,
	data_b,
	enable_a,
	enable_b,
	wren_a,
	wren_b,
	q_a,
	q_b);

	input	[16:0]  address_a;
	input	[16:0]  address_b;
	input	[3:0]  byteena_a;
	input	[3:0]  byteena_b;
	input	  clock_a;
	input	  clock_b;
	input	[31:0]  data_a;
	input	[31:0]  data_b;
	input	  enable_a;
	input	  enable_b;
	input	  wren_a;
	input	  wren_b;
	output	reg[31:0]  q_a;
	output	reg[31:0]  q_b;


	reg [31:0] mem[0:65535];
	integer i;
	initial begin
	for(i = 0; i < 65536; i=i+1)
		mem[i] = 0;
	$readmemh("mem.txt", mem);
	end

	always@(posedge clock_a)
	begin	
		if(enable_a)
		begin
		q_a <= mem[address_a];
			if(wren_a) begin
				if(byteena_a[0]) mem[address_a][7:0]   <= data_a[7:0];
				if(byteena_a[1]) mem[address_a][15:8]  <= data_a[15:8];
				if(byteena_a[2]) mem[address_a][23:16] <= data_a[23:16];
				if(byteena_a[3]) mem[address_a][31:24] <= data_a[31:24];
			end
		end
	end
	always@(posedge clock_b)
	begin	
		if(enable_b)
		q_b <= mem[address_b];
		else if(wren_b) begin
				case(byteena_b)
				4'b0001 : begin
									if(byteena_b[0]) mem[address_b][7:0]   <= data_b[7:0];
											else mem[address_b][7:0] <=mem[address_b][7:0];
									if(byteena_b[1]) mem[address_b][15:8]  <= data_b[7:0];
											else mem[address_b][15:8] <=mem[address_b][15:8];
									if(byteena_b[2]) mem[address_b][23:16] <= data_b[7:0];
											else mem[address_b][23:16] <=mem[address_b][23:16];
									if(byteena_b[3]) mem[address_b][31:24] <= data_b[7:0];
											else mem[address_b][31:24] <=mem[address_b][31:24];
									end
				4'b0010 : begin
									if(byteena_b[0]) mem[address_b][7:0]   <= data_b[7:0];
											else mem[address_b][7:0] <=mem[address_b][7:0];
									if(byteena_b[1]) mem[address_b][15:8]  <= data_b[7:0];
											else mem[address_b][15:8] <=mem[address_b][15:8];
									if(byteena_b[2]) mem[address_b][23:16] <= data_b[7:0];
											else mem[address_b][23:16] <=mem[address_b][23:16];
									if(byteena_b[3]) mem[address_b][31:24] <= data_b[7:0];
											else mem[address_b][31:24] <=mem[address_b][31:24];
									end
				4'b0100 : begin
									if(byteena_b[0]) mem[address_b][7:0]   <= data_b[7:0];
											else mem[address_b][7:0] <=mem[address_b][7:0];
									if(byteena_b[1]) mem[address_b][15:8]  <= data_b[7:0];
											else mem[address_b][15:8] <=mem[address_b][15:8];
									if(byteena_b[2]) mem[address_b][23:16] <= data_b[7:0];
											else mem[address_b][23:16] <=mem[address_b][23:16];
									if(byteena_b[3]) mem[address_b][31:24] <= data_b[7:0];
											else mem[address_b][31:24] <=mem[address_b][31:24];
									end
				4'b1000 : begin
									if(byteena_b[0]) mem[address_b][7:0]   <= data_b[7:0];
											else mem[address_b][7:0] <=mem[address_b][7:0];
									if(byteena_b[1]) mem[address_b][15:8]  <= data_b[7:0];
											else mem[address_b][15:8] <=mem[address_b][15:8];
									if(byteena_b[2]) mem[address_b][23:16] <= data_b[7:0];
											else mem[address_b][23:16] <=mem[address_b][23:16];
									if(byteena_b[3]) mem[address_b][31:24] <= data_b[7:0];
											else mem[address_b][31:24] <=mem[address_b][31:24];
									end	
				
				4'b0011 : begin
									if(byteena_b[0]) mem[address_b][7:0]   <= data_b[7:0];
											else mem[address_b][7:0] <=mem[address_b][7:0];
									if(byteena_b[1]) mem[address_b][15:8]  <= data_b[15:8];
											else mem[address_b][15:8] <=mem[address_b][15:8];
									if(byteena_b[2]) mem[address_b][23:16] <= data_b[7:0];
											else mem[address_b][23:16] <=mem[address_b][23:16];
									if(byteena_b[3]) mem[address_b][31:24] <= data_b[15:8];
											else mem[address_b][31:24] <=mem[address_b][31:24];
									end
				4'b1100 : begin
									if(byteena_b[0]) mem[address_b][7:0]   <= data_b[7:0];
											else mem[address_b][7:0] <=mem[address_b][7:0];
									if(byteena_b[1]) mem[address_b][15:8]  <= data_b[15:8];
											else mem[address_b][15:8] <=mem[address_b][15:8];
									if(byteena_b[2]) mem[address_b][23:16] <= data_b[7:0];
											else mem[address_b][23:16] <=mem[address_b][23:16];
									if(byteena_b[3]) mem[address_b][31:24] <= data_b[15:8];
											else mem[address_b][31:24] <=mem[address_b][31:24];
									end		

				4'b1111	:			mem[address_b][31:0] <= data_b[31:0];

				default	:			mem[address_b][31:0] <= data_b[31:0];
				endcase	
		end
		else
		begin
			q_b<=q_b;
			mem[address_b]<=mem[address_b];
		end
		end
endmodule
