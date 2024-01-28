/*
--
-- top.sv
-- MC2P Original TOP by Victor Trucco
-- Multi SX 3.9.2 Top by Ducasp
--
-- All rights reserved
--
-- Redistribution and use in source and synthezised forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
-- Redistributions of source code must retain the above copyright notice,
-- this list of conditions and the following disclaimer.
--
-- Redistributions in synthesized form must reproduce the above copyright
-- notice, this list of conditions and the following disclaimer in the
-- documentation and/or other materials provided with the distribution.
--
-- Neither the name of the author nor the names of other contributors may
-- be used to endorse or promote products derived from this software without
-- specific prior written permission.
--
-- THIS CODE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
--
-- You are responsible for any legal issues arising from your use of this code.
--
*/

`default_nettype none

module top
(
    // Clocks
    input wire          clock_50_i,

    // Buttons
    input wire [2:1]    btn_n_i,

    // SDRAM
    output [12:0]       SDRAM_A,
    output  [1:0]       SDRAM_BA,
    inout  [15:0]       SDRAM_DQ,
    output              SDRAM_DQMH,
    output              SDRAM_DQML,
    output              SDRAM_CKE,
    output              SDRAM_nCS,
    output              SDRAM_nWE,
    output              SDRAM_nRAS,
    output              SDRAM_nCAS,
    output              SDRAM_CLK,

    // PS2
    inout wire          ps2_clk_io          = 1'bz,
    inout wire          ps2_data_io         = 1'bz,
    inout wire          ps2_mouse_clk_io    = 1'bz,
    inout wire          ps2_mouse_data_io   = 1'bz,

    // SD Card
    output wire         sd_cs_n_o           = 1'bZ,
    output wire         sd_sclk_o           = 1'bZ,
    output wire         sd_mosi_o           = 1'bZ,
    input wire          sd_miso_i,

    // Joysticks
    inout wire          joy1_up_io;
    inout wire          joy1_down_io;
    inout wire          joy1_left_io;
    inout wire          joy1_right_io;
    inout wire          joy1_p6_io;
    inout wire          joy1_p7_io;
    inout wire          joy1_p8_io;
    inout wire          joy2_up_io;
    inout wire          joy2_down_io;
    inout wire          joy2_left_io;
    inout wire          joy2_right_io;
    inout wire          joy2_p6_io;
    inout wire          joy2_p7_io;
    inout wire          joy2_p8_io;

    // Audio
    output              AUDIO_L,
    output              AUDIO_R,
    input wire          ear_i,
    output wire         mic_o               = 1'b0,

    // VGA
    output  [4:0]       VGA_R,
    output  [4:0]       VGA_G,
    output  [4:0]       VGA_B,
    output              VGA_HS,
    output              VGA_VS,

    // External Slots
    inout wire  [15:0]  slot_A_o            = 16'bzzzzzzzzzzzzzzzz;
    inout wire  [ 7:0]  slot_D_io           = 8'bzzzzzzzz;
    inout wire          slot_CS1_o          = 1'bz;
    inout wire          slot_CS2_o          = 1'bz;
    inout wire          slot_CLOCK_o        = 1'bz;
    inout wire          slot_M1_o           = 1'bz;
    inout wire          slot_MERQ_o         = 1'bz;
    inout wire          slot_IOREQ_o        = 1'bz;
    inout wire          slot_RD_o           = 1'bz;
    inout wire          slot_WR_o           = 1'bz;
    inout wire          slot_RESET_io       = 1'bz;
    inout wire          slot_SLOT1_o        = 1'bz;
    inout wire          slot_SLOT2_o        = 1'bz;
    inout wire          slot_BUSDIR_i       = 1'bz;
    inout wire          slot_RFSH_i         = 1'bz;
    inout wire          slot_INT_i          = 1'bz;
    inout wire          slot_WAIT_i         = 1'bz;

    //STM32
    input wire          stm_tx_i,
    output wire         stm_rx_o,
    output wire         stm_rst_o           = 1'bz, // '0' to hold the microcontroller reset line, to free the SD card

    input               SPI_SCK,
    output              SPI_DO,
    input               SPI_DI,
    input               SPI_SS2,

    output              esp_rx_o            = 1'bz,
    input               esp_tx_i            = 1'bz,

    output              LED                 = 1'b1 // '0' is LED on

);

//---------------------------------------------------------
//-- MC2+ defaults
//---------------------------------------------------------
assign stm_rst_o    = 1'bZ;
assign stm_rx_o     = 1'bZ;

reg [7:0] pump_s    = 8'b11111111;
PumpSignal PumpSignal (clk_sys, ~pll_locked, sd_flg, pump_s);

//-----------------------------------------------------------------

assign LED          = ~leds[0];

`include "build_id.v"
parameter CONF_STR = {
//    "D,disable STM SD;",
    "P,INIT;",
    "I1,IMG/VHD,Load Image...;",
    "OC,Blend,Off,On;",                                         // No SD, F12 pops up 0, Off
    "OEF,Keymap,BR,EN,ES,FR;",                                  // No SD, F12 pops up 00, BR
    "O7,OPL3 sound,Yes,No;",                                    // No SD, F12 pops up 0, invert to enable
    "OD,OPL3 stereo,Yes,No;",                                   // No SD, F12 pops up 0, mono off, stereo yes
    "OGH,Paddle using mouse,No,Vaus,MSX;",                      // No SD, F12 pops up 00, paddle emulation off
    "OK,Franky Video Type,NTSC,PAL;",                           // No SD, F12 pops up 0, MSX Video Out, status[19]
    "T0,Reset;"
};

