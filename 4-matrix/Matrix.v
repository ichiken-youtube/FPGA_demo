module Matrix#(
	parameter WIDTH = 8

)(
	input wire clk,
	input wire rst,
	input wire key1,
	input wire [9:0]SW,
	output wire [9:0]LED,
	
	output wire [7:0] HEX0,
	output wire [7:0] HEX1,
	output wire [7:0] HEX2,
	output wire [7:0] HEX3,
	output wire [7:0] HEX4,
	output wire [7:0] HEX5
	
	);

	reg [WIDTH-1:0] matA[0:1][0:1];
	reg [WIDTH-1:0] matB[0:1][0:1];
	reg [WIDTH-1:0] result[0:1][0:1];

	
	always @(*) begin
	
		result[0][0] <= matA[0][0]*matB[0][0] + matA[0][1]*matB[1][0];
		result[0][1] <= matA[0][0]*matB[0][1] + matA[0][1]*matB[1][1];
		result[1][0] <= matA[1][0]*matB[0][0] + matA[1][1]*matB[1][0];
		result[1][1] <= matA[1][0]*matB[0][1] + matA[1][1]*matB[1][1];
		
	end
	

	always @(negedge key1 or negedge rst) begin
		integer i,j;
		if (rst == 0) begin
			matA[0][0] <= 4;
			matA[0][1] <= 5;
			matA[1][0] <= 2;
			matA[1][1] <= 6;
			//[4,5]
			//[2,6]
			
				
		
			matB[0][0] <= 1;
			matB[0][1] <= 0;
			matB[1][0] <= 0;
			matB[1][1] <= 1;
			//単位行列
			
		end else begin 
			
			
			matB[0][0] <= 1;
			matB[0][1] <= 3;
			matB[1][0] <= 7;
			matB[1][1] <= 2;
			//[1,3]
			//[7,2]

		end

	end


	bin_to_7seg digit1(result[1][1], HEX0);
	bin_to_7seg digit2(result[1][0], HEX1);
	bin_to_7seg digit3(result[0][1], HEX2);
	bin_to_7seg digit4(result[0][0], HEX3);
	
endmodule


module bin_to_7seg(
	input wire [7:0] bin,         // 8ビットの2進数入力（0〜255の範囲）
	output reg [7:0] seg   // 7セグの最下位桁（1の位）
);

    reg [3:0] digit; // mod10繰り上がり無し

    // 2進数を10進数に変換
    always @(bin) begin
        digit = bin % 10;
    end

 // 10進数を7セグメント表示に変換する関数
   function [7:0] digit_to_7seg;
        input [3:0] digit;
        case (digit)
            4'd0: digit_to_7seg = 8'b11000000; // 0
            4'd1: digit_to_7seg = 8'b11111001; // 1
            4'd2: digit_to_7seg = 8'b10100100; // 2
            4'd3: digit_to_7seg = 8'b10110000; // 3
            4'd4: digit_to_7seg = 8'b10011001; // 4
            4'd5: digit_to_7seg = 8'b10010010; // 5
            4'd6: digit_to_7seg = 8'b10000010; // 6
            4'd7: digit_to_7seg = 8'b11111000; // 7
            4'd8: digit_to_7seg = 8'b10000000; // 8
            4'd9: digit_to_7seg = 8'b10010000; // 9
            default: digit_to_7seg = 8'b11111111; // 非表示
        endcase
    endfunction

    // 各桁を7セグメントに変換して出力
    always @(digit) begin
        seg = digit_to_7seg(digit);
    end
endmodule

