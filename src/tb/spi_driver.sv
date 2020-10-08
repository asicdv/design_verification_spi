/*
 * Author:  Deepak Siddharth Parthipan
 *          RIT, NY, USA
 * Module:  Driver
 */
//-------------------------------------------------------------
class spi_driver extends uvm_driver #(spi_sequence_item);
//-------------------------------------------------------------
    `uvm_component_utils(spi_driver)
     spi_vif m_vif, s_vif;
     spi_sequence_item packet;
     uvm_analysis_port #(spi_sequence_item) dut_in_pkt;
//-------------------------------------------------------------
    function new(string name="spi_monitor",uvm_component parent);
        super.new(name,parent);
        dut_in_pkt = new("dut_in_pkt",this);
    endfunction: new
//-------------------------------------------------------------
     function void build_phase(uvm_phase phase);
        super.build_phase(phase);
       `uvm_info(get_full_name(),"Build phase called in spi_driver",UVM_LOW) 
        if(!uvm_config_db#(virtual spi_if)::get(this, "", "m_if", m_vif))
        `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".m_vif"})
        if(!uvm_config_db#(virtual spi_if)::get(this, "", "s_if", s_vif))
        `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".s_vif"})       
    endfunction: build_phase 
//-------------------------------------------------------------
    task run_phase(uvm_phase phase);
     packet = spi_sequence_item :: type_id :: create("packet");
        reset_dut();
        fork
            forever begin
            seq_item_port.get_next_item(req);
            //$display("SPI_DIVIDE=0x%0h, SPI_TX_0=0x%0h, SPI_CTRL=0x%0h",req.divider_reg,req.in_master_data,req.master_ctrl_reg);
            drive_transfer(req);
            packet = req;
            dut_in_pkt.write(packet);
            seq_item_port.item_done();
            
            //$finish();
            end
        join_none  
    endtask: run_phase
//-------------------------------------------------------------
    task reset_dut();      
        m_vif.adr  <= {awidth{1'bx}};
        m_vif.dout <= {dwidth{1'bx}};
        m_vif.cyc  <= 1'b0;
        m_vif.stb  <= 1'bx;
        m_vif.we   <= 1'hx;
        m_vif.sel  <= {dwidth/8{1'bx}};

        s_vif.adr  <= {awidth{1'bx}};
        s_vif.dout <= {dwidth{1'bx}};
        s_vif.cyc  <= 1'b0;
        s_vif.stb  <= 1'bx;
        s_vif.we   <= 1'hx;
        s_vif.sel  <= {dwidth/8{1'bx}};
    endtask: reset_dut
//-------------------------------------------------------------
    task drive_transfer(spi_sequence_item seq);     
      wb_write(m_vif, 0, SPI_DIVIDE, seq.divider_reg);     // set divider register
      wb_write(m_vif, 0, SPI_SS, seq.slave_select_reg);    // set ss 0
      wb_write(m_vif, 0, SPI_TX_0, seq.in_master_data);    // set master data register
      wb_write(m_vif, 0, SPI_CTRL, seq.master_ctrl_reg);   // set master ctrl register
      wb_write(s_vif, 0, SPI_CTRL, seq.slave_ctrl_reg);    // set slave ctrl register
      wb_write(s_vif, 0, SPI_TX_0, seq.in_slave_data);     // set slave data register
      wb_write(m_vif, 0, SPI_CTRL, seq.start_dut_reg);   // start data transfer
    endtask: drive_transfer
/*----------------Wishbone write cycle------------------------*/   
  task wb_write;
    input   vif; 
    input   delay;
    integer delay;
  
    input logic [awidth -1:0] a;
    input logic [dwidth -1:0] d;
    spi_vif vif;
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
endclass: spi_driver
//-------------------------------------------------------------
