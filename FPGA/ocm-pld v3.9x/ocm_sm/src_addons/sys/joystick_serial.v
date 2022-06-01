/*
  
   Multicore 2 / Multicore 2+
  
   Copyright (c) 2017-2020 - Victor Trucco

  
   All rights reserved
  
   Redistribution and use in source and synthezised forms, with or without
   modification, are permitted provided that the following conditions are met:
  
   Redistributions of source code must retain the above copyright notice,
   this list of conditions and the following disclaimer.
  
   Redistributions in synthesized form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
  
   Neither the name of the author nor the names of other contributors may
   be used to endorse or promote products derived from this software without
   specific prior written permission.
  
   THIS CODE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
   AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
   THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
   PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
   LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
   INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
   ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
   POSSIBILITY OF SUCH DAMAGE.
  
   You are responsible for any legal issues arising from your use of this code.
  
*/
module joystick_serial
(
    input  wire clk_i,     //Master clock
    input  wire joy_data_i,
    output wire joy_clk_o,  
    output wire joy_load_o, 

    output wire joy1_up_o,
    output wire joy1_down_o,
    output wire joy1_left_o,
    output wire joy1_right_o,
    output wire joy1_fire1_o,
    output wire joy1_fire2_o,

    output wire joy2_up_o,
    output wire joy2_down_o,
    output wire joy2_left_o,
    output wire joy2_right_o,
    output wire joy2_fire1_o,
    output wire joy2_fire2_o
);

wire clk_en;
reg [1:0]clk_cnt = 2'd0;
always @(posedge clk_i)
begin
    clk_cnt <= clk_cnt + 2'd1;
end
assign clk_en = clk_cnt[1];

reg [11:0] joy1  = 12'hFFF;
reg [11:0] joy2  = 12'hFFF;   
reg joy_renew = 1'b1;
reg [4:0]joy_count = 5'd0;

assign joy_clk_o    = clk_en;
assign joy_load_o   = joy_renew;

assign joy1_up_o    = joy1[0];     
assign joy1_down_o  = joy1[1];
assign joy1_left_o  = joy1[2];
assign joy1_right_o = joy1[3];
assign joy1_fire1_o = joy1[4];
assign joy1_fire2_o = joy1[5];
assign joy2_up_o    = joy2[0];   
assign joy2_down_o  = joy2[1];
assign joy2_left_o  = joy2[2];
assign joy2_right_o = joy2[3];
assign joy2_fire1_o = joy2[4];
assign joy2_fire2_o = joy2[5];

reg [1:0] clk_enab;

always @(posedge clk_i) 
begin 

    clk_enab <= {clk_enab[0], clk_en};

    if ( clk_enab == 2'b01 )
        begin

        if (joy_count == 5'd0) 
          begin
           joy_renew <= 1'b0;
          end 
        else 
          begin
           joy_renew <= 1'b1;
          end

        if (joy_count == 5'd16) 
          begin
             joy_count <= 5'd0;
          end
        else 
          begin
             joy_count <= joy_count + 1'd1;
          end   

        case (joy_count)
            5'd15 : joy1[0]  <= joy_data_i;   //  1p up
            5'd14 : joy1[4]  <= joy_data_i;   //  1p fire1
            5'd13 : joy1[1]  <= joy_data_i;   //  1p down
            5'd12 : joy1[2]  <= joy_data_i;   //  1p left
            5'd11 : joy1[3]  <= joy_data_i;   //  1p right
            5'd10 : joy1[5]  <= joy_data_i;   //  1p fire2

            5'd7  : joy2[0]  <= joy_data_i;   //  2p up
            5'd6  : joy2[4]  <= joy_data_i;   //  2p fire1
            5'd5  : joy2[1]  <= joy_data_i;   //  2p down
            5'd4  : joy2[2]  <= joy_data_i;   //  2p left
            5'd3  : joy2[3]  <= joy_data_i;   //  2p right
            5'd2  : joy2[5]  <= joy_data_i;   //  2p fire2
        endcase 
    end
end
endmodule