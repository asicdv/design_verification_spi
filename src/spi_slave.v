/*
 * Author:  Deepak Siddharth Parthipan
 *          RIT, NY, USA
 * Module:  spi_slave_model
 */
//-----------------------------------------------------------------------------------
//`include "timescale.v"
//-----------------------------------------------------------------------------------
module spi_slave (rst, ss, sclk, mosi, miso);

  input         rst;            // reset
  input         ss;             // slave select
  input         sclk;           // serial clock
  input         mosi;           // master out slave in
  output        miso;           // master in slave out

  reg           miso;

  reg           rx_negedge;     // slave receiving on negedge
  reg           tx_negedge;     // slave transmiting on negedge
  reg    [31:0] data;           // data register
//-----------------------------------------------------------------------------------
  always @(posedge(sclk && !rx_negedge) or negedge(sclk && rx_negedge) or rst)
  begin
    if (rst)
      data <=  32'b0;
    else if (!ss)
      data <=  {data[30:0], mosi};
  end
//-----------------------------------------------------------------------------------
  always @(posedge(sclk && !tx_negedge) or negedge(sclk && tx_negedge))
  begin
    miso <=  data[31];
  end
//-----------------------------------------------------------------------------------
endmodule
//-----------------------------------------------------------------------------------      
