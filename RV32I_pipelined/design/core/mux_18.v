module mux_18 (input[17:0]a,b,input s, output [17:0] c);

assign c = (s) ? b : a ;

endmodule