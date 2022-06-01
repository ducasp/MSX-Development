// A simple OSD implementation. Can be hooked up between a cores
// VGA output and the physical VGA pins

module osd (
    // OSDs pixel clock, should be synchronous to cores pixel clock to
    // avoid jitter.
    input wire       clk_sys,
    input wire       ce,

    // SPI interface
    input wire       SPI_SCK,
    input wire       SPI_SS3,
    input wire       SPI_DI,

    input wire [1:0] rotate, //[0] - rotate [1] - left or right

    // VGA signals coming from core
    input wire [5:0] R_in,
    input wire [5:0] G_in,
    input wire [5:0] B_in,
    input wire       HSync,
    input wire       VSync,

    // VGA signals going to video connector
    output wire [5:0] R_out,
    output wire [5:0] G_out,
    output wire [5:0] B_out,
    output reg        osd_enable = 1,
    
    output wire [9:0] dsp_width_o,
    output wire [9:0] dsp_height_o
);

parameter OSD_X_OFFSET = 10'd0;
parameter OSD_Y_OFFSET = 10'd0;
parameter OSD_COLOR    = 3'd1;
parameter OSD_AUTO_CE  = 1'b1;

localparam OSD_WIDTH   = 10'd256;
localparam OSD_HEIGHT  = 10'd128;

// *********************************************************************************
// spi client
// *********************************************************************************

// this core supports only the display related OSD commands
// of the minimig

(* ramstyle = "no_rw_check" *) reg  [7:0] osd_buffer[2047:0];  // the OSD buffer itself