////////////////////   CLOCKS   ///////////////////
wire        pll_locked;
wire        clk_sys;
wire        clk_sms;
wire        memclk;

//////////////////   SX3 I/O   ///////////////////
wire [63:0] status;
wire        sd_flag;

reg  [31:0] sd_lba;
reg         sd_rd = 0;
reg         sd_wr = 0;
wire        sd_conf;
wire        sd_ack;
wire        sd_ack_conf;
wire        sd_sdhc;
wire  [8:0] sd_buff_addr;
wire  [7:0] sd_buff_dout;
wire  [7:0] sd_buff_din;
wire        sd_buff_wr;
wire        img_mounted;
wire        img_readonly;
wire [31:0] img_size;
wire  [8:0] mouse_x;
wire  [8:0] mouse_y;
wire  [7:0] mouse_flags;
wire        mouse_strobe;
wire sd_sclk_o_s, sd_cs_n_o_s, sd_mosi_o_s, sd_miso_i_s;

reg ce_cpu_p;
reg ce_cpu_n;
reg ce_vdp;
reg ce_pix;
reg ce_sp;
always @(negedge clk_sms) begin
    reg [4:0] clkd;

    ce_sp <= clkd[0];
    ce_vdp <= 0;//div5
    ce_pix <= 0;//div10
    clkd <= clkd + 1'd1;
    if (clkd==29) begin
        clkd <= 0;
        ce_vdp <= 1;
        ce_pix <= 1;
    end else if (clkd==24) begin
        ce_vdp <= 1;
    end else if (clkd==19) begin
        ce_vdp <= 1;
        ce_pix <= 1;
    end else if (clkd==14) begin
        ce_vdp <= 1;
    end else if (clkd==9) begin
        ce_vdp <= 1;
        ce_pix <= 1;
    end else if (clkd==4) begin
        ce_vdp <= 1;
    end
end

sd_card sd_card
(
    .clk_sys(clk_sys),
    .img_mounted(img_mounted),
    .img_size(img_size),
    .sd_conf(sd_conf),
    .sd_ack(sd_ack),
    .sd_ack_conf(sd_ack_conf),
    .sd_sdhc(sd_sdhc),
    .sd_rd(sd_rd),
    .sd_wr(sd_wr),
    .sd_lba(sd_lba),
    .sd_buff_addr(sd_buff_addr),
    .sd_buff_din(sd_buff_din),
    .sd_buff_dout(sd_buff_dout),
    .sd_buff_wr(sd_buff_wr),
    .allow_sdhc(1),
    .sd_sck(sd_sclk_o_s),
    .sd_cs(sd_cs_n_o_s),
    .sd_sdi(sd_mosi_o_s),
    .sd_sdo(sd_miso_i_s)
);

