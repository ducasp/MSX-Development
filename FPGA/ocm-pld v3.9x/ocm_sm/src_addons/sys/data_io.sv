//
// data_io.v
//
// data_io for the MiST board
// http://code.google.com/p/mist-board/
//
// Copyright (c) 2014 Till Harbaum <till@harbaum.org>
//
// This source file is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This source file is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
///////////////////////////////////////////////////////////////////////

module data_io # ( parameter STRLEN =   0 )
(
    input             clk_sys,
    input             SPI_SCK,
    input             SPI_SS2,
    input             SPI_DI,
    output            SPI_DO,
    
    input      [ 7:0] data_in,
    input      [(8*STRLEN)-1:0] conf_str,
    output reg [63:0] status,
    output reg [ 7:0] config_buffer_o[15:0],  // 15 bytes for general use
    output reg [ 6:0] core_mod, // core variant, sent before the config string is requested
    output reg        sd_flag,

        
    // ARM -> FPGA download
    input             ioctl_wait,
    output reg        ioctl_download = 0, // signal indicating an active download
    output reg  [7:0] ioctl_index,        // menu index used to upload the file
    output            ioctl_wr,
    output reg [24:0] ioctl_addr,
    output reg  [7:0] ioctl_dout,
    
    //------------------------------------

    // connection to sd card emulation
    input               clk_sd,  // clock for SD-card related messages
    input        [31:0] sd_lba,
    input         [1:0] sd_rd,
    input         [1:0] sd_wr,
    output reg          sd_ack,
    output reg          sd_ack_conf,
    input               sd_conf,
    input               sd_sdhc,
    output reg    [7:0] sd_dout, // valid on rising edge of sd_dout_strobe
    output reg          sd_dout_strobe,
    input         [7:0] sd_din,
    output reg          sd_din_strobe, //rising edge when sd_din was read (so we can advance to another addr)
    output reg    [8:0] sd_buff_addr,

    output reg    [1:0] img_mounted, // rising edge if a new image is mounted
    output reg   [31:0] img_size,    // size of image in bytes

    output reg          external_sd_disabled = 0 //read the DIS_SD on .INI file
    
);
/////////////////////////////// SD

