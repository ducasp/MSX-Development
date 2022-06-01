// A video pipeline for MiST. Just insert between the core video output and the VGA pins
// Provides an optional scandoubler, a rotateable OSD and (optional) RGb->YPbPr conversion

module mist_video
(
    // master clock
    // it should be 4x (or 2x) pixel clock for the scandoubler
    input wire       clk_sys,

    // OSD SPI interface
    input wire       SPI_SCK,
    input wire       SPI_SS3,
    input wire       SPI_DI,

    // scanlines (00-none 01-25% 10-50% 11-75%)
    input wire [1:0] scanlines,

    // non-scandoubled pixel clock divider 0 - clk_sys/4, 1 - clk_sys/2
    input wire       ce_divider,

    // 0 = HVSync 31KHz, 1 = CSync 15KHz
    input wire       scandoubler_disable,

    // 0 = Csync for 15khz, 1 = separated VS and HS for 15khz (doesn't matter on 31khz)
    input wire       no_csync,

    // Rotate OSD [0] - rotate [1] - left or right
    input wire [1:0] rotate,
    // composite-like blending
    input wire       blend,

    //show patrons list
    input wire       patrons,
    input wire signed [11:0] PATRON_ADJ_X,
    input wire signed [11:0] PATRON_ADJ_Y,
    input wire PATRON_DOUBLE_WIDTH,
    input wire PATRON_DOUBLE_HEIGHT,
    input wire signed [11:0] PATRON_SCROLL,
        
    // video in
    input wire [COLOR_DEPTH-1:0] R,
    input wire [COLOR_DEPTH-1:0] G,
    input wire [COLOR_DEPTH-1:0] B,

    input wire       HSync,
    input wire       VSync,

    // MiST video output signals
    output wire [4:0] VGA_R,
    output wire [4:0] VGA_G,
    output wire [4:0] VGA_B,
    output wire      VGA_VS,
    output wire      VGA_HS,
    output wire osd_enable
    
);

parameter OSD_COLOR    = 3'd1;
parameter OSD_X_OFFSET = 10'd0;
parameter OSD_Y_OFFSET = 10'd0;
parameter SD_HCNT_WIDTH = 9;
parameter COLOR_DEPTH = 6; // 1-6
parameter OSD_AUTO_CE = 1'b1;
parameter USE_FRAMEBUFFER = 1'b0;


wire [5:0] SD_R_O;
wire [5:0] SD_G_O;
wire [5:0] SD_B_O;
wire       SD_HS_O;
wire       SD_VS_O;

wire [5:0] SL_R_O;
wire [5:0] SL_G_O;
wire [5:0] SL_B_O;

reg  [5:0] R_full;
reg  [5:0] G_full;
reg  [5:0] B_full;

always @(*) begin
    if (COLOR_DEPTH == 6) begin
        R_full = R;
        G_full = G;
        B_full = B;
    end else if (COLOR_DEPTH == 2) begin
        R_full = {3{R}};
        G_full = {3{G}};
        B_full = {3{B}};
    end else if (COLOR_DEPTH == 1) begin
        R_full = {6{R}};
        G_full = {6{G}};
        B_full = {6{B}};
    end else begin
        R_full = { R, R[COLOR_DEPTH-1 -:(6-COLOR_DEPTH)] };
        G_full = { G, G[COLOR_DEPTH-1 -:(6-COLOR_DEPTH)] };
        B_full = { B, B[COLOR_DEPTH-1 -:(6-COLOR_DEPTH)] };
    end
end

reg [1:0] i_div;
reg ce_x1, ce_x2;

always @(posedge clk_sys) begin : b1
    reg last_hs_in;
    last_hs_in <= HSync;
    if(last_hs_in & !HSync) begin
        i_div <= 2'b00;
    end else begin
        i_div <= i_div + 2'd1;
    end
end

