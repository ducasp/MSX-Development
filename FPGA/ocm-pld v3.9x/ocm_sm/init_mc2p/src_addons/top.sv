/*
--
-- top.sv
-- MC2P Original TOP by Victor Trucco
-- MC2P 3.9 Top by Ducasp
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
    input wire [4:1]    btn_n_i,

    // SRAM (IS61WV20488FBLL-10)
    output wire [20:0]  sram_addr_o         = 21'b000000000000000000000,
    inout wire  [7:0]   sram_data_io        = 8'bzzzzzzzz,
    output wire         sram_we_n_o         = 1'b1,
    output wire         sram_oe_n_o         = 1'b1,

    // SDRAM (W9825G6KH-6)
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
    output wire         joy_clock_o         = 1'b1,
    output wire         joy_load_o          = 1'b1,
    input  wire         joy_data_i, 
    output wire         joy_p7_o            = 1'b1,

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

    //STM32
    input wire          stm_tx_i,
    output wire         stm_rx_o,
    output wire         stm_rst_o           = 1'bz, // '0' to hold the microcontroller reset line, to free the SD card

    input               SPI_SCK,
    output              SPI_DO,
    input               SPI_DI,
    input               SPI_SS2,
    output wire         SPI_nWAIT           = 1'b1, // '0' to hold the microcontroller data streaming

    inout [31:0]        GPIO,

    output              LED                 = 1'b1 // '0' is LED on

);

//---------------------------------------------------------
//-- MC2+ defaults
//---------------------------------------------------------
assign GPIO         = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
assign stm_rst_o    = 1'bZ;
assign stm_rx_o     = 1'bZ;

// SRAM not used in this core
assign sram_we_n_o  = 1'b1;
assign sram_oe_n_o  = 1'b1;

wire joy1_up_i, joy1_down_i, joy1_left_i, joy1_right_i, joy1_p6_i, joy1_p9_i;
wire joy2_up_i, joy2_down_i, joy2_left_i, joy2_right_i, joy2_p6_i, joy2_p9_i;

wire joyserial_clk;

always @(posedge clk_sys) begin
    joyserial_clk <= ~joyserial_clk;
end
joystick_serial  joystick_serial
(
    .clk_i           ( joyserial_clk ),
    .joy_data_i      ( joy_data_i ),
    .joy_clk_o       ( joy_clock_o ),
    .joy_load_o      ( joy_load_o ),

    .joy1_up_o       ( joy1_up_i ),
    .joy1_down_o     ( joy1_down_i ),
    .joy1_left_o     ( joy1_left_i ),
    .joy1_right_o    ( joy1_right_i ),
    .joy1_fire1_o    ( joy1_p6_i ),
    .joy1_fire2_o    ( joy1_p9_i ),

    .joy2_up_o       ( joy2_up_i ),
    .joy2_down_o     ( joy2_down_i ),
    .joy2_left_o     ( joy2_left_i ),
    .joy2_right_o    ( joy2_right_i ),
    .joy2_fire1_o    ( joy2_p6_i ),
    .joy2_fire2_o    ( joy2_p9_i )
);

assign joy_p7_o     = (midi_active_s) ? midi_o_s : joyP7_s;

//--- Joystick read with sega 6 button support----------------------
reg clk_sega_s = 1'b0;
reg old_clk_sega_s = 1'b0;
localparam CLOCK = 21484; // clk_sys speed
localparam TIMECLK = (36 * (CLOCK / 1000)); //calculate 36us state time based on input clock
reg [9:0] delay = TIMECLK;

always@(posedge clk_sys)
begin
    delay <= delay - 10'd1;

    if (delay == 10'd0)
        begin
            clk_sega_s <= ~clk_sega_s;
            delay <= TIMECLK;
        end
end

reg [7:0]osd_keys   = 8'b11111111;
reg [11:0]joy1_s    = 12'b111111111111;
reg [11:0]joy2_s    = 12'b111111111111;
reg joyP7_s = 1'b1;
reg [5:0]state_v = 6'd0;
reg j1_sixbutton_v = 1'b0;
reg j1_twobutton_v = 1'b0;
reg j2_sixbutton_v = 1'b0;
reg j2_twobutton_v = 1'b0;

always @(posedge clk_sys)
begin
    if (clk_sega_s != old_clk_sega_s) begin
        // joy_s format M  X  Y Z S A C B R L D U
        //              11 10 9 8 7 6 5 4 3 2 1 0
        case (state_v)
            // All joysticks with 1st strobe high return four directions and two buttons
            6'd0:
                begin
                    // Don't care reading now, just pulse it
                    joyP7_s <=  1'b0;
                end
            // At this point, the first low pulse, we can't determine joystick type
            // We could determine it to be a 2 button MS joystick, but not differentiate Mega 8 buttons from Mega 4 buttons
            6'd1:
                begin
                    // Don't care reading now, just pulse it
                    joyP7_s <=  1'b1;
                end
            // All joysticks with 2nd strobe high return four directions and two buttons
            // So let's get it
            6'd2:
                begin
                    joy1_s[3:0] <= {joy1_right_i, joy1_left_i, joy1_down_i, joy1_up_i}; //-- R, L, D, U
                    joy1_s[5:4] <= {joy1_p9_i, joy1_p6_i}; //-- C, B
                    joy2_s[3:0] <= {joy2_right_i, joy2_left_i, joy2_down_i, joy2_up_i}; //-- R, L, D, U
                    joy2_s[5:4] <= {joy2_p9_i, joy2_p6_i}; //-- C, B
                    // Pulse it
                    joyP7_s <= 1'b0;
                end
            // 2nd strobe low, now it is time to figure out if joystick is Mega or Master
            // 2 buttons Master System joystick won't have LEFT + RIGHT
            // Any Mega joystick will have LEFT + RIGHT at the same time here
            6'd3:
                begin
                    if (joy1_right_i == 1'b0 && joy1_left_i == 1'b0) begin
                        // it's a megadrive joystick
                        joy1_s[7:6] <= { joy1_p9_i , joy1_p6_i }; //-- Start, A
                        // we know it is not two buttons
                        j1_twobutton_v <= 1'b0;
                    end
                    else begin
                        // it's a Master joystick
                        joy1_s[11:4] <= { 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, joy1_p9_i, joy1_p6_i }; //-- read A/B as master System
                        // we know it is two buttons
                        j1_twobutton_v <= 1'b1;
                    end
                    if (joy2_right_i == 1'b0 && joy2_left_i == 1'b0) begin
                        // it's a megadrive joystick
                        joy2_s[7:6] <= { joy2_p9_i , joy2_p6_i }; //-- Start, A
                        // we know it is not two buttons
                        j2_twobutton_v <= 1'b0;
                    end
                    else begin
                        // it's a Master joystick
                        joy2_s[11:4] <= { 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, joy2_p9_i, joy2_p6_i }; //-- read A/B as master System
                        // we know it is two buttons
                        j2_twobutton_v <= 1'b1;
                    end
                    // Pulse it
                    joyP7_s <= 1'b1;
                end
            // 3rd strobe high
            // All joysticks with 3rd strobe high return four directions and two buttons
            6'd4:
                begin
                    // Don't care reading now, just pulse it
                    joyP7_s <= 1'b0;
                end
            // 3rd strobe low, now it is time to figure out if joystick is Mega 8 type
            // If Mega 8 joystick, will have UP + DOWN at the same time here
            6'd5:
                begin
                    if (joy1_down_i == 1'b0 && joy1_up_i == 1'b0 )
                        j1_sixbutton_v <= 1'b1; // it's an eight button
                    else
                        j1_sixbutton_v <= 1'b0; // it's not an eight button
                    if (joy2_down_i == 1'b0 && joy2_up_i == 1'b0 )
                        j2_sixbutton_v <= 1'b1; // it's an eight button
                    else
                        j2_sixbutton_v <= 1'b0; // it's not an eight button
                    // Pulse it
                    joyP7_s <= 1'b1;
                end
            // 4th strobe high
            // Only Mega 8 joysticks with 4thd strobe high return the four extra buttons
            6'd6:
                begin
                    if (j1_sixbutton_v == 1'b1)
                        joy1_s[11:8] <= { joy1_right_i, joy1_left_i, joy1_down_i, joy1_up_i }; // Mode, X, Y and Z
                    else
                        joy1_s[11:8] <= { 1'b1, 1'b1, 1'b1, 1'b1 };
                    if (j2_sixbutton_v == 1'b1)
                        joy2_s[11:8] <= { joy2_right_i, joy2_left_i, joy2_down_i, joy2_up_i }; // Mode, X, Y and Z
                    else
                        joy2_s[11:8] <= { 1'b1, 1'b1, 1'b1, 1'b1 };
                    joyP7_s <= 1'b0;
                end
            // 4th strobe low will fall here
            // We never care about it, some Mega joysticks could have extra buttons here
            // But we don't have this case to test, so just ignore it
            default:
                begin
                    // Keep it high ~240 times, this gives 2ms, enough to a sis button controller reset
                    // This is important so if a joystick was plugged in the middle of the routine, it
                    // will misread for that cycle, but after these 2ms, it will be on state 0 again
                    // and read correctly from that moment on
                    joyP7_s <= 1'b1;
                end
        endcase
        // Always increment state every clock
        state_v <= state_v + 1;
        // If mode and start are not hit at the same time on joy 1
        if (joy1_s[7] || joy1_s[11])
            // won't change OSD
            osd_keys[7:0] <= { osd_s[7], osd_s[6], osd_s[5], osd_s[4]&joy1_s[4]&joy1_s[5]&joy1_s[6]&joy1_s[10]&joy1_s[8]&joy1_s[9], osd_s[3]&joy1_s[3], osd_s[2]&joy1_s[2], osd_s[1]&joy1_s[1], osd_s[0]&joy1_s[0]};
        else
            // hit at the same time, force invoking OSD
            osd_keys[7:0] <= { 1'b0, 1'b1, 1'b1, osd_s[4]&joy1_s[4]&joy1_s[5]&joy1_s[6]&joy1_s[10]&joy1_s[8]&joy1_s[9], osd_s[3]&joy1_s[3], osd_s[2]&joy1_s[2], osd_s[1]&joy1_s[1], osd_s[0]&joy1_s[0]};
    end
    // This is taken every clock so we detect changes
    old_clk_sega_s <= clk_sega_s;
end

//--- Joymega emulation -------------------------------------------
localparam CLOCK_J = 21484; // clk_sys speed
localparam TIMECLK_J = (1600 * (CLOCK_J / 1000)); //calculate 1.6ms time-out to reset state
reg [15:0] delay_a = 16'd0;
reg [15:0] delay_b = 16'd0;
reg [3:0]state_a = 4'd0;
reg [3:0]state_b = 4'd0;
reg stra_j = 1'b0;
reg strb_j = 1'b0;
reg frsta = 1'b0;
reg frstb = 1'b0;
reg holdstatechangea = 1'b0;
reg holdstatechangeb = 1'b0;

always@(posedge clk_sys)
begin
    holdstatechangea = 1'b0;
    // First, let's see if we are waiting some delay to reset state
    if (delay_a != 16'd0)
        // Decrement delay counter
        delay_a <= delay_a - 1;

    // Still an 8 buttons joystick ? No Delay? Timer was set to run?
    if ((j1_sixbutton_v == 1'b1)&&(j1_twobutton_v == 1'b0)&&(delay_a == 16'd0)&&(frsta == 1'b1)) begin
        frsta <= 1'b0; // no longer running
        holdstatechangea = 1'b1; // No check for state change
        // Back to state 0 or 1
        if (!msx_stra)
        begin
            stra_j <= 1'b0;
            state_a <= 4'd0; // Back to 0, simulate no change so state doesn't increment state counter
        end
        else begin
            stra_j <= 1'b1;
            state_a <= 4'd1; // Back to 1, simulate no change so state doesn't increment state counter
        end
    end
    else if ((j1_sixbutton_v == 1'b0)||(j1_twobutton_v == 1'b1)) begin
        frsta <= 1'b0; // no longer running
        delay_a <= 16'd0; // no timer just if changed
    end

    // Increase state on change of strobe
    if ((stra_j != msx_stra)&&(!holdstatechangea)) begin
        // Eight Buttons Joystick?
        if ((j1_sixbutton_v == 1'b1)&&(j1_twobutton_v == 1'b0)) begin
            // Yeah, have we started running the timer to reset state? And are we at state 0?
            if ((frsta == 1'b0)&&(state_a == 4'd0)) begin
                // No, so let's do it
                delay_a <= TIMECLK_J;
                frsta <= 1'b1;
            end
            // 8 buttons joy will leap over to state 0 after state 7
            if (state_a == 4'd7)
                state_a <= 4'd0;
            // Otherwise just increment state
            else
                state_a <= state_a + 1;
        end
        // Not eight buttons
        else begin
            // 4 and 2 buttons joy will handle only state 0 or 1
            if (state_a == 4'd0)
                state_a <= 4'd1;
            else
                state_a <= 4'd0;
            // And make sure to reset any 6 button stuff
            frsta <= 1'b0; // no longer running
            delay_a <= 16'd0; // no timer just if changed
        end
    end
    // Get status changes next clock
    stra_j  <= msx_stra;

    //Rinse and repeat for Joystick B
    holdstatechangeb = 1'b0;
    // First, let's see if we are waiting some delay to reset state
    if (delay_b != 16'd0)
        // Decrement delay counter
        delay_b <= delay_b - 1;

    // Still an 8 buttons joystick ? No Delay? Timer was set to run?
    if ((j2_sixbutton_v == 1'b1)&&(j2_twobutton_v == 1'b0)&&(delay_b == 16'd0)&&(frstb == 1'b1)) begin
        frstb <= 1'b0; // no longer running
        holdstatechangeb = 1'b1; // No check for state change
        // Back to state 0 or 1
        if (!msx_strb)
        begin
            strb_j <= 1'b0;
            state_b <= 4'd0; // Back to 0, simulate no change so state doesn't increment state counter
        end
        else begin
            strb_j <= 1'b1;
            state_b <= 4'd1; // Back to 1, simulate no change so state doesn't increment state counter
        end
    end
    else if ((j2_sixbutton_v == 1'b0)||(j2_twobutton_v == 1'b1)) begin
        frstb <= 1'b0; // no longer running
        delay_b <= 16'd0; // no timer just if changed
    end

    // Increase state on change of strobe
    if ((strb_j != msx_strb)&&(!holdstatechangeb)) begin
        // Eight Buttons Joystick?
        if ((j2_sixbutton_v == 1'b1)&&(j2_twobutton_v == 1'b0)) begin
            // Yeah, have we started running the timer to reset state? And are we at state 0?
            if ((frstb == 1'b0)&&(state_b == 4'd0)) begin
                // No, so let's do it
                delay_b <= TIMECLK_J;
                frstb <= 1'b1;
            end
            // 8 buttons joy will leap over to state 0 after state 7
            if (state_b == 4'd7)
                state_b <= 4'd0;
            // Otherwise just increment state
            else
                state_b <= state_b + 1;
        end
        // Not eight buttons
        else begin
            // 4 and 2 buttons joy will handle only state 0 or 1
            if (state_b == 4'd0)
                state_b <= 4'd1;
            else
                state_b <= 4'd0;
            // And make sure to reset any 6 button stuff
            frstb <= 1'b0; // no longer running
            delay_b <= 16'd0; // no timer just if changed
        end
    end
    // Get status changes next clock
    strb_j  <= msx_strb;

    case (state_a)
        8'd0:
            begin
                // Always return this for all types when MSX strobe is low and state is 0
                joya <= {joy1_s[5], joy1_s[4], joy1_s[0], joy1_s[1], joy1_s[2], joy1_s[3]};
            end
        8'd1:
            begin
                if (j1_twobutton_v == 1'd0)
                    // All Mega joysticks will return LEFT+RIGHT pressed , real UP and DOWN and A and START
                    joya <= {joy1_s[7], joy1_s[6], joy1_s[0], joy1_s[1], 1'b0, 1'b0};
                else
                    // Always return this for 2 buttons
                    joya <= {1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1};
            end
        8'd2:
            begin
                // 8 buttons from now on, 2nd strobe change is the same as state 0 with C B U D L R
                joya <= {joy1_s[5], joy1_s[4], joy1_s[0], joy1_s[1], joy1_s[2], joy1_s[3]};
            end
        8'd3:
            begin
                // 8 buttons from now on, 3rd strobe change is the same as state 1 with S A U D 0 0
                joya <= {joy1_s[7], joy1_s[6], joy1_s[0], joy1_s[1], 1'b0, 1'b0};
            end
        8'd4:
            begin
                // 8 buttons from now on, 4th strobe change is the same as state 0 with C B U D L R
                joya <= {joy1_s[5], joy1_s[4], joy1_s[0], joy1_s[1], joy1_s[2], joy1_s[3]};
            end
        8'd5:
            begin
                // 8 buttons from now on, 5th strobe change is S A 0 0 0 0
                joya <= {joy1_s[7], joy1_s[6], 1'b0, 1'b0, 1'b0, 1'b0};
            end
        8'd6:
            begin
                // 8 buttons from now on, 6th strobe change is C B Z Y X M
                joya <= {joy1_s[5], joy1_s[4], joy1_s[8], joy1_s[9], joy1_s[10], joy1_s[11]};
            end
        8'd7:
            begin
                // 8 buttons from now on, 7th strobe change is S A 1 1 1 1
                joya <= {joy1_s[7], joy1_s[6], 1'b1, 1'b1, 1'b1, 1'b1};
            end
        default:
            begin
                // Shouldn't be here, leave open
                joya <= {1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1};
            end
    endcase
    // Repeat and rinse for Joy B
    case (state_b)
        8'd0:
            begin
                // Always return this for all types when MSX strobe is low and state is 0
                joyb <= {joy2_s[5], joy2_s[4], joy2_s[0], joy2_s[1], joy2_s[2], joy2_s[3]};
            end
        8'd1:
            begin
                if (j2_twobutton_v == 1'd0)
                    // All Mega joysticks will return LEFT+RIGHT pressed , real UP and DOWN and A and START
                    joyb <= {joy2_s[7], joy2_s[6], joy2_s[0], joy2_s[1], 1'b0, 1'b0};
                else
                    // Always return this for 2 buttons
                    joyb <= {1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1};
            end
        8'd2:
            begin
                // 8 buttons from now on, 2nd strobe change is the same as state 0 with C B U D L R
                joyb <= {joy2_s[5], joy2_s[4], joy2_s[0], joy2_s[1], joy2_s[2], joy2_s[3]};
            end
        8'd3:
            begin
                // 8 buttons from now on, 3rd strobe change is the same as state 1 with S A U D 0 0
                joyb <= {joy2_s[7], joy2_s[6], joy2_s[0], joy2_s[1], 1'b0, 1'b0};
            end
        8'd4:
            begin
                // 8 buttons from now on, 4th strobe change is the same as state 0 with C B U D L R
                joyb <= {joy2_s[5], joy2_s[4], joy2_s[0], joy2_s[1], joy2_s[2], joy2_s[3]};
            end
        8'd5:
            begin
                // 8 buttons from now on, 5th strobe change is S A 0 0 0 0
                joyb <= {joy2_s[7], joy2_s[6], 1'b0, 1'b0, 1'b0, 1'b0};
            end
        8'd6:
            begin
                // 8 buttons from now on, 6th strobe change is C B Z Y X M
                joyb <= {joy2_s[5], joy2_s[4], joy2_s[8], joy2_s[9], joy2_s[10], joy2_s[11]};
            end
        8'd7:
            begin
                // 8 buttons from now on, 7th strobe change is S A 1 1 1 1
                joyb <= {joy2_s[7], joy2_s[6], 1'b1, 1'b1, 1'b1, 1'b1};
            end
        default:
            begin
                // Shouldn't be here, leave open
                joyb <= {1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1};
            end
    endcase
end

reg [7:0] pump_s    = 8'b11111111;
PumpSignal PumpSignal (clk_sys, ~pll_locked, sd_flg, pump_s);

//-----------------------------------------------------------------

assign LED          = ~leds[0];

`include "build_id.v"
parameter CONF_STR = {
//    "D,disable STM SD;",
    "P,INIT;",
    "I1,IMG/VHD,Load Image...;",
    "OAB,Scanlines,Off,25%,50%,75%;",                           // No SD, F12 pops up 00, Off
    "OC,Blend,Off,On;",                                         // No SD, F12 pops up 0, Off
    "O1,Scandoubler,On,Off;",                                   // No SD, F12 pops up 0, On
    "O8,RGB/Comp or LED/CRT,1st,2nd;",                          // No SD, F12 pops up 0, RGB or LED (invert if status 1 = 0)
    "O2,CPU Clock,Normal,Turbo;",                               // No SD, F12 pops up 0, Normal
    "O3,Slot1,MegaSCC+ 1MB,External;",                          // No SD, F12 pops up 0, MegaSCC+
    "O45,Slot2,MegaSCC+ 2MB,External,MegaRAM 2MB,MegaRAM 1MB;", // No SD, F12 pops up 00, inverts 5 to have 00 = MEGASCC+
    "O6,RAM,4096kB,2048kB;",                                    // No SD, F12 pops up 0, 4096
    "O9,Mega SD,On,Off;",                                       // No SD, F12 pops up 0, Enabled
    "OEF,Keymap,BR,EN,ES,FR;",                                  // No SD, F12 pops up 00, BR
    "O7,OPL3 sound,Yes,No;",                                    // No SD, F12 pops up 0, invert to enable
    "OD,OPL3 stereo,Yes,No;",                                   // No SD, F12 pops up 0, mono off, stereo yes
    "OGH,Paddle using mouse,No,Vaus,MSX;",                      // No SD, F12 pops up 00, paddle emulation off
    "OI,ZX Next Expansion,No,Yes;",                             // No SD, F12 pops up 0, do not try to use ZX Next Expansion
    "T0,Reset;"
};

////////////////////   CLOCKS   ///////////////////

wire        pll_locked;
wire        clk_sys;
wire        memclk;

//////////////////   MC2P I/O   ///////////////////
wire  [1:0] buttons;
wire [63:0] status;
wire        ypbpr;
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
wire [63:0] rtc;
wire sd_sclk_o_s, sd_cs_n_o_s, sd_mosi_o_s, sd_miso_i_s;

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
wire [5:0]  msx_joyb;
wire        msx_stra;
wire        msx_strb;
wire [1:0]  msx_joy1_out;
wire        Sd_Ck;
wire        Sd_Cm;
wire [3:0]  Sd_Dt;
reg  [7:0]  dipsw;
wire [7:0]  leds;

reg         reset;
wire        resetW = status[0] | ~btn_n_i[4] | img_mounted | (PoR_counter != 25'd0) | ext_cart_reset_s;

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

wire   joy1_p6_io, joy1_p7_io;
assign joy1_p6_io = msx_joy1_out[0];
assign joy1_p7_io = msx_joy1_out[1];

always @(posedge clk_sys) begin
reg        mouse_en_old = 1'b0;
reg  [1:0] paddl_en_old = 2'b00;
reg        clock_div_5 = 1'b0;
reg [20:0] port_a_disc_time = 21'd0;

    reset <= resetW;
    dipsw <= {status[9], status[6], ~status[5], status[4], status[3], status[1] ? status[8] : ~status[8], status[1], ~status[2]};
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
                                            mouse : joya
                       : '1;
assign      msx_joyb =                    joyb;
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
        .pClk21m         ( clock_50_i    ),
        .pExtClk         ( 1'b0          ),

        // SD-RAM ports
        .pMemClk         ( memclk        ),
        .pSdrClk         ( clk_sdram     ),
        .pMemCke         ( SDRAM_CKE     ),
        .pMemCs_n        ( SDRAM_nCS     ),
        .pMemRas_n       ( SDRAM_nRAS    ),
        .pMemCas_n       ( SDRAM_nCAS    ),
        .pMemWe_n        ( SDRAM_nWE     ),
        .pMemUdq         ( SDRAM_DQMH    ),
        .pMemLdq         ( SDRAM_DQML    ),
        .pMemBa0         ( SDRAM_BA[0]   ),
        .pMemBa1         ( SDRAM_BA[1]   ),
        .pMemAdr         ( SDRAM_A       ),
        .pMemDat         ( SDRAM_DQ      ),

        // PS/2 keyboard ports
        .pPs2Clk         ( ps2_clk_io    ),
        .pPs2Dat         ( ps2_data_io   ),

        // Joystick ports (Port_A, Port_B)
        .pJoyA_in        ( {msx_joya[5:4],
                            msx_joya[0],
                            msx_joya[1],
                            msx_joya[2],
                            msx_joya[3]} ),
        .pStra           ( msx_stra      ),
        // WARNING!!! Unlike SM-X / OCM this
        // is not bi-dir, so it is 1 or 0.
        // This is needed as it is not connected
        // externally to receive a pull-up, unlike
        // on SM-X or OCM.
        .pJoyA_out       ( msx_joy1_out  ),
        .pJoyB_in        ( {msx_joyb[5:4],
                            msx_joyb[0],
                            msx_joyb[1],
                            msx_joyb[2],
                            msx_joyb[3]} ),
        .pStrb           ( msx_strb      ),

        // SD/MMC slot ports
        .pSd_Ck          ( Sd_Ck         ),
        .pSd_Cm          ( Sd_Cm         ),
        .pSd_Dt          ( Sd_Dt         ),

        // DIP switch, Lamp ports
        .pDip            ( dipsw         ),
        .pLed            ( leds          ),

        // Video, Audio/CMT ports
        .pDac_VR         ( R_O           ), // RGB_Red / Svideo_C
        .pDac_VG         ( G_O           ), // RGB_Grn / Svideo_Y
        .pDac_VB         ( B_O           ), // RGB_Blu / CompositeVideo
        .pVideoHS_n      ( HSync         ), // HSync(RGB15K, VGA31K)
        .pVideoVS_n      ( VSync         ), // VSync(RGB15K, VGA31K)

        .pDac_SL         ( audio_l       ),
        .pDac_SR         ( audio_r       ),

        // MC2P Exclusive
        .pll_locked      ( pll_locked    ),
        .osd_o           ( osd_s         ),
        .opl3_enabled    ( ~status[7]    ),
        .opl3_mono       ( status[13]    ),
        .EnAltMap        ( { status[14],
                             status[15]} ),

        // Slots
        .pCpuClk         ( slot_CLOCK_o  ),
        .pSltRst_n       ( ~reset        ),

        .pSltAdr         ( ext_cart_a    ),
        .pSltDat         ( sram_data_io  ),

        .pSltMerq_n      ( slot_MREQ_o   ),
        .pSltIorq_n      ( slot_IOREQ_o  ),
        .pSltRd_n        ( slot_RD_o     ),
        .pSltWr_n        ( slot_WR_o     ),

        .pSltRfsh_n      ( slot_RFSH_i   ),
        .pSltWait_n      ( slot_WAIT_i   ),
        .pSltInt_n       ( GPIO[27]      ),
        .pSltM1_n        ( slot_M1_o     ),

        .pSltBdir_n      ( slot_BUSDIR_i ),
        .pSltSltsl_n     ( slot_SLOT1_o  ),
        .pSltSlts2_n     ( slot_SLOT2_o  ),
        .pSltCs1_n       ( slot_CS1_o    ),
        .pSltCs2_n       ( slot_CS2_o    ),
        .pSltCs12_n      ( slot_CS12_o   ),

        // SM-X
        .clk21m_out      ( clk_sys       ),
        .esp_rx_o        ( esp_rx_o      ),
        .esp_tx_i        ( esp_tx_i      ),
        .ear_i           ( ear_i         ),
        .mic_o           ( mic_o         ),
        .midi_o          ( midi_o_s      ),
        .midi_active_o   ( midi_active_s )
);



//////////////////   VIDEO   //////////////////
wire  [5:0] R_O;
wire  [5:0] G_O;
wire  [5:0] B_O;
wire        HSync, VSync, CSync;

wire [5:0]  osd_r_o, osd_g_o, osd_b_o;

mist_video #( .OSD_COLOR ( 3'b001 )) mist_video_inst
(
    .clk_sys     ( memclk ), //clk_sys ),
    .scanlines   ( status[11:10] ),
    .rotate      ( 2'b00 ),
    .scandoubler_disable  ( 1'b1 ),
    .ce_divider  ( 1'b0 ), //1 para clk_sys ou 0 com clksdram para usar blend
    .blend       ( status[12] ),
    .no_csync    ( 1'b1 ),

    .SPI_SCK     ( SPI_SCK ),
    .SPI_SS3     ( SPI_SS2 ),
    .SPI_DI      ( SPI_DI ),

    .HSync       ( HSync ),
    .VSync       ( VSync ),
    .R           ( R_O ),
    .G           ( G_O ),
    .B           ( B_O ),

    .VGA_HS      ( VGA_HS ),
    .VGA_VS      ( VGA_VS ),
    .VGA_R       ( VGA_R ),
    .VGA_G       ( VGA_G ),
    .VGA_B       ( VGA_B ),

    .osd_enable  ( )
);

assign AUDIO_L      = audio_li[0];
assign AUDIO_R      = audio_ri[0];

//////////////////   Expansion #02   //////////////////
wire        ext_cart_detect, ext_cart_detect_db, ext_lvc_oe, ext_lvc_dir;
wire        ext_cart_detect_r, ext_cart_reset_s;
reg [15:0]  ext_cart_reset_cnt = 16'b1111111111111111;

wire [7:0]  ext_cart_d, cpu_do_s;
wire [15:0] ext_cart_a, cpu_a_s;
wire        ext_cs, ext_rd, ext_wr, ext_reset, ext_clock, ext_wait;
wire        cpu_rd_s, cpu_wr_s;

wire        sw1, sw2, cs1,cs2,cs12;
wire        slot_SLOT1_o, slot_SLOT2_o, slot_SLOT3_o;
wire        slot_CS1_o, slot_CS2_o, slot_CS12_o;
wire        slot_IOREQ_o, slot_MREQ_o, slot_RD_o, slot_WR_o, slot_M1_o;
wire        slot_RFSH_i, slot_WAIT_i, slot_INT_i, slot_BUSDIR_i;
wire        slot_CLOCK_o, slot_RESET_o, slot_RESET_io;

wire        esp_rx_o, esp_tx_i;

//--- alias
assign ext_cart_detect =    status[18]           ? 1'b1             : GPIO[5];

assign GPIO[13]        =  ( ext_cart_detect_db ) ? ext_lvc_dir      : 1'bZ;
assign GPIO[12]        =  ( ext_cart_detect_db ) ? ext_lvc_oe       : 1'bZ;
        
assign esp_tx_i        =  ( ext_cart_detect_db ) ?
                                                GPIO[7] :
                                                    ( status[18] ) ?
                                                        GPIO[0] :
                                                        1'bZ;
assign GPIO[1]         =  ( status[18]         ) ? esp_rx_o         : 1'bZ;
assign GPIO[11]        =  ( ext_cart_detect_db ) ? esp_rx_o         : 1'bZ;

assign sram_addr_o[4]  =  ( ext_cart_detect_db ) ? ext_cart_a[0]    : 1'bZ;
assign sram_addr_o[5]  =  ( ext_cart_detect_db ) ? ext_cart_a[1]    : 1'bZ;
assign sram_addr_o[2]  =  ( ext_cart_detect_db ) ? ext_cart_a[2]    : 1'bZ;
assign sram_addr_o[3]  =  ( ext_cart_detect_db ) ? ext_cart_a[3]    : 1'bZ;
assign sram_addr_o[0]  =  ( ext_cart_detect_db ) ? ext_cart_a[4]    : 1'bZ;
assign sram_addr_o[1]  =  ( ext_cart_detect_db ) ? ext_cart_a[5]    : 1'bZ;
assign sram_addr_o[10] =  ( ext_cart_detect_db ) ? ext_cart_a[6]    : 1'bZ;
assign sram_addr_o[11] =  ( ext_cart_detect_db ) ? ext_cart_a[7]    : 1'bZ;
assign sram_addr_o[8]  =  ( ext_cart_detect_db ) ? ext_cart_a[8]    : 1'bZ;
assign sram_addr_o[15] =  ( ext_cart_detect_db ) ? ext_cart_a[9]    : 1'bZ;
assign sram_addr_o[12] =  ( ext_cart_detect_db ) ? ext_cart_a[10]   : 1'bZ;
assign sram_addr_o[13] =  ( ext_cart_detect_db ) ? ext_cart_a[11]   : 1'bZ;
assign sram_addr_o[9]  =  ( ext_cart_detect_db ) ? ext_cart_a[12]   : 1'bZ;
assign sram_addr_o[6]  =  ( ext_cart_detect_db ) ? ext_cart_a[13]   : 1'bZ;
assign sram_addr_o[7]  =  ( ext_cart_detect_db ) ? ext_cart_a[14]   : 1'bZ;
assign sram_addr_o[14] =  ( ext_cart_detect_db ) ? ext_cart_a[15]   : 1'bZ;

assign GPIO[21]        =  ( ext_cart_detect_db ) ? slot_SLOT1_o     : 1'bZ;
assign GPIO[22]        =  ( ext_cart_detect_db ) ? slot_SLOT2_o     : 1'bZ;
assign GPIO[26]        =  ( ext_cart_detect_db ) ? slot_SLOT3_o     : 1'bZ;

assign GPIO[25]        =  ( ext_cart_detect_db ) ? slot_CS1_o       : 1'bZ;
assign GPIO[24]        =  ( ext_cart_detect_db ) ? slot_CS2_o       : 1'bZ;
assign GPIO[23]        =  ( ext_cart_detect_db ) ? slot_CS12_o      : 1'bZ;

assign sram_addr_o[16] =  ( ext_cart_detect_db ) ? slot_MREQ_o      : 1'bZ;
assign GPIO[18]        =  ( ext_cart_detect_db ) ? slot_IOREQ_o     : 1'bZ;
assign GPIO[16]        =  ( ext_cart_detect_db ) ? slot_RD_o        : 1'bZ;
assign GPIO[14]        =  ( ext_cart_detect_db ) ? slot_WR_o        : 1'bZ;
assign GPIO[19]        =  ( ext_cart_detect_db ) ? slot_M1_o        : 1'bZ;

assign sw1             =  ( ext_cart_detect_db ) ? GPIO[8]          : 1'bZ;
assign sw2             =  ( ext_cart_detect_db ) ? GPIO[6]          : 1'bZ;
assign slot_WAIT_i     =  ( ext_cart_detect_db ) ? GPIO[29]         : 1'bZ;
assign slot_BUSDIR_i   =  ( ext_cart_detect_db ) ? GPIO[31]         : 1'bZ;

assign GPIO[10]        =  ( ext_cart_detect_db ) ? slot_CLOCK_o     : 1'bZ;

assign ext_lvc_oe      =  ( ext_cart_detect_db  == 1'b0 ) ? 1'b1 : (slot_SLOT1_o == 1'b0) ? 1'b0 : (slot_SLOT2_o == 1'b0) ? 1'b0 : (slot_IOREQ_o == 1'b0 && slot_BUSDIR_i == 1'b0) ? 1'b0 : 1'b1;
assign ext_lvc_dir     =  ( ext_cart_detect_db  == 1'b0 ) ? 1'b0 : ~slot_RD_o; // port A=SLOT, B=FPGA     DIR(1)=A to B   

assign slot_SLOT3_o    =  slot_SLOT1_o;

//clear the inputs tri-state I/Os
assign GPIO[8:5]       =  4'bzzzz;
assign GPIO[29]        =  1'bz;
assign GPIO[31]        =  1'bz;

debounce #(23) debounce
(
    .clk_i     ( clk_sys ),
    .button_i  ( ~ext_cart_detect ),
    .result_o  ( ext_cart_detect_db )
);

// Reset when the external module is turned on or off
always @ (posedge clk_sys)
    begin

          ext_cart_detect_r <= ext_cart_detect_db;

          if ((ext_cart_detect_db == 1'b0 && ext_cart_detect_r == 1'b1) ||
              (ext_cart_detect_db == 1'b1 && ext_cart_detect_r == 1'b0)) // reset signal on edges
             ext_cart_reset_cnt <= 16'b1111111111111111;


          if (ext_cart_reset_cnt > 16'd0)
            begin
                ext_cart_reset_s <= 1'b1;
                ext_cart_reset_cnt <= ext_cart_reset_cnt - 1;
            end
          else
            ext_cart_reset_s <= 1'b0;
end

endmodule