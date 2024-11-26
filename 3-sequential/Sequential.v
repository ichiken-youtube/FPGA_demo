module Sequential(
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
	reg [7:0] stage1p, stage1c, stage2;
	reg [19:0] counter;  // デバウンス用のカウンタ
	reg btn_sync_0, btn_sync_1; // シンクロナイザレジスタ
	reg push_clk;   // デバウンス後のボタン出力
	reg seqFlag;
	reg [2:0]opA,opB,opC;
	assign LED[2:0]=opA;
	assign LED[5:3]=opB;
	assign LED[8:6]=opC;
	
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

	always @(SW[8:0])begin
		if(seqFlag==0)begin
			opA<=SW[2:0];
			opB<=SW[5:3];
			opC<=SW[8:6];
		end
	end
	
	always @(posedge push_clk or negedge rst) begin
		if(rst == 0)begin
			stage1p <= 0;
			stage1c <= 0;
			stage2 <= 0;
			seqFlag  <= 0;
		end else begin
			case(seqFlag)
				2'b00:begin
					stage1p <= opA+opB;
					stage1c <= opC;
					seqFlag <= 2'b01;
				end
				2'b01:begin
					stage2 <= stage1p + stage1c;
					seqFlag <= 2'b00;
				end
				default:seqFlag <= 2'b00;
			endcase
		end
		
	end

	bin_to_7seg_2digit digit1(opA, HEX0);
	bin_to_7seg_2digit digit2(opB, HEX1);
	bin_to_7seg_2digit digit3(opC, HEX2);
	
	bin_to_7seg_2digit digit4(stage1p, HEX3);
	bin_to_7seg_2digit digit5(stage1c, HEX4);
	bin_to_7seg_2digit digit6(stage2,  HEX5);
endmodule


module bin_to_7seg_2digit(
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