/*
 * Author:  Deepak Siddharth Parthipan
 *          RIT, NY, USA
 * Module:  spi_slave_model
 */
//-----------------------------------------------------------------------------------
`include "src/spi_defines.v"
`include "src/timescale.v"
//-----------------------------------------------------------------------------------
module spi_slave (
  // Wishbone signals
  wb_clk_i, wb_rst_i, wb_adr_i, wb_dat_i, wb_dat_o, wb_sel_i,
  wb_we_i, wb_stb_i, wb_cyc_i, wb_ack_o, wb_err_o, wb_int_o,

  // SPI signals
  ss_pad_i, sclk_pad_i, mosi_pad_i, miso_pad_o,

  //Scan Insertion  
  scan_in0, scan_en, test_mode, scan_out0); //,reset, clk);
//-----------------------------------------------------------------------------------
  // Wishbone signals
  input                            wb_clk_i;         // master clock input
  input                            wb_rst_i;         // synchronous active high reset
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

 // SPI signals 
  input         [`SPI_SS_NB-1:0]   ss_pad_i;         // slave select
  input                            sclk_pad_i;       // serial clock
  input                            mosi_pad_i;       // master out slave in
  output                           miso_pad_o;       // master in slave out

  input                            scan_in0;         // test scan mode data input
  input                            scan_en;          // test scan mode enable
  input                            test_mode;        // test mode select
  output                           scan_out0;        // test scan mode data output

  wire                              rx_negedge;       // slave receiving on negedge
  wire                              tx_negedge;       // slave transmiting on negedge
  wire                              spi_tx_sel;       // tx_l register select

  reg                     [32-1:0] wb_dat_o;
  reg                     [32-1:0] wb_dat;
  reg                              wb_ack_o;
  reg                              wb_int_o;
  reg       [`SPI_CTRL_BIT_NB-1:0] ctrl;
  reg                              miso_pad_o;

//-----------------------------------------------------------------------------------
  // Address decoder
  assign spi_ctrl_sel    = wb_cyc_i & wb_stb_i & (wb_adr_i[`SPI_OFS_BITS] == `SPI_CTRL);

  assign rx_negedge = ctrl[`SPI_CTRL_RX_NEGEDGE];
  assign tx_negedge = ctrl[`SPI_CTRL_TX_NEGEDGE];
  assign char_len   = ctrl[`SPI_CTRL_CHAR_LEN];
  assign ie         = ctrl[`SPI_CTRL_IE];

  assign spi_tx_sel   = wb_cyc_i & wb_stb_i & (wb_adr_i[`SPI_OFS_BITS] == `SPI_TX_0);
//-----------------------------------------------------------------------------------
 // Wb data out
  always @(posedge wb_clk_i or posedge wb_rst_i)
  begin
    if (wb_rst_i)
      wb_dat_o <=  32'b0;
    else
      wb_dat_o <=  wb_dat;
  end
//-----------------------------------------------------------------------------------  
  // Wb acknowledge
  always @(posedge wb_clk_i or posedge wb_rst_i)
  begin
    if (wb_rst_i)
      wb_ack_o <=  1'b0;
    else
      wb_ack_o <=  wb_cyc_i & wb_stb_i & ~wb_ack_o;
  end
//-----------------------------------------------------------------------------------  
  // Wb error
  assign wb_err_o = 1'b0;
  
  // Interrupt
/*  always @(posedge wb_clk_i or posedge wb_rst_i)
  begin
    if (wb_rst_i)
      wb_int_o <=  1'b0;
    else if (ie && !ss_pad_i && last_bit && pos_edge) // there needs to be rising edge detector
      wb_int_o <=  1'b1;
    else if (wb_ack_o)
      wb_int_o <=  1'b0;
  end*/
//-----------------------------------------------------------------------------------
  // Ctrl register
  always @(posedge wb_clk_i or posedge wb_rst_i)
  begin
    if (wb_rst_i)
      ctrl <=  {`SPI_CTRL_BIT_NB{1'b0}};
    else if(spi_ctrl_sel && wb_we_i && (!(&ss_pad_i))) //!ss_pad_i Because during no transfer we go to tristate mode
      begin
        if (wb_sel_i[0])
          ctrl[7:0] <=  wb_dat_i[7:0] | {7'b0, ctrl[0]};
        if (wb_sel_i[1])
          ctrl[`SPI_CTRL_BIT_NB-1:8] <=  wb_dat_i[`SPI_CTRL_BIT_NB-1:8];
      end
  end
//-----------------------------------------------------------------------------------
  always @(posedge(sclk_pad_i && !rx_negedge) or negedge(sclk_pad_i && rx_negedge) or posedge wb_rst_i or posedge(wb_clk_i && (&ss_pad_i)))
  begin
    if (wb_rst_i)
      wb_dat <=  32'b0;
    else if (!(&ss_pad_i))
      wb_dat <=  {wb_dat[30:0], mosi_pad_i};
    else if ((&ss_pad_i) && spi_tx_sel)
      wb_dat <=  wb_dat_i;      
     else     
      wb_dat <=  wb_dat;      
  end
//-----------------------------------------------------------------------------------
  always @(posedge(sclk_pad_i && !tx_negedge) or negedge(sclk_pad_i && tx_negedge))
  begin
    miso_pad_o <=  wb_dat[31];
  end
//-----------------------------------------------------------------------------------
endmodule
 //-----------------------------------------------------------------------------------     
