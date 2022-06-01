//============================================================================
//
//  Hard reset signal for the Data Pump start
//
//  Victor Trucco - 2020
//
//============================================================================

`default_nettype none

module PumpSignal
(
    input wire  clk_i,
    input wire  reset_i,   
    input wire  download_i,       
    output reg [7:0] pump_o
);

reg [15:0] power_on_s   = 16'b1111111111111111;

//--start the microcontroller OSD menu after the power on
always @(posedge clk_i) 
begin

        if (reset_i == 1'b1)
            power_on_s = 16'b1111111111111111;
        else if (power_on_s != 0)
        begin
            power_on_s = power_on_s - 1'b1;
            pump_o = 8'b00111111;
        end 

        if (download_i == 1 && pump_o == 8'b00111111)
            pump_o = 8'b11111111;
end 

endmodule