// the OSD has its own SPI interface to the io controller
always@(posedge SPI_SCK, posedge SPI_SS3) begin : b1
    reg  [4:0] cnt;
    reg [10:0] bcnt;
    reg  [7:0] sbuf;
    reg  [7:0] cmd;

    if(SPI_SS3) begin
        cnt  <= 0;
        bcnt <= 0;
        //osd_enable <= 0;
    end else begin
        sbuf <= {sbuf[6:0], SPI_DI};

        // 0:7 is command, rest payload
        if(cnt < 15) cnt <= cnt + 1'd1;
            else cnt <= 8;

        if(cnt == 7) begin
            cmd <= {sbuf[6:0], SPI_DI};

            // lower three command bits are line address
            bcnt <= {sbuf[1:0], SPI_DI, 8'h00};

            // command 0x40: OSDCMDENABLE, OSDCMDDISABLE
            if(sbuf[6:3] == 4'b0100) osd_enable <= SPI_DI;
        end

        // command 0x20: OSDCMDWRITE
        if((cmd[7:3] == 5'b00100) && (cnt == 15)) begin
            osd_buffer[bcnt] <= {sbuf[6:0], SPI_DI};
            bcnt <= bcnt + 1'd1;
        end
    end
end

// *********************************************************************************
// video timing and sync polarity anaylsis
// *********************************************************************************

// horizontal counter
reg  [9:0] h_cnt;
reg  [9:0] hs_low, hs_high;
wire       hs_pol = hs_high < hs_low;
wire [9:0] dsp_width = hs_pol ? hs_low : hs_high;

// vertical counter
reg  [9:0] v_cnt;
reg  [9:0] vs_low, vs_high;
wire       vs_pol = vs_high < vs_low;
wire [9:0] dsp_height = vs_pol ? vs_low : vs_high;

assign dsp_width_o = dsp_width;
assign dsp_height_o = dsp_height;

wire doublescan = (dsp_height>350);

reg auto_ce_pix;
always @(posedge clk_sys) begin : b2
    integer cnt = 0;
    integer pixsz, pixcnt;
    reg hs;

    cnt <= cnt + 1;
    hs <= HSync;

    pixcnt <= pixcnt + 1;
    if(pixcnt == pixsz) pixcnt <= 0;
    auto_ce_pix <= !pixcnt;

    if(hs && ~HSync) begin
        cnt    <= 0;
        if (cnt <= 512) pixsz <= 0;
        else pixsz  <= (cnt >> 9) - 1;
        pixcnt <= 0;
        auto_ce_pix <= 1;
    end
end

wire ce_pix = OSD_AUTO_CE ? auto_ce_pix : ce;

always @(posedge clk_sys) begin : b3
    reg hsD;
    reg vsD;

    if(ce_pix) begin
        // bring hsync into local clock domain
        hsD <= HSync;

        // falling edge of HSync
        if(!HSync && hsD) begin
            h_cnt <= 0;
            hs_high <= h_cnt;
        end

        // rising edge of HSync
        else if(HSync && !hsD) begin
            h_cnt <= 0;
            hs_low <= h_cnt;
            v_cnt <= v_cnt + 1'd1;
        end else begin
            h_cnt <= h_cnt + 1'd1;
        end

        vsD <= VSync;

        // falling edge of VSync
        if(!VSync && vsD) begin
            v_cnt <= 0;
            vs_high <= v_cnt;
        end

        // rising edge of VSync
        else if(VSync && !vsD) begin
            v_cnt <= 0;
            vs_low <= v_cnt;
        end
    end
end

// area in which OSD is being displayed
wire [9:0] h_osd_start = ((dsp_width - OSD_WIDTH)>> 1) + OSD_X_OFFSET;
wire [9:0] h_osd_end   = h_osd_start + OSD_WIDTH;
wire [9:0] v_osd_start = ((dsp_height- (OSD_HEIGHT<<doublescan))>> 1) + OSD_Y_OFFSET;
wire [9:0] v_osd_end   = v_osd_start + (OSD_HEIGHT<<doublescan);
wire [9:0] osd_hcnt    = h_cnt - h_osd_start;
wire [9:0] osd_vcnt    = v_cnt - v_osd_start;
wire [9:0] osd_hcnt_next  = osd_hcnt + 2'd1;  // one pixel offset for osd pixel
wire [9:0] osd_hcnt_next2 = osd_hcnt + 2'd2;  // two pixel offset for osd byte address register
reg        osd_de;

reg [10:0] osd_buffer_addr;
wire [7:0] osd_byte = osd_buffer[osd_buffer_addr];
reg        osd_pixel;

always @(posedge clk_sys) begin
    if(ce_pix) begin
        osd_buffer_addr <= rotate[0] ? {rotate[1] ? osd_hcnt_next2[7:5] : ~osd_hcnt_next2[7:5],  // 11
                                        rotate[1] ? (doublescan ? ~osd_vcnt[7:0] : ~{osd_vcnt[6:0], 1'b0}) : //10
                                                    (doublescan ?  osd_vcnt[7:0] : {osd_vcnt[6:0], 1'b0})} :

                                        rotate[1] ? {doublescan ? ~osd_vcnt[7:5] : ~osd_vcnt[6:4], ~osd_hcnt_next2[7:0]} : //01

                                       {doublescan ? osd_vcnt[7:5] : osd_vcnt[6:4], osd_hcnt_next2[7:0]}; //00

        osd_pixel <= rotate[0]  ? osd_byte[rotate[1]  ? osd_hcnt_next[4:2] : ~osd_hcnt_next[4:2]] : //11 and 10

                                  rotate[1] ? osd_byte[doublescan ? ~osd_vcnt[4:2]      : ~osd_vcnt[3:1]] : //01

                                  osd_byte[doublescan ? osd_vcnt[4:2]      : osd_vcnt[3:1]]; //00

        osd_de <= osd_enable &&
            (HSync != hs_pol) && ((h_cnt + 1'd1) >= h_osd_start) && ((h_cnt + 1'd1) < h_osd_end) &&
            (VSync != vs_pol) && (v_cnt >= v_osd_start) && (v_cnt < v_osd_end);
    end
end

assign R_out = !osd_de ? R_in : {osd_pixel, osd_pixel, OSD_COLOR[2], R_in[5:3]};
assign G_out = !osd_de ? G_in : {osd_pixel, osd_pixel, OSD_COLOR[1], G_in[5:3]};
assign B_out = !osd_de ? B_in : {osd_pixel, osd_pixel, OSD_COLOR[0], B_in[5:3]};

endmodule
