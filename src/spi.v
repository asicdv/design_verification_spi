/*
 * Author:  Deepak Siddharth Parthipan
 *          RIT, NY, USA
 * Module:  spi
 */
//-----------------------------------------------------------------------------------
`include "src/spi_defines.v"
`include "src/timescale.v"
//-----------------------------------------------------------------------------------
module spi
(
  /*Wishbone signals*/
  reset, clk, wb_adr_i, wb_dat_i, wb_dat_o, wb_sel_i,
  wb_we_i, wb_stb_i, wb_cyc_i, wb_ack_o, wb_err_o, wb_int_o,

  /*SPI signals*/
  ss_pad_o, sclk_pad_o, mosi_pad_o, miso_pad_i,

  /*Scan Insertion*/  
  scan_in0, scan_en, test_mode, scan_out0, tip //,reset, clk wb_clk_i, wb_rst_i
);
/*----------------------------Wishbone signals--------------------------------------*/
  wire                            wb_clk_i;         // master clock input
  wire                            wb_rst_i;         // synchronous active high reset
  input                      [4:0] wb_adr_i;         // lower address bits
  input                   [32-1:0] wb_dat_i;         // databus input
  output                  [32-1:0] wb_dat_o;         // databus output
  input                      [3:0] wb_sel_i;         // byte select inputs
  input                            wb_we_i;          // write enable input
  input                            wb_stb_i;         // stobe/core select signal
  input                            wb_cyc_i;         // valid bus cycle input
  output                           wb_ack_o;         // bus cycle acknowledge output
  output                           wb_err_o;         // termination w/ error
  output                           wb_int_o;         // interrupt request signal output
/*---------------------------------SPI signals--------------------------------------*/                                                     
  output          [`SPI_SS_NB-1:0] ss_pad_o;         // slave select
  output                           sclk_pad_o;       // serial clock
  output                           mosi_pad_o;       // master out slave in
  input                            miso_pad_i;       // master in slave out
 input                          reset;            // system reset   
 input                          clk;              // system clock
  input                            scan_in0;         // test scan mode data input
  input                            scan_en;          // test scan mode enable
  input                            test_mode;        // test mode select
  output                           scan_out0;        // test scan mode data output
  output                           tip;
 /*--------------------------------------------------------------------------------*/                                                       
  reg                     [32-1:0] wb_dat_o;
  reg                     [32-1:0] wb_dat;
  reg                              wb_ack_o;
  reg                              wb_int_o;
  reg       [`SPI_CTRL_BIT_NB-1:0] ctrl;
  reg       [`SPI_DIVIDER_LEN-1:0] divider;
  reg             [`SPI_SS_NB-1:0] ss;
  reg                              scan_out0;                                                       
  // Internal signals
  wire         [`SPI_MAX_CHAR-1:0] rx;               // Rx register
  wire                             rx_negedge;       // miso is sampled on negative edge
  wire                             tx_negedge;       // mosi is driven on negative edge
  wire    [`SPI_CHAR_LEN_BITS-1:0] char_len;         // char len
  wire                             go;               // go
  wire                             lsb;              // lsb first on line
  wire                             ie;               // interrupt enable
  wire                             ass;              // automatic slave select
  wire                             spi_divider_sel;  // divider register select
  wire                             spi_ctrl_sel;     // ctrl register select
  wire                       [3:0] spi_tx_sel;       // tx_l register select
  wire                             spi_ss_sel;       // ss register select
  reg                              tip;              // transfer in progress
  wire                             pos_edge;         // recognize posedge of sclk
  wire                             neg_edge;         // recognize negedge of sclk
  wire                             last_bit;         // marks last character bit
//-----------------------------------------------------------------------------------  
  spi_clock_gen clock_gen (.clk_in(wb_clk_i), .rst(wb_rst_i), .go(go), .enable(tip), .last_clk(last_bit),
                           .divider(divider), .clk_out(sclk_pad_o), .pos_edge(pos_edge), 
                           .neg_edge(neg_edge)); 
                           //.scan_in0(scan_in0), .scan_en(scan_en), .test_mode(test_mode), .scan_out0(scan_out0), .reset(reset), .clk(clk));
