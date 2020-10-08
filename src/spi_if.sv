/*
 * Author:  Deepak Siddharth Parthipan
 *          RIT, NY, USA
 * Module:  Package
 */
//-------------------------------------------------------------
interface spi_if(input bit clk);
//-------------------------------------------------------------
  // Wishbone signals

  logic                      [4:0] adr;       // lower address bits
  logic                   [32-1:0] din;       // databus input
  logic                   [32-1:0] dout;      // databus output
  logic                      [3:0] sel;       // byte select inputs
  logic                            we;        // write enable input
  logic                            stb;       // stobe/core select signal
  logic                            cyc;       // valid bus cycle input
  logic                            ack;       // bus cycle acknowledge output
  logic                            err;       // termination w/ error
  logic                            intp;       // interrupt request signal output  input 
  logic                            transfer_in_progress; 
  logic                            sclk; 
  logic                            mosi;
  logic                            miso;
  logic                      [7:0] ss;
//-------------------------------------------------------------
    clocking drive_cb @(posedge clk);
    input  din, ack, err, intp, transfer_in_progress; 
    output  adr, dout, sel, we, stb, cyc;                
    endclocking : drive_cb
//-------------------------------------------------------------
    clocking monitor_cb @(posedge clk);
    input  din, ack, err, intp, transfer_in_progress, mosi, miso, ss; 
   // input  ss;
    output  adr, dout, sel, we, stb, cyc;     
    endclocking : monitor_cb
//-------------------------------------------------------------
endinterface : spi_if
//-------------------------------------------------------------      
