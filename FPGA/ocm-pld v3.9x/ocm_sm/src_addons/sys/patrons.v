`timescale 1ns / 1ps
`default_nettype none
/*
 * This modules returns the value of the pixel to be displayied
 * at coordinate (x, y) allowing to select when get as source
 * the text.
 *
 * Each letter is a matrix of 8x16 pixels, we want to cover at least the
 * first 127 ASCII character, so we need at least 128*128 = 16384 bits
 *
 * 640x480 will give us 40x30 characters (the width is doubled), so the TEXT buffer needs 1200 bytes
 *
 */
 
module patrons(
	input wire clk,
	input wire hs_i,
	input wire vs_i,
	input wire text_mode,
	output wire [2:0] pixel_out,
	input wire double_width,
	input wire double_height,
	input wire [1:0] rotate, //[0] - rotate [1] - left or right
	
	input wire signed [11:0] ADJ_X,
   input wire signed [11:0] ADJ_Y,
	
	input wire [9:0] dsp_width,
	input wire [9:0] dsp_height
);

parameter OSD_AUTO_CE  = 1'b1;

reg auto_ce_pix;
always @(posedge clk) begin : b1
	integer cnt = 0;
	integer pixsz, pixcnt;
	reg hs;

	cnt <= cnt + 1;
	hs <= hs_i;

	pixcnt <= pixcnt + 1;
	if(pixcnt == pixsz) pixcnt <= 0;
	auto_ce_pix <= !pixcnt;

	if(hs && ~hs_i) begin
		cnt    <= 0;
		if (cnt <= 512) pixsz <= 0;
		else pixsz  <= (cnt >> 9) - 1;
		pixcnt <= 0;
		auto_ce_pix <= 1;
	end
end

wire ce_pix = auto_ce_pix; //OSD_AUTO_CE ? auto_ce_pix : ce;


reg signed [13:0] x = 12'd1;
reg signed [13:0] y = 12'd0;

wire blank;

reg signed [12:0] cnt_x = 12'd0;
reg signed [12:0] cnt_y = 12'd0;

wire [7:0] num_rows;

wire  [6:0] column;        // 40 columns
wire  [7:0] row;           // 30 rows
wire [11:0] text_address;
wire  [7:0] text_value;    // character to display

wire wea;
wire dina;

reg  [2:0] glyph_x;      
reg  [3:0] glyph_y;       
wire [13:0] glyph_address; 
 
reg  [2:0] g_x;       // coordinates
reg  [3:0] g_y;       // in the grid 


assign column = rotate[1] && double_height ? num_rows-y[11:4] : rotate[1] ? num_rows-y[8:4] : rotate[0] && double_height ?                        y[8:4] : rotate[0] && double_width ?            y[8:4] : rotate[0] ?            y[8:3] : double_height ? x[ 9:4] : double_width ? x[9:4] : x[9:3];
assign row    = rotate[1] && double_height ?          x[11:5] : rotate[1] ?          x[9:4] : rotate[0] && double_height ?  (num_rows/* *2 */) - x[11:5] : rotate[0] && double_width ? num_rows - x[9:4] : rotate[0] ? num_rows - x[9:4] : double_height ? y[10:5] :                         y[9:4];
assign text_address = column + (row * 40);

assign blank = (rotate[1] || rotate[0]) ? (column > 29 || row > num_rows-2) : (column > 39 || row > num_rows-2);


patrons_list patrons_list(
  .clk(clk), // input clka
  .addr(text_address), // input [11 : 0] addra
  .data(text_value), // output [7 : 0] douta
  .lines(num_rows)
);

reg old_hs, porch;

always @(posedge clk) 
begin

	old_hs <= hs_i;

	if (hs_i == 0 && old_hs == 1) //falling edge HS
	begin
		cnt_x = 12'd0;
		
		if (vs_i == 0)
			cnt_y = 12'd0;
		else
			cnt_y = cnt_y + 1;
			
	end
	else
		cnt_x = cnt_x + 1;


			x = cnt_x + ADJ_X;
			y = cnt_y + ADJ_Y;
			
	if (x < 0)
		x = 0;
	else
	  x = cnt_x + ADJ_X;
		
		
	//porch <= 1'b0;//(cnt_x<100 || cnt_x>200) ? 1'b1 : 1'b0;
	porch <= 1'b0; //(cnt_x < 30 || cnt_x > dsp_width) ? 1'b1 : 1'b0;
		
end


always @(posedge clk) begin
	glyph_x <= rotate[1] && double_height ? y[4:1] : rotate[1] ? y[4:1] : rotate[0] && double_height ?    y[4:1] : rotate[0] && double_width ? y[4:1] : rotate[0] ?    y[4:0] : double_height ? x[3:1] : double_width ? x[3:1] : x[2:0] ; 
	glyph_y <= rotate[1] && double_height ? x[4:1] : rotate[1] ? x[3:0] : rotate[0] && double_height ? 16-x[4:1] :                                      rotate[0] ? 16-x[3:0] : double_height ? y[4:1] : y[3:0]; //3:0

	//delay an extra clock cycle
	g_x <= glyph_x;
	g_y <= glyph_y;
end
                     // text_value * (8*16) + glyph_x + (glyph_y * 8)
assign glyph_address = rotate[1] ? (text_value << 7) - (g_x + 1 ) + ((g_y + 1) << 3)  : rotate[0] ? (text_value << 7) + g_x + (g_y << 3)  : (text_value << 7) + g_x + (g_y << 3);

wire pixel;

vga_font glyph_rom(
  .clk(clk), // input clka
  .addr(glyph_address), // input [13 : 0] addra
  .data(pixel) // output [0 : 0] douta

);

reg px_buff;
always @(posedge clk) begin
	if(ce_pix) begin
		px_buff <= pixel;
	end
end


assign pixel_out[2] = (!blank & !porch) ? pixel : 0;
assign pixel_out[1] = (!blank & !porch) ? pixel : 0;
assign pixel_out[0] = (!blank & !porch) ? pixel : 0;



endmodule
