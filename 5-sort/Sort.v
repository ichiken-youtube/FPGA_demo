module Sort#(
	parameter WIDTH = 8,
	parameter N = 16

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
	output wire [7:0] HEX5,
	
	output wire [1:0]GPIO
	);

	reg [WIDTH-1:0] data_in[0:N-1];
	wire [WIDTH-1:0] data_out[0:N-1];

	reg [19:0] counter;  // デバウンス用のカウンタ
	reg btn_sync_0, btn_sync_1; // シンクロナイザレジスタ
	wire push_clk;   // デバウンス後のボタン出力
	
	wire end_sig;
	//reg end_flag;
	
	assign GPIO[0] = end_sig;
	assign GPIO[1] = push_clk;
	
	always @(negedge rst) begin
		data_in[0]  = 8'b00001001;
		data_in[1]  = 8'b00000001;
		data_in[2]  = 8'b00000101;
		data_in[3]  = 8'b00000010;
		data_in[4]  = 8'b00000011;
		data_in[5]  = 8'b00000100;
		data_in[6]  = 8'b00000110;
		data_in[7]  = 8'b00000111;
		data_in[8]  = 8'b00000000;
		data_in[9]  = 8'b00001000;
		data_in[10] = 8'b00001010;
		data_in[11] = 8'b00001100;
		data_in[12] = 8'b00001011;
		data_in[13] = 8'b00001101;
		data_in[14] = 8'b00001111;
		data_in[15] = 8'b00001110;
	end
	
    // ボタンのシンクロナイズ（非同期入力を同期化）
	always @(posedge clk) begin
		btn_sync_0 <= key1;
		btn_sync_1 <= btn_sync_0;
	end

	// デバウンス処理
	always @(posedge clk) begin
		if (btn_sync_1 == 0) begin
			counter <= 0;
			push_clk <= 0;
		end else if (counter == 20'hFFFFF) begin
			push_clk <= 1;
		end else begin
			counter <= counter + 1;
		end
	end

	
	/*always @(posedge clk) begin
		end_sig <= end_flag;
	end*/
	
	bitonicSorter bs(push_clk, rst, end_sig, data_in, data_out);
	
	bin_to_7seg digit1(data_out[0], HEX0);
	bin_to_7seg digit2(data_out[1], HEX1);
	bin_to_7seg digit3(data_out[2], HEX2);
	bin_to_7seg digit4(data_out[3], HEX3);
	bin_to_7seg digit5(data_out[4], HEX4);
	bin_to_7seg digit6(data_out[5], HEX5);
	
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

module bitonicSorter#(
	parameter WIDTH = 8,
	parameter N = 16

)(
	input clk, 
	input rst,
	output end_sig,
	input [WIDTH-1:0] data_in [0:N-1],  // ソート前のデータ
	output [WIDTH-1:0] data_out [0:N-1] // ソート後のデータ
);

	reg [WIDTH-1:0] temp [0:N-1]; // ソート後のデータ
	reg [WIDTH-1:0]i,j,k,l;
	reg end_flag;
	
	assign end_sig = end_flag;

	// 内部ワイヤを生成する
	genvar  h;
	
	generate
		for (h = 0; h < N; h = h + 1) begin : result
			assign data_out[h][WIDTH-1:0] = temp[h][WIDTH-1:0];	
		end
	endgenerate
	
	integer m ;
	always @(posedge clk or negedge rst) begin
		reg [WIDTH-1:0] swap; 
		
		if (rst == 0) begin
			for (m = 0; m < N; m = m + 1) begin
				temp[m] <= data_in[m];
			end
			end_flag = 0;
		end else begin
			for (k = 2; k <= N; k = (k << 1)) begin : stage
				for (j = (k >> 1); j > 0; j = (j >> 1)) begin : sub_stage
					for (i = 0; i < N; i = i + 1) begin : compare_exchange
						l = i ^ j;
						swap[WIDTH-1:0] = temp[i];
						if (l > i) begin
							if (((i & k) == 0 && (temp[i] > temp[l])) || ((i & k) != 0 && temp[i] < temp[l])) begin
								//temp[i] <= temp[l];
								//temp[l] <= temp[i];
								temp[i] = temp[l];
								temp[l] = swap;
							end
						end			
					end
				end
			end
			end_flag = 1;	
		end
	end

	
endmodule