reg [7:0]   osd_s   = 8'b11111111;
wire ioctl_download, external_sd_disabled;


data_io #(
    .STRLEN(($size(CONF_STR)>>3)))
data_io
(
    .clk_sys    ( clk_sys ),
    .SPI_SCK    ( SPI_SCK ),
    .SPI_DI     ( SPI_DI  ),
    .SPI_SS2    ( SPI_SS2 ),
    .SPI_DO     ( SPI_DO  ),

    .data_in    ( osd_keys & pump_s  ),
    .conf_str   ( CONF_STR ),
    .status     ( status ),
    .sd_flag    ( sd_flag ),
    .ioctl_download ( ioctl_download ),

        //--------------------------------------------

    .clk_sd(clk_sys),
    .sd_conf(sd_conf),
    .sd_sdhc(sd_sdhc),
    .sd_lba(sd_lba),
    .sd_rd({1'b0,sd_rd}),
    .sd_wr({1'b0,sd_wr}),
    .sd_ack(sd_ack),
    .sd_buff_addr(sd_buff_addr),
    .sd_dout(sd_buff_dout),
    .sd_din(sd_buff_din),
    .sd_dout_strobe(sd_buff_wr),
    .sd_din_strobe(),
    .img_mounted(img_mounted),
    .img_size(img_size),

    .external_sd_disabled ( external_sd_disabled ) //output: signal DIS_SD from .INI to disable the STM SD pins 
);

wire [5:0]  audio_li;
wire [5:0]  audio_ri;
wire [5:0]  audio_l;
wire [5:0]  audio_r;

reg  [5:0]  joya = '1;
reg  [5:0]  joyb = '1;
wire [5:0]  msx_joya;
wire        msx_stra;
wire        Sd_Ck;
wire        Sd_Cm;
wire [3:0]  Sd_Dt;
wire [7:0]  leds;

reg         reset;
wire        resetW = status[0] | img_mounted | (PoR_counter != 25'd0);

wire        sd_flg = sd_flag | status[31];

reg [5:0]   clock_div_q;

reg         last_PoR;
reg [24:0]  PoR_counter = 25'd0;

always @(posedge clk_sys) 
begin
    last_PoR <= sd_flg;

    if (sd_flg && ~last_PoR) PoR_counter <= 25'b1111111111111111111111111;

    if (PoR_counter > 25'd0) PoR_counter <= PoR_counter - 25'd1;

end

always @(posedge clk_sys) begin
reg        mouse_en_old = 1'b0;
reg  [1:0] paddl_en_old = 2'b00;
reg        clock_div_5 = 1'b0;
reg [20:0] port_a_disc_time = 21'd0;

    reset <= resetW;
    audio_li <= audio_l;
    audio_ri <= audio_r;
    clock_div_q <= clock_div_q + 6'd1;
    clock_div_5 <= clock_div_q[5];

    // This handle device change so it can be detected by HIDLIB/HIDTEST
    // It considers that old device should be plugged out at least for 1s
    mouse_en_old <= mouse_en;
    paddl_en_old <= status[17:16];
    if ((mouse_en_old != mouse_en)||(paddl_en_old != status[17:16])) begin
        port_a_disc_time <= 21'd800000; //about 1s disconnected
        joya_en <= 1'b0;
    end
    if (clock_div_q[5]!=clock_div_5)
        if (port_a_disc_time != 21'd0)
            port_a_disc_time <= port_a_disc_time - 21'd1;
        else
            joya_en <= 1'b1;
end

assign      msx_joya = joya_en ?
                                (status[17:16]!='0) ?
                                                     status[16] ? { 2'b11, pad_data, mouse_flags[1]&mouse_flags[0], 2'b11 } : { mouse_flags[1:0], pad_data, 3'b111 }
                                : mouse_en ?
                                            mouse : { joy1_p7_io, joy1_p6_io, joy1_right_io, joy1_left_io, joy1_down_io, joy1_up_io}
                       : '1;
wire        mouse_en;
wire        joya_en;
reg  [5:0]  mouse;

ps2mouse mousectrl
(
    .clk        ( clock_div_q[5] ),     //-- need a slower clock to avoid loosing data
    .reset      ( reset ),              //-- slow reset signal
 
    .ps2mdat    ( ps2_mouse_data_io ),  //-- mouse PS/2 data
    .ps2mclk    ( ps2_mouse_clk_io ),   //-- mouse PS/2 clk
 
    .xcount     ( mouse_x ),            //-- mouse X counter
    .ycount     ( mouse_y ),            //-- mouse Y counter
    .zcount     (   ),                  //-- mouse Z counter
    .mleft      ( mouse_flags[0] ),     //-- left mouse button output
    .mright     ( mouse_flags[1] ),     //-- right mouse button output
    .mthird     ( mouse_flags[2] ),     //-- third(middle) mouse button output   
    .mouse_data_out ( mouse_strobe )    //-- mouse has data top present
);

always @(posedge clk_sys) begin

    reg        stra_d = 1'b0;
    reg        mouse_strobe_d = 1'b0;
    reg  [7:0] mouse_x_latch = '0;
    reg  [7:0] mouse_y_latch = '0;
    reg  [1:0] mouse_state = '0;
    reg [17:0] mouse_timeout = 18'd100000;

    if (reset) begin
        mouse_en <= 1'b0;
        mouse_state <= '0;
    end
    else if (mouse_strobe) mouse_en <= 1'b1;
    else if (joy1_s!='1) mouse_en <= 1'b0;

    mouse_strobe_d <= mouse_strobe;
    stra_d <= msx_stra;
    mouse[5:4] <= mouse_flags[1:0];

    if (mouse_strobe && !mouse_strobe_d) begin
        mouse_x_latch <= mouse_x; //~mouse_x + 1'd1; //2nd complement of x
        mouse_y_latch <= mouse_y;
    end

    if (mouse_en) begin
        if (mouse_timeout != '0) begin
            mouse_timeout <= mouse_timeout - 1'd1;
            if (mouse_timeout == 1) mouse_state <= 0;
        end

        if (stra_d != msx_stra) begin
            mouse_timeout <= 18'd50000;
            mouse_state <= mouse_state + 1'd1;
            case (mouse_state)
            2'b00: mouse[3:0] <= {mouse_x_latch[4],mouse_x_latch[5],mouse_x_latch[6],mouse_x_latch[7]};
            2'b01: mouse[3:0] <= {mouse_x_latch[0],mouse_x_latch[1],mouse_x_latch[2],mouse_x_latch[3]};
            2'b10: mouse[3:0] <= {mouse_y_latch[4],mouse_y_latch[5],mouse_y_latch[6],mouse_y_latch[7]};
            2'b11:
            begin
                mouse[3:0] <= {mouse_y_latch[0],mouse_y_latch[1],mouse_y_latch[2],mouse_y_latch[3]};
                mouse_x_latch <= '0;
                mouse_y_latch <= '0;
            end
            endcase
        end
    end
end

//--- Paddle emulation --------------------------------------------
wire        pad_data;
wire  [8:0] V_Paddle_Read;
wire  [8:0] M_Paddle_Read;
wire  [8:0] Shift_Register;
wire  [8:0] MSXPaddleCount;
wire [10:0] Scaler12us;
wire        oldmousedata;
wire        oldstrA_s;
wire        oldjoy1_p6_io;

always @(posedge clk_sdram) begin
    reg  [8:0] Paddle_Pos       = '0;
    int unsigned Temp_Mouse_X   = 'd0;
    reg  [1:0] paddle_state     = 2'b00;

    // Those will take effect only on the next clock
    oldstrA_s <= msx_stra;
    oldjoy1_p6_io <= joy1_p6_io;
    oldmousedata <= mouse_strobe;

    // We are here mostly to read X axis deltas
    if (mouse_strobe && !oldmousedata) begin
        //so what matters to us is if X changed, otherwise no check to do
        if (mouse_x != '0) begin
            // positive? move to the left, decrease position value
            if (!mouse_x[7]) begin
                Temp_Mouse_X = {2'b00,    mouse_x[6:0]};
                // Update VAUS position
                Paddle_Pos = V_Paddle_Read;
                if (Paddle_Pos < Temp_Mouse_X)
                    Paddle_Pos = 9'b001101110;
                else
                    Paddle_Pos = Paddle_Pos - Temp_Mouse_X;
                if (Paddle_Pos < 9'd110)
                    Paddle_Pos = 9'd110;
                V_Paddle_Read <= Paddle_Pos;
                // Update MSX Paddle position
                Paddle_Pos = M_Paddle_Read;
                if (Paddle_Pos < Temp_Mouse_X)
                    Paddle_Pos = 9'b000000000;
                else
                    Paddle_Pos = Paddle_Pos - Temp_Mouse_X;
                M_Paddle_Read <= Paddle_Pos;
            end
            // negative? move to the right, increase position value
            else begin
                // Negative value, Just divide it or not according to sensitivity setting, after inverting it
                Temp_Mouse_X = {2'b00,    ~mouse_x[6:0]};
                // Negative value, after inverting it, add 1
                Temp_Mouse_X = Temp_Mouse_X + 9'd1;
                // Update VAUS position
                Paddle_Pos = V_Paddle_Read;
                Paddle_Pos = Paddle_Pos + Temp_Mouse_X;
                if (Paddle_Pos > 9'd380)
                    Paddle_Pos = 9'd380;
                V_Paddle_Read <= Paddle_Pos;
                // Update MSX Paddle position
                Paddle_Pos = M_Paddle_Read;
                Paddle_Pos = Paddle_Pos + Temp_Mouse_X;
                if (Paddle_Pos > 275)
                    Paddle_Pos = 9'd275;
                M_Paddle_Read <= Paddle_Pos;
            end
        end
    end

    case (paddle_state)
        2'b00: //Startup -- Should be here only once
        begin
            // "Open"/"Inactive"
            pad_data        <= 1'b1;
            V_Paddle_Read   <= 9'b011101100; // Center Position / 236
            M_Paddle_Read   <= 9'b001111100; // Center Position / 127
            Shift_Register  <= 9'b000000000; // Cleared
            paddle_state    <= 2'b01;        // Next state
        end
        2'b01: //Pad Work
        // Will be here most of the time in VAUS Mode
        // In MSX mode, just waiting the trigger to time encode paddle read
        begin
            if (status[17:16]==2'b01) begin
                // VAUS Mode, data has bit to be presented
                pad_data <= Shift_Register[8];
                // Pin 8 from low to high, copy value to shift register in VAUS mode
                if (!oldstrA_s && msx_stra)
                    Shift_Register = V_Paddle_Read;
                // Pin 6 from low to high, shift the shift register in VAUS mode
                else if (!oldjoy1_p6_io && joy1_p6_io)
                    Shift_Register[8:0] = { Shift_Register[7:0], 1'b0 };
            end
            else if (status[17:16]==2'b10) begin
                // MSX Paddle mode, inactive until data is requested
                pad_data <= 1'b0;
                // Pin 8 from low to high, need to time encode the paddle read in MSX mode
                if (!oldstrA_s && msx_stra) begin
                    MSXPaddleCount <= M_Paddle_Read;
                    paddle_state <= 2'b10;
                    pad_data <= 1'b1;
                    // Adjust our scaler value, 1032 clk_sdram give us a little bit over 12us
                    Scaler12us <= 11'd1032;
                end
            end
        end
        2'b10: //Pad Msx Send Data1
        begin
            // First we need to stop for 12us * paddle pos
            if (MSXPaddleCount != '0) begin
                if (Scaler12us != '0)
                    Scaler12us <= Scaler12us - 11'd1;
                else begin
                    Scaler12us <= 11'd1032;
                    MSXPaddleCount <= MSXPaddleCount - 9'd1;
                end
            end
            else begin
                Scaler12us <= 11'd1032;
                paddle_state <= 2'b11;
            end
        end
        2'b11: //Pad Msx Send Data2
        begin
            // Now wait more 12us, even for 0, we have extra 12us http://frs.badcoffee.info/hardware/PWM_devices.html
            // R2 value * C value * 0,55 (HCT123) guarantees 12us minimum
            if (Scaler12us != '0)
                Scaler12us <= Scaler12us - 11'd1;
            else
                paddle_state <= 2'b01;
        end
    endcase

    if (!joya_en) paddle_state <= 2'b00; // Reset paddle to wait state while disconnecting

end

always @(*) begin
    if (external_sd_disabled == 1'b0 || pump_s != 8'b11111111) //use IMG or under initial reset
    begin
        sd_sclk_o = 1'bZ;
        sd_mosi_o = 1'bZ;
        sd_cs_n_o = 1'bZ;

        sd_sclk_o_s = Sd_Ck;
        sd_mosi_o_s = Sd_Cm;
        sd_cs_n_o_s = Sd_Dt[3];
        Sd_Dt[0] = sd_miso_i_s;
    end
    else //use External SD
    begin
        sd_sclk_o_s = 1'b1;
        sd_mosi_o_s = 1'b1;
        sd_cs_n_o_s = 1'b1;

        sd_sclk_o = Sd_Ck;
        sd_mosi_o = Sd_Cm;
        sd_cs_n_o = Sd_Dt[3];
        Sd_Dt[0] = sd_miso_i;
    end
end

wire        midi_o_s;
wire        midi_active_s;
wire        clk_sdram;
assign      SDRAM_CLK = clk_sdram;

emsx_top emsx
(
        // Clock, Reset ports
        .pClk21m         ( clock_50_i     ),
        .pExtClk         ( 1'b0           ),

        // SDRAM ports
        .pMemClk         ( memclk         ),
        .pSdrClk         ( clk_sdram      ),
        .pMemCke         ( SDRAM_CKE      ),
        .pMemCs_n        ( SDRAM_nCS      ),
        .pMemRas_n       ( SDRAM_nRAS     ),
        .pMemCas_n       ( SDRAM_nCAS     ),
        .pMemWe_n        ( SDRAM_nWE      ),
        .pMemUdq         ( SDRAM_DQMH     ),
        .pMemLdq         ( SDRAM_DQML     ),
        .pMemBa0         ( SDRAM_BA[0]    ),
        .pMemBa1         ( SDRAM_BA[1]    ),
        .pMemAdr         ( SDRAM_A        ),
        .pMemDat         ( SDRAM_DQ       ),

        // PS/2 keyboard ports
        .pPs2Clk         ( ps2_clk_io     ),
        .pPs2Dat         ( ps2_data_io    ),

        // Joystick ports (Port_A, Port_B)
        .pJoyA_in        ( {msx_joya[5:4],
                            msx_joya[0],
                            msx_joya[1],
                            msx_joya[2],
                            msx_joya[3]}  ),
        .pStra           ( msx_stra       ),
        // WARNING!!! Unlike SM-X / OCM this
        // is not bi-dir, so it is 1 or 0.
        // This is needed as it is not connected
        // externally to receive a pull-up, unlike
        // on SM-X or OCM.
        .pJoyA_out       ( msx_joy1_out   ),
        .pJoyB_in        ( {msx_joyb[5:4],
                            msx_joyb[0],
                            msx_joyb[1],
                            msx_joyb[2],
                            msx_joyb[3]}  ),
        .pStrb           ( msx_strb       ),

        // SD/MMC slot ports
        .pSd_Ck          ( Sd_Ck          ),
        .pSd_Cm          ( Sd_Cm          ),
        .pSd_Dt          ( Sd_Dt          ),

        // DIP switch, Lamp ports
        .pDip            ( dip_i          ),
        .pLed            ( leds           ),

        // Video, Audio/CMT ports
        .pDac_VR         ( R_O            ), // RGB_Red / Svideo_C
        .pDac_VG         ( G_O            ), // RGB_Grn / Svideo_Y
        .pDac_VB         ( B_O            ), // RGB_Blu / CompositeVideo
        .pVideoHS_n      ( HSync          ), // HSync(RGB15K, VGA31K)
        .pVideoVS_n      ( VSync          ), // VSync(RGB15K, VGA31K)

        .pDac_SL         ( audio_l        ),
        .pDac_SR         ( audio_r        ),

        // Franky VDP
        .clkSYSSMS       ( clk_sms        ),
        .clkSMSVDP       ( ce_vdp         ),
        .clkPIXSMS       ( ce_pix         ),
        .clkSMSSP        ( ce_sp          ),
        .colorSMSVDP     ( color          ),
        .sms_mask_column ( sms_mask_column),
        .sms_x           ( sms_x          ),
        .sms_y           ( sms_y          ),
        .sms_smode_M1    ( sms_smode_M1   ),
        .sms_smode_M3    ( sms_smode_M3   ),
        .sms_pal         ( sms_pal        ),
        .sms_video_active( smsvideo_active),

        // SX3 Exclusive
        .pll_locked      ( pll_locked     ),
        .osd_o           ( osd_s          ),
        .opl3_enabled    ( ~status[7]     ),
        .opl3_mono       ( status[13]     ),
        .EnAltMap        ( { status[14],
                             status[15]}  ),

        // Slots
        .pCpuClk         ( slot_CLOCK_o   ),
        .pSltRst_n       ( ~reset         ),

        .pSltAdr         ( ext_cart_a     ),
        .pSltDat         ( sram_data_io   ),

        .pSltMerq_n      ( slot_MERQ_o    ),
        .pSltIorq_n      ( slot_IOREQ_o   ),
        .pSltRd_n        ( slot_RD_o      ),
        .pSltWr_n        ( slot_WR_o      ),

        .pSltRfsh_n      ( slot_RFSH_i    ),
        .pSltWait_n      ( slot_WAIT_i    ),
        .pSltInt_n       ( GPIO[27]       ),
        .pSltM1_n        ( slot_M1_o      ),

        .pSltBdir_n      ( slot_BUSDIR_i  ),
        .pSltSltsl_n     ( slot_SLOT1_o   ),
        .pSltSlts2_n     ( slot_SLOT2_o   ),
        .pSltCs1_n       ( slot_CS1_o     ),
        .pSltCs2_n       ( slot_CS2_o     ),
        .pSltCs12_n      ( slot_CS12_o    ),

        // SM-X
        .clk21m_out      ( clk_sys        ),
        .esp_rx_o        ( esp_rx_o       ),
        .esp_tx_i        ( esp_tx_i       ),
        .ear_i           ( ear_i          ),
        .mic_o           ( mic_o          ),
        .midi_o          ( midi_o_s       ),
        .midi_active_o   ( midi_active_s  )
);

//////////////////   VIDEO   //////////////////
wire  [ 5:0] R_O;
wire  [ 5:0] G_O;
wire  [ 5:0] B_O;
wire  [ 3:0] R_O_SMS;
wire  [ 3:0] G_O_SMS;
wire  [ 3:0] B_O_SMS;
wire         HSync, VSync;
wire  [11:0] color;
wire         sms_HSync, sms_VSync;
wire  [ 4:0] MSX_VGA_R, MSX_VGA_G, MSX_VGA_B, SMS_VGA_R , SMS_VGA_B , SMS_VGA_G;
wire         MSX_VGA_HS, MSX_VGA_VS, SMS_VGA_HS, SMS_VGA_VS;
wire         sms_mask_column;
wire  [ 8:0] sms_x;
wire  [ 8:0] sms_y;
wire         sms_HBlank;
wire         sms_VBlank;
wire         sms_smode_M1;
wire         sms_smode_M3;
wire         smsvideo_active;
wire         sms_pal;

video
(
    .clk         ( clk_sms ),
    .ce_pix      ( ce_pix ),
    .pal         ( sms_pal ),
    .gg          ( 1'b0 ),
    .border      ( 1'b1 ),
    .mask_column ( sms_mask_column ),
    .x           ( sms_x ),
    .y           ( sms_y ),
    .smode_M1    ( sms_smode_M1 ),
    .smode_M3    ( sms_smode_M3 ),
    .HSync       ( sms_HSync ),
    .VSync       ( sms_VSync ),
    .HBlank      ( sms_HBlank ),
    .VBlank      ( sms_VBlank )
);

assign R_O_SMS = color[3:0];
assign G_O_SMS = color[7:4];
assign B_O_SMS = color[11:8];

mist_video #(.SD_HCNT_WIDTH(10), .COLOR_DEPTH(4)) mist_video_sms
(
    .clk_sys                ( clk_sms ),
    .scanlines              ( status[11:10] ),
    .rotate                 ( 2'b00 ),
    .scandoubler_disable    ( status[1] ),
    .blend                  ( status[12] ),

    .SPI_DI                 ( SPI_DI ),
    .SPI_SCK                ( SPI_SCK ),
    .SPI_SS3                ( SPI_SS2 ),
    .HSync                  ( ~sms_HSync ),
    .VSync                  ( ~sms_VSync ),
    .R                      ( R_O_SMS ),
    .G                      ( G_O_SMS ),
    .B                      ( B_O_SMS ),
    .VGA_HS                 ( SMS_VGA_HS ),
    .VGA_VS                 ( SMS_VGA_VS ),
    .VGA_R                  ( SMS_VGA_R ),
    .VGA_G                  ( SMS_VGA_G ),
    .VGA_B                  ( SMS_VGA_B ),
    .osd_enable             ( )
);

mist_video #( .OSD_COLOR ( 3'b001 ), .COLOR_DEPTH(5)) mist_video_inst
(
    .clk_sys                ( memclk ),
    .scanlines              ( status[11:10] ),
    .rotate                 ( 2'b00 ),
    .scandoubler_disable    ( 1'b1 ),
    .ce_divider             ( 1'b0 ),
    .blend                  ( status[12] ),
    .no_csync               ( 1'b1 ),

    .SPI_SCK                ( SPI_SCK ),
    .SPI_SS3                ( SPI_SS2 ),
    .SPI_DI                 ( SPI_DI ),

    .HSync                  ( HSync ),
    .VSync                  ( VSync ),
    .R                      ( R_O[5:1] ),
    .G                      ( G_O[5:1] ),
    .B                      ( B_O[5:1] ),

    .VGA_HS                 ( MSX_VGA_HS ),
    .VGA_VS                 ( MSX_VGA_VS ),
    .VGA_R                  ( MSX_VGA_R ),
    .VGA_G                  ( MSX_VGA_G ),
    .VGA_B                  ( MSX_VGA_B ),

    .osd_enable             ( )
);

assign sms_pal = status[19];
assign VGA_R  = smsvideo_active ? SMS_VGA_R : MSX_VGA_R;
assign VGA_G  = smsvideo_active ? SMS_VGA_G : MSX_VGA_G;
assign VGA_B  = smsvideo_active ? SMS_VGA_B : MSX_VGA_B;
assign VGA_HS = smsvideo_active ? SMS_VGA_HS : MSX_VGA_HS;
assign VGA_VS = smsvideo_active ? SMS_VGA_VS : MSX_VGA_VS;
assign AUDIO_L      = audio_li[0];
assign AUDIO_R      = audio_ri[0];

endmodule