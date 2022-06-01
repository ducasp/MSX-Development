//
// scanlines.v
// 


module scanlines
(
    // system interface
    input            clk_sys,

    // scanlines (00-none 01-25% 10-50% 11-75%)
    input      [1:0] scanlines,
    input            ce_x2,

    // shifter video interface
    input            hs_in,
    input            vs_in,
    input      [5:0] r_in,
    input      [5:0] g_in,
    input      [5:0] b_in,

    // output interface
    output reg [5:0] r_out,
    output reg [5:0] g_out,
    output reg [5:0] b_out
);

// --------------------- create output signals -----------------
// latch everything once more to make it glitch free and apply scanline effect
reg scanline;
reg       hs_out;
reg       vs_out;

always @(posedge clk_sys) begin
    if(ce_x2) begin
        hs_out <= hs_in;
        vs_out <= vs_in;

        // reset scanlines at every new screen
        if(!vs_in) scanline <= 0;

        // toggle scanlines at begin of every hsync
        if(hs_out && !hs_in) scanline <= !scanline;

        // if no scanlines or not a scanline
        if(!scanline || !scanlines) begin
            r_out <= r_in;
            g_out <= g_in;
            b_out <= b_in;
        end else begin
            case(scanlines)
                1: begin // reduce 25% = 1/2 + 1/4
                    r_out <= {1'b0, r_in[5:1]} + {2'b00, r_in[5:2] };
                    g_out <= {1'b0, g_in[5:1]} + {2'b00, g_in[5:2] };
                    b_out <= {1'b0, b_in[5:1]} + {2'b00, b_in[5:2] };
                end

                2: begin // reduce 50% = 1/2
                    r_out <= {1'b0, r_in[5:1]};
                    g_out <= {1'b0, g_in[5:1]};
                    b_out <= {1'b0, b_in[5:1]};
                end

                3: begin // reduce 75% = 1/4
                    r_out <= {2'b00, r_in[5:2]};
                    g_out <= {2'b00, g_in[5:2]};
                    b_out <= {2'b00, b_in[5:2]};
                end
            endcase
        end
    end
end



endmodule
