//--------------------------------------------------
/*
 *
 * Author:  Deepak Siddharth Parthipan
 *          RIT, NY, USA
 * Module:  spi tb defines
 *
 */
//---------------------------------------------------
    `define LOW 0
    `define HIGH 1

    parameter CLOCK_PERIOD = 50;
    parameter RESET_PERIOD = 25;

    parameter dwidth = 32;
    parameter awidth = 32;

    parameter SPI_RX_0   = 5'h0;
    parameter SPI_RX_1   = 5'h4;
    parameter SPI_RX_2   = 5'h8;
    parameter SPI_RX_3   = 5'hc;
    parameter SPI_TX_0   = 5'h0;
    parameter SPI_TX_1   = 5'h4;
    parameter SPI_TX_2   = 5'h8;
    parameter SPI_TX_3   = 5'hc;
    parameter SPI_CTRL   = 5'h10;
    parameter SPI_DIVIDE = 5'h14;
    parameter SPI_SS     = 5'h18;

    logic scan_in0, scan_in1, scan_en, test_mode;    
    logic clock, rstn;  
    logic  [7:0] ss;
    logic  [31:0] q;
    logic sclk, mosi, miso;
    logic tip;

    typedef virtual spi_if spi_vif;
//---------------------------------------------------
