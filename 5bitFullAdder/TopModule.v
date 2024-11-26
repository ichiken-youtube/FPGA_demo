module TopModule(
	input [9:0]SW,
	output [9:0]LED 
	);
	
	wire [5:1]wC; 


	fullAdder fa1(SW[0], SW[5], 0, wC[1], LED[0]);
	fullAdder fa2(SW[1], SW[6], wC[1], wC[2], LED[1]);
	fullAdder fa3(SW[2], SW[7], wC[2], wC[3], LED[2]);
	fullAdder fa4(SW[3], SW[8], wC[3], wC[4], LED[3]);
	fullAdder fa5(SW[4], SW[9], wC[4], LED[5], LED[4]);
endmodule


module fullAdder(input a, input b, input cin, output co, output sum);
	wire wHA1s, wHA1c, wHA2c;

	halfAdder ha1(a, b, wHA1c, wHA1s);
	halfAdder ha2(wHA1s, cin, wHA2c, sum);
   orModule or1(wHA1c, wHA2c, co);
endmodule


module halfAdder(input a, input b, output co, output sum);
    xorModule u1(a, b, sum);
    andModule u2(a, b, co);
endmodule


module andModule(input a, input b, output q);
	assign q = a & b;
endmodule


module xorModule(input a, input b, output q);
	assign q = a ^ b;
endmodule


module orModule(input a, input b, output q);
	assign q = a | b;
endmodule