always @(*) begin : b2
    if (!ce_divider) begin
        ce_x1 = (i_div == 2'b01);
        ce_x2 = i_div[0];
    end else begin
        ce_x1 = i_div[0];
        ce_x2 = 1'b1;
    end
end

scandoubler #(SD_HCNT_WIDTH, COLOR_DEPTH) scandoubler
(
    .clk_sys    ( clk_sys    ),
    .scandoubler_disable ( scandoubler_disable | USE_FRAMEBUFFER ),
    .scanlines  ( 2'b00      ),
    .ce_x1      ( ce_x1      ),
    .ce_x2      ( ce_x2      ),
    .hs_in      ( HSync      ),
    .vs_in      ( VSync      ),
    .r_in       ( R          ),
    .g_in       ( G          ),
    .b_in       ( B          ),
    .SD_hs_o    ( SD_HS_O    ),
    .SD_vs_o    ( SD_VS_O    ),
    .SD_r_o     ( SD_R_O     ),
    .SD_g_o     ( SD_G_O     ),
    .SD_b_o     ( SD_B_O     )
);
/*
assign VGA_R  = SD_R_O[5:1];
assign VGA_G  = SD_G_O[5:1];
assign VGA_B  = SD_B_O[5:1];
assign VGA_HS = SD_HS_O;
assign VGA_VS = SD_VS_O;
*/
scanlines scanlines_out
(
    .clk_sys    ( clk_sys    ),
    .scanlines  ( scanlines  ),
    .ce_x2      ( ce_x2      ),
    .hs_in      ( SD_HS_O    ),
    .vs_in      ( SD_VS_O    ),
    .r_in       ( SD_R_O     ),
    .g_in       ( SD_G_O     ),
    .b_in       ( SD_B_O     ),
    .r_out      ( SL_R_O     ),
    .g_out      ( SL_G_O     ),
    .b_out      ( SL_B_O     )
);

wire [5:0] osd_r_o;
wire [5:0] osd_g_o;
wire [5:0] osd_b_o;

osd #(OSD_X_OFFSET, OSD_Y_OFFSET, OSD_COLOR, OSD_AUTO_CE) osd
(
    .clk_sys    ( clk_sys ),
    .rotate     ( rotate  ),
    .ce         ( scandoubler_disable ? ce_x1 : ce_x2 ),
    .SPI_DI     ( SPI_DI  ),
    .SPI_SCK    ( SPI_SCK ),
    .SPI_SS3    ( SPI_SS3 ),
    .R_in       ( SL_R_O ),
    .G_in       ( SL_G_O ),
    .B_in       ( SL_B_O ),
    .HSync      ( SD_HS_O ),
    .VSync      ( SD_VS_O ),
    .R_out      ( osd_r_o ),
    .G_out      ( osd_g_o ),
    .B_out      ( osd_b_o ),
    .osd_enable (osd_enable),
    
    .dsp_width_o (dsp_width),
    .dsp_height_o (dsp_height)
);

wire [5:0] cofi_r, cofi_g, cofi_b;
wire       cofi_hs, cofi_vs;

wire [9:0] dsp_width;
wire [9:0] dsp_height;

cofi cofi (
    .clk     ( clk_sys ),
    .pix_ce  ( scandoubler_disable ? ce_x1 : ce_x2 ),
    .enable  ( blend   ),
    .hblank  ( ~(SD_HS_O) ),
    .hs      ( SD_HS_O ),
    .vs      ( SD_VS_O ),
    .red     ( osd_r_o ),
    .green   ( osd_g_o ),
    .blue    ( osd_b_o ),
    .hs_out  ( cofi_hs ),
    .vs_out  ( cofi_vs ),
    .red_out ( cofi_r  ),
    .green_out( cofi_g ),
    .blue_out( cofi_b  )
);

wire [2:0]patron_pixel;

reg signed[11:0]  scroll_list = 11'd00;

always @(negedge VSync)
begin

    if (patrons)
    begin
        
            scroll_list <= scroll_list + PATRON_SCROLL;
        
    end

end

patrons patrons_names
(
    .clk           ( clk_sys ),
    .hs_i          ( scandoubler_disable ? HSync : SD_HS_O ),
    .vs_i          ( scandoubler_disable ? VSync : SD_VS_O ),
    .double_width  ( PATRON_DOUBLE_WIDTH ),
    .double_height ( PATRON_DOUBLE_HEIGHT ),
    .rotate        ( rotate ),
    .ADJ_X         ( PATRON_ADJ_X + ( rotate[0] ? scroll_list : 0 )), 
    .ADJ_Y         ( PATRON_ADJ_Y + (~rotate[0] ? scroll_list : 0 )), 
    .pixel_out     ( patron_pixel ),
    
    .dsp_width     ( dsp_width ),
    .dsp_height    ( dsp_height )
);



wire [5:0] vga_r_s = ( !hs || !vs ) ? 6'd0 : !patrons ? cofi_r : (patron_pixel[2]) ? { 6{patron_pixel[2]}} : { 2'b00, cofi_r[5:2] };
wire [5:0] vga_g_s = ( !hs || !vs ) ? 6'd0 : !patrons ? cofi_g : (patron_pixel[1]) ? { 6{patron_pixel[1]}} : { 2'b00, cofi_g[5:2] };
wire [5:0] vga_b_s = ( !hs || !vs ) ? 6'd0 : !patrons ? cofi_b : (patron_pixel[0]) ? { 6{patron_pixel[0]}} : { 2'b00, cofi_b[5:2] };
wire       hs = cofi_hs;
wire       vs = cofi_vs;


assign VGA_R = vga_r_s[5:1];
assign VGA_G = vga_g_s[5:1];
assign VGA_B = vga_b_s[5:1];
assign VGA_HS =  ( ~no_csync & scandoubler_disable ) ? ~(hs ^ vs) : hs;
assign VGA_VS =  ( ~no_csync & scandoubler_disable ) ? 1'b1       : vs;

endmodule