wire drive_sel = sd_rd[1] | sd_wr[1];
// command byte read by the io controller
wire [7:0] sd_cmd = { 4'h6, sd_conf, sd_sdhc, sd_wr[drive_sel], sd_rd[drive_sel] };

///////////////////////////////   DOWNLOADING   ///////////////////////////////

reg [ 7:0] data_w;
reg [24:0] addr_w;
reg        rclk = 0;
reg        sdo_s;
reg [7:0] sd_din_r;

assign SPI_DO = sdo_s;

localparam UIO_FILE_TX      = 8'h53;
localparam UIO_FILE_TX_DAT  = 8'h54;
localparam UIO_FILE_INDEX   = 8'h55;

reg [ 7:0] ACK = 8'd75; // letter K - 0x4b
reg [ 7:0] DIS_SD = 8'd01;
reg [10:0] byte_cnt;   // counts bytes
reg [ 7:0] cmd;
reg [ 4:0] cnt;
    
// SPI MODE 0 : incoming data on Rising, outgoing on Falling
always@(negedge SPI_SCK, posedge SPI_SS2) 
begin
        reg [31:0] sd_lba_r;
        reg  [7:0] drive_sel_r;
    
    //each time the SS goes down, we will receive a command from the SPI master
    if (SPI_SS2) // not selected
    begin
        sdo_s    <= 1'bZ;
        byte_cnt <= 11'd0;
        sd_din_r <= sd_din;
    end
    else
    begin

        if (cmd == 8'h10 ) //command 0x10 - send the data to the microcontroller
            sdo_s <= data_in[~cnt[2:0]];

        else if (cmd == 8'h00 ) //command 0x00 - ACK
            sdo_s <= ACK[~cnt[2:0]];

        //  else if (cmd == 8'h61 ) //command 0x61 - echo the pumped data
        //      sdo_s <= sram_data_s[~cnt[2:0]];          

        else if(cmd == 8'h14) //command 0x14 - reading config string
        begin

            if(byte_cnt < STRLEN + 1 ) // returning a byte from string
                sdo_s <= conf_str[{STRLEN - byte_cnt,~cnt[2:0]}];
            else
                sdo_s <= 1'b0;
        end 

         // --------------- SD related -------------------
                            else if(cmd == 8'h18) //command 0x18 -  reading sd card write data
                            begin
                                sdo_s <= sd_din_r[~cnt[2:0]];

                                if (cnt[2:0]==3'd7) sd_din_r <= sd_din;
                            end 

                             else if(cmd == 8'h16) //command 0x16 - reading sd card status
                                begin
                                    if(byte_cnt == 0 || byte_cnt == 1) begin
                                        sdo_s <= sd_cmd[~cnt[2:0]];
                                        sd_lba_r <= sd_lba;
                                        drive_sel_r <= {7'b0, drive_sel};
                                    end 
                                    else if(byte_cnt == 2) sdo_s <= drive_sel_r[~cnt[2:0]];
                                    else if(byte_cnt < 7) sdo_s <= sd_lba_r[{ 6-byte_cnt, ~cnt[2:0] }]; // sd_lba_r[(5-byte_cnt)<<3 +:8];
                                end
                                

        if(cnt[2:0] == 7) 
            byte_cnt <= byte_cnt + 11'd1;

    end
end
    

// data_io has its own SPI interface to the io controller
always@(posedge SPI_SCK, posedge SPI_SS2) begin
    reg [ 6:0] sbuf;
    reg [24:0] addr;
    reg [ 4:0] cnf_byte;

    if(SPI_SS2) 
    begin
        cnt <= 0;
        cnf_byte <= 4'd15;
    end
    else begin
        rclk <= 0;

        // don't shift in last bit. It is evaluated directly
        // when writing to ram
        if(cnt != 15) sbuf <= { sbuf[5:0], SPI_DI};

        // increase target address after write
        if(rclk) addr <= addr + 1'd1;

        // count 0-7 8-15 8-15 ... 
        if(cnt < 15) cnt <= cnt + 1'd1;
            else cnt <= 8;

        // finished command byte
        if(cnt == 7) 
        begin 
            cmd <= {sbuf, SPI_DI};
        
        
                // command 0x61: start the data streaming
                if(sbuf[6:0] == 7'b0110000 && SPI_DI == 1'b1)
                begin
                    //addr <= 0; //nao pode estar aqui, senao zera o endereço a cada ciclo de dados tem que estar no 0x60
                    ioctl_download <= 1;
                end
                
                // command 0x62: end the data streaming
                if(sbuf[6:0] == 7'b0110001 && SPI_DI == 1'b0)
                begin
                    //addr_w <= addr;
                    ioctl_download <= 0;
                end
        end
        
        if(cnt == 15) 
        begin 
        
                // command 0x15: stores the status word (menu selections)
                if (cmd == 8'h15)
                begin
                    case (cnf_byte) 

                        4'd15: status[31:24] <={sbuf, SPI_DI};
                        4'd14: status[23:16] <={sbuf, SPI_DI};
                        4'd13: status[15:8]  <={sbuf, SPI_DI};
                        4'd12: status[7:0]   <={sbuf, SPI_DI};
                        
                        4'd11: core_mod <= {sbuf[5:0], SPI_DI};

                        4'd10: external_sd_disabled <= SPI_DI;

                        4'd9: status[63:56] <={sbuf, SPI_DI};
                        4'd8: status[55:48] <={sbuf, SPI_DI};
                        4'd7: status[47:40] <={sbuf, SPI_DI};
                        4'd6: status[39:32] <={sbuf, SPI_DI};

                        4'd5: sd_flag <= SPI_DI;
                    endcase
                    
                    cnf_byte <= cnf_byte - 1'd1;

                end

            // command 0x60: stores a configuration byte
                if (cmd == 8'h60)
                begin
                        config_buffer_o[cnf_byte] <= {sbuf, SPI_DI};
                        cnf_byte <= cnf_byte - 1'd1;
                        
                        addr <= 0;
                end
                        
                // command 0x61: Data Pump 8 bits
                if (cmd == 8'h61) 
                begin
                        addr_w <= addr;
                        data_w <= {sbuf, SPI_DI};
                        rclk <= 1;
                end
        end
/*      
        // prepare/end transmission
        if((cmd == UIO_FILE_TX) && (cnt == 15)) begin
            // prepare 
            if(SPI_DI) begin
                addr <= 0;
                ioctl_download <= 1; 
            end else begin
                addr_w <= addr;
                ioctl_download <= 0;
            end
        end

        // command 0x54: UIO_FILE_TX
        if((cmd == UIO_FILE_TX_DAT) && (cnt == 15)) begin
            addr_w <= addr;
            data_w <= {sbuf, SPI_DI};
            rclk <= 1;
        end
        */

        // expose file (menu) index
        if((cmd == UIO_FILE_INDEX) && (cnt == 15)) ioctl_index <= {sbuf, SPI_DI};
    end
end

reg [1:0] ioctl_wrd;
assign ioctl_wr = |ioctl_wrd;

always@(negedge clk_sys) begin
    reg        rclkD, rclkD2;

    rclkD    <= rclk;
    rclkD2   <= rclkD;
    ioctl_wrd<= {ioctl_wrd[0],1'b0};

    if(rclkD & ~rclkD2) begin
        ioctl_dout <= data_w;
        ioctl_addr <= addr_w;
        ioctl_wrd  <= 2'b11;
    end

    //lock the write bit if the download is inactive
    if (~ioctl_download) ioctl_wrd <= 2'b00; 

end

/////////////////////////////////////////////////////////////////////////////////////
//
// SD emulation related
//
/////////////////////////////////////////////////////////////////////////////////////

// SPI bit and byte counters
reg [2:0]     bit_cnt;    // counts bits 0-7 0-7 ...
always@(posedge SPI_SCK or posedge SPI_SS2) begin : spi_counter
    if(SPI_SS2 == 1) begin
        bit_cnt <= 0;
      //  byte_cnt <= 0;
    end else begin
       // if((bit_cnt == 7)&&(~&byte_cnt))  byte_cnt <= byte_cnt + 8'd1;

        bit_cnt <= bit_cnt + 1'd1;
    end
end

// SPI receiver IO -> FPGA

reg       spi_receiver_strobe_r = 0;
reg       spi_transfer_end_r = 1;
reg [7:0] spi_byte_in;
reg [6:0]     bsbuf;

// Read at spi_sck clock domain, assemble bytes for transferring to clk_sys
always@(posedge SPI_SCK, posedge SPI_SS2) begin : spi_receiver

    if(SPI_SS2 == 1) begin
        spi_transfer_end_r <= 1;
    end else begin
        spi_transfer_end_r <= 0;

        if(bit_cnt != 7)
            bsbuf[6:0] <= { bsbuf[5:0], SPI_DI };

        // finished reading a byte, prepare to transfer to clk_sys
        if(bit_cnt == 7) begin
            spi_byte_in <= { bsbuf, SPI_DI};
            spi_receiver_strobe_r <= ~spi_receiver_strobe_r;
        end
    end
end

// Process SD-card related bytes from SPI at the clk_sd domain
always @(posedge clk_sd) begin : sd_block

    reg       spi_receiver_strobe;
    reg       spi_transfer_end;
    reg       spi_receiver_strobeD;
    reg       spi_transfer_endD;
    reg [1:0] sd_wrD;
    reg [7:0] acmd;
    reg [7:0] abyte_cnt;   // counts bytes

    reg       sd_ackD;

    //synchronize between SPI and sd clock domains
    spi_receiver_strobeD <= spi_receiver_strobe_r;
    spi_receiver_strobe <= spi_receiver_strobeD;
    spi_transfer_endD   <= spi_transfer_end_r;
    spi_transfer_end    <= spi_transfer_endD;

    sd_ackD <= sd_ack;

    if(sd_dout_strobe) begin
        sd_dout_strobe<= 0;
        if(~&sd_buff_addr) sd_buff_addr <= sd_buff_addr + 1'b1;
    end

    sd_din_strobe<= 0;
    sd_wrD <= sd_wr;

    img_mounted <= 0;

    // fetch the first byte immediately after the write command seen
    if ((~sd_wrD[0] & sd_wr[0]) || (~sd_wrD[1] & sd_wrD[1])) begin
       sd_buff_addr <= 0;
       sd_din_strobe <= 1;
    end

    if (acmd == 8'h18 && (~sd_ack & sd_ackD)) begin
       sd_buff_addr <= 0;
       sd_din_strobe <= 1;
    end
    else     if (spi_transfer_end) begin
        abyte_cnt <= 8'd0;
        sd_ack <= 1'b0;
        sd_ack_conf <= 1'b0;
        sd_dout_strobe <= 1'b0;
        sd_din_strobe <= 1'b0;
        sd_buff_addr <= 0;

    end else if (spi_receiver_strobeD ^ spi_receiver_strobe) begin

     //   if (cnt[2:0] == 8'd0) begin sd_din_r <= sd_din; end

        if(~&abyte_cnt) 
            abyte_cnt <= abyte_cnt + 8'd1;

        if(abyte_cnt == 0) begin
            acmd <= spi_byte_in;

            if(spi_byte_in == 8'h18) begin
                //sd_din_r <= sd_din;
                sd_din_strobe <= 1'b1;
                if(~&sd_buff_addr) sd_buff_addr <= sd_buff_addr + 1'b1;
            end

            if(spi_byte_in == 8'h19)
                sd_ack_conf <= 1'b1;
            if((spi_byte_in == 8'h17) || (spi_byte_in == 8'h18))
                sd_ack <= 1'b1;

        end else begin
            case(acmd)

                // send sector IO -> FPGA
                8'h17,
                // send SD config IO -> FPGA
                8'h19: begin
                    // flag that download begins
                    sd_dout_strobe <= 1'b1;
                    sd_dout <= spi_byte_in;
                end

                // send sector FPGA -> IO
                8'h18: begin
                    if(~&sd_buff_addr) begin
                     //   sd_din_r <= sd_din;
                        sd_din_strobe <= 1'b1;
                        sd_buff_addr <= sd_buff_addr + 1'b1;
                    end
                end

                8'h1c: img_mounted[spi_byte_in[0]] <= 1;

                // send image info
                8'h1d: if(abyte_cnt<5) img_size[(abyte_cnt-1)<<3 +:8] <= spi_byte_in;
            endcase
        end
    end
end


endmodule
