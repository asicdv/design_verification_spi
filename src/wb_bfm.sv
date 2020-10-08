/*
 * Author:  Deepak Siddharth Parthipan
 *          RIT, NY, USA
 * Module:  wishbone bus function
 */
//-------------------------------------------------------------
class wb_bfm extends uvm_object;
//-------------------------------------------------------------
    `uvm_object_utils(wb_bfm)
//-------------------------------------------------------------
    function new(string name = "wb_bfm");
        super.new(name);
    endfunction: new
//-------------------------------------------------------------
    static task wb_reset;
        input spi_vif vif;      
        vif.adr  <= {awidth{1'bx}};
        vif.dout <= {dwidth{1'bx}};
        vif.cyc  <= 1'b0;
        vif.stb  <= 1'bx;
        vif.we   <= 1'hx;
        vif.sel  <= {dwidth/8{1'bx}};
    endtask: wb_reset
/*----------------Wishbone read cycle------------------------*/ 
  static task wb_read;
    input spi_vif vif; 
    input integer delay;
    input logic [awidth -1:0] a;
    output logic [dwidth -1:0] d;
    
    begin 
      // wait initial delay
      repeat(delay) @(vif.monitor_cb); 
      // assert wishbone signals
      repeat(1) @(vif.monitor_cb);
      vif.monitor_cb.adr  <= a;
      vif.monitor_cb.dout <= {dwidth{1'bx}};
      vif.monitor_cb.cyc  <= 1'b1;
      vif.monitor_cb.stb  <= 1'b1;
      vif.monitor_cb.we   <= 1'b0;
      vif.monitor_cb.sel  <= {dwidth/8{1'b1}};
      @(vif.monitor_cb);  
      // wait for acknowledge from slave
      wait(vif.monitor_cb.ack==1'b1)  
      // negate wishbone signals
      repeat (1) @(vif.monitor_cb);
      vif.monitor_cb.cyc  <= 1'b0;
      vif.monitor_cb.stb  <= 1'bx;
      vif.monitor_cb.adr  <= {awidth{1'bx}};
      vif.monitor_cb.dout <= {dwidth{1'bx}};
      vif.monitor_cb.we   <= 1'hx;
      vif.monitor_cb.sel  <= {dwidth/8{1'bx}};
                     d    = vif.monitor_cb.din;
  
    end
  endtask : wb_read
/*----------------Wishbone write cycle------------------------*/   
  static task wb_write;
    input spi_vif vif; 
    input integer delay;
    input logic [awidth -1:0] a;
    input logic [dwidth -1:0] d;

    begin  
      // wait initial delay
      repeat(delay) @(vif.drive_cb);  
      // assert wishbone signal
      vif.drive_cb.adr  <= a;
      vif.drive_cb.dout <= d;
      vif.drive_cb.cyc  <= 1'b1;
      vif.drive_cb.stb  <= 1'b1;
      vif.drive_cb.we   <= 1'b1;
      vif.drive_cb.sel  <= {dwidth/8{1'b1}};
      @(vif.drive_cb);  
      // wait for acknowledge from slave
      //@(vif.drive_cb);
      wait(vif.drive_cb.ack==1'b1)  
      // negate wishbone signals
      repeat (2)
	  @(vif.drive_cb);
      vif.drive_cb.cyc  <= 1'b0;
      vif.drive_cb.stb  <= 1'bx;
      vif.drive_cb.adr  <= {awidth{1'bx}};
      vif.drive_cb.dout <= {dwidth{1'bx}};
      vif.drive_cb.we   <= 1'hx;
      vif.drive_cb.sel  <= {dwidth/8{1'bx}}; 
    end
  endtask : wb_write
//-------------------------------------------------------------
endclass: wb_bfm
//-------------------------------------------------------------