//-----------------------------------------------------------------------------------  
  spi_shift shift (.clk_shift(wb_clk_i), .rst(wb_rst_i), .len(char_len[`SPI_CHAR_LEN_BITS-1:0]),
                   .latch(spi_tx_sel[3:0] & {4{wb_we_i}}), .byte_sel(wb_sel_i), .lsb(lsb), 
                   .go(go), .pos_edge(pos_edge), .neg_edge(neg_edge), .rx_negedge(rx_negedge), 
                   .tx_negedge(tx_negedge), .tip(tip), .last(last_bit),.p_in(wb_dat_i), .p_out(rx), 
                   .s_clk(sclk_pad_o), .s_in(miso_pad_i), .s_out(mosi_pad_o));
                   //.scan_in0(scan_in0), .scan_en(scan_en), .test_mode(test_mode), .scan_out0(scan_out0), .reset(reset), .clk(clk));
/*----------------------------------Address decoder-----------------------------------*/ 
  assign spi_divider_sel = wb_cyc_i & wb_stb_i & (wb_adr_i[`SPI_OFS_BITS] == `SPI_DIVIDE);
  assign spi_ctrl_sel    = wb_cyc_i & wb_stb_i & (wb_adr_i[`SPI_OFS_BITS] == `SPI_CTRL);
  assign spi_tx_sel[0]   = wb_cyc_i & wb_stb_i & (wb_adr_i[`SPI_OFS_BITS] == `SPI_TX_0);
  assign spi_tx_sel[1]   = wb_cyc_i & wb_stb_i & (wb_adr_i[`SPI_OFS_BITS] == `SPI_TX_1);
  assign spi_tx_sel[2]   = wb_cyc_i & wb_stb_i & (wb_adr_i[`SPI_OFS_BITS] == `SPI_TX_2);
  assign spi_tx_sel[3]   = wb_cyc_i & wb_stb_i & (wb_adr_i[`SPI_OFS_BITS] == `SPI_TX_3);
  assign spi_ss_sel      = wb_cyc_i & wb_stb_i & (wb_adr_i[`SPI_OFS_BITS] == `SPI_SS);

  assign wb_clk_i = clk;
  assign wb_rst_i = reset;
/*-----------------------------Read from registers-------------------------------------*/  
  always @(wb_adr_i or rx or ctrl or divider or ss)
  begin
    case (wb_adr_i[`SPI_OFS_BITS])
	`ifdef SPI_MAX_CHAR_128
      		`SPI_RX_0:    wb_dat = rx[31:0];
	      	`SPI_RX_1:    wb_dat = rx[63:32];
      		`SPI_RX_2:    wb_dat = rx[95:64];
      		`SPI_RX_3:    wb_dat = {{128-`SPI_MAX_CHAR{1'b0}}, rx[`SPI_MAX_CHAR-1:96]};
	`else
	`ifdef SPI_MAX_CHAR_64
      		`SPI_RX_0:    wb_dat = rx[31:0];
      		`SPI_RX_1:    wb_dat = {{64-`SPI_MAX_CHAR{1'b0}}, rx[`SPI_MAX_CHAR-1:32]};
      		`SPI_RX_2:    wb_dat = 32'b0;
      		`SPI_RX_3:    wb_dat = 32'b0;
	`else
      		`SPI_RX_0:    wb_dat = {{32-`SPI_MAX_CHAR{1'b0}}, rx[`SPI_MAX_CHAR-1:0]};
      		`SPI_RX_1:    wb_dat = 32'b0;
      		`SPI_RX_2:    wb_dat = 32'b0;
      		`SPI_RX_3:    wb_dat = 32'b0;
	`endif
	`endif
      		`SPI_CTRL:    wb_dat = {{32-`SPI_CTRL_BIT_NB{1'b0}}, ctrl};
      		`SPI_DIVIDE:  wb_dat = {{32-`SPI_DIVIDER_LEN{1'b0}}, divider};
      		`SPI_SS:      wb_dat = {{32-`SPI_SS_NB{1'b0}}, ss};
      default:      
		wb_dat = 32'bx;
    endcase
  end
/*---------------------------------Wb data out----------------------------------------*/  
  always @(posedge wb_clk_i or posedge wb_rst_i)
  begin
    if (wb_rst_i)
      wb_dat_o <=  32'b0;
    else
      wb_dat_o <=  wb_dat;
  end
/*------------------------------Wb acknowledge----------------------------------------*/  
  always @(posedge wb_clk_i or posedge wb_rst_i)
  begin
    if (wb_rst_i)
      wb_ack_o <=  1'b0;
    else
      wb_ack_o <=  wb_cyc_i & wb_stb_i & ~wb_ack_o;
  end
/*---------------------------------Wb error------------------------------------------*/  
  assign wb_err_o = 1'b0;
/*---------------------------------Interrupt-----------------------------------------*/   
  always @(posedge wb_clk_i or posedge wb_rst_i)
  begin
    if (wb_rst_i)
      wb_int_o <=  1'b0;
    else if (ie && tip && last_bit && pos_edge)
      wb_int_o <=  1'b1;
    else if (wb_ack_o)
      wb_int_o <=  1'b0;
  end
/*-------------------------------Divider register-------------------------------------*/ 
  always @(posedge wb_clk_i or posedge wb_rst_i)
  begin
    if (wb_rst_i)
        divider <=  {`SPI_DIVIDER_LEN{1'b0}};
    else if (spi_divider_sel && wb_we_i && !tip)
      begin
      	`ifdef SPI_DIVIDER_LEN_8
        	if (wb_sel_i[0])
          	  divider <=  wb_dat_i[`SPI_DIVIDER_LEN-1:0];
      	`endif
      	`ifdef SPI_DIVIDER_LEN_16
        	if (wb_sel_i[0])
          	  divider[7:0] <=  wb_dat_i[7:0];
       		if (wb_sel_i[1])
          	  divider[`SPI_DIVIDER_LEN-1:8] <=  wb_dat_i[`SPI_DIVIDER_LEN-1:8];
      	`endif
     	`ifdef SPI_DIVIDER_LEN_24
        	if (wb_sel_i[0])
          	  divider[7:0] <=  wb_dat_i[7:0];
        	if (wb_sel_i[1])
          	  divider[15:8] <=  wb_dat_i[15:8];
        	if (wb_sel_i[2])
          	  divider[`SPI_DIVIDER_LEN-1:16] <=  wb_dat_i[`SPI_DIVIDER_LEN-1:16];
      	`endif
      	`ifdef SPI_DIVIDER_LEN_32
        	if (wb_sel_i[0])
          	  divider[7:0] <=  wb_dat_i[7:0];
        	if (wb_sel_i[1])
          	  divider[15:8] <= wb_dat_i[15:8];
        	if (wb_sel_i[2])
          	  divider[23:16] <=  wb_dat_i[23:16];
        	if (wb_sel_i[3])
          	  divider[`SPI_DIVIDER_LEN-1:24] <=  wb_dat_i[`SPI_DIVIDER_LEN-1:24];
      `endif
      end
  end
/*-------------------------------Ctrl register-------------------------------------*/   
  always @(posedge wb_clk_i or posedge wb_rst_i)
  begin
    if (wb_rst_i)
      ctrl <=  {`SPI_CTRL_BIT_NB{1'b0}};
    else if(spi_ctrl_sel && wb_we_i && !tip)
      begin
        if (wb_sel_i[0])
          ctrl[7:0] <=  wb_dat_i[7:0] | {7'b0, ctrl[0]};
        if (wb_sel_i[1])
          ctrl[`SPI_CTRL_BIT_NB-1:8] <=  wb_dat_i[`SPI_CTRL_BIT_NB-1:8];
      end
    else if(tip && last_bit && pos_edge)
      ctrl[`SPI_CTRL_GO] <=  1'b0;
  end
/*-------------------------------Ctrl register decode------------------------------*/ 
  assign rx_negedge = ctrl[`SPI_CTRL_RX_NEGEDGE];
  assign tx_negedge = ctrl[`SPI_CTRL_TX_NEGEDGE];
  assign go         = ctrl[`SPI_CTRL_GO];
  assign char_len   = ctrl[`SPI_CTRL_CHAR_LEN];
  assign lsb        = ctrl[`SPI_CTRL_LSB];
  assign ie         = ctrl[`SPI_CTRL_IE];
  assign ass        = ctrl[`SPI_CTRL_ASS];
/*------------------------------Slave select register------------------------------*/  
  always @(posedge wb_clk_i or posedge wb_rst_i)
  begin
    if (wb_rst_i)
    	ss <=  {`SPI_SS_NB{1'b0}};
    else if(spi_ss_sel && wb_we_i && !tip)
      	begin
      		`ifdef SPI_SS_NB_8
        		if (wb_sel_i[0])
          		  ss <=  wb_dat_i[`SPI_SS_NB-1:0];
	      	`endif
      		`ifdef SPI_SS_NB_16
        		if (wb_sel_i[0])
          		  ss[7:0] <=  wb_dat_i[7:0];
        		if (wb_sel_i[1])
          		  ss[`SPI_SS_NB-1:8] <=  wb_dat_i[`SPI_SS_NB-1:8];
	      	`endif
      		`ifdef SPI_SS_NB_24
        		if (wb_sel_i[0])
          		  ss[7:0] <=  wb_dat_i[7:0];
        		if (wb_sel_i[1])
          		  ss[15:8] <=  wb_dat_i[15:8];
        		if (wb_sel_i[2])
          		  ss[`SPI_SS_NB-1:16] <=  wb_dat_i[`SPI_SS_NB-1:16];
	      	`endif
      		`ifdef SPI_SS_NB_32
        		if (wb_sel_i[0])
          		  ss[7:0] <=  wb_dat_i[7:0];
        		if (wb_sel_i[1])
          		  ss[15:8] <=  wb_dat_i[15:8];
        		if (wb_sel_i[2])
          		  ss[23:16] <=  wb_dat_i[23:16];
        		if (wb_sel_i[3])
          		  ss[`SPI_SS_NB-1:24] <=  wb_dat_i[`SPI_SS_NB-1:24];
      		`endif
      end
  end
//-----------------------------------------------------------------------------------  
  assign ss_pad_o = ~((ss & {`SPI_SS_NB{tip & ass}}) | (ss & {`SPI_SS_NB{!ass}}));
 //----------------------------------------------------------------------------------- 
endmodule
//-----------------------------------------------------------------------------------  
