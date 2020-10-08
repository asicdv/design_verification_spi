/*
 * Author:  Deepak Siddharth Parthipan
 *          RIT, NY, USA
 * Module:  Monitor
 */
//-------------------------------------------------------------
class spi_monitor extends uvm_monitor;
//-------------------------------------------------------------
    `uvm_component_utils(spi_monitor) 
    spi_vif m_vif, s_vif; 
    spi_sequence_item packet;
    uvm_analysis_port #(spi_sequence_item) dut_out_pkt;
//-------------------------------------------------------------
    function new(string name="spi_monitor",uvm_component parent);
        super.new(name,parent);
        dut_out_pkt = new("dut_out_pkt",this);
    endfunction: new
//-------------------------------------------------------------
     function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_full_name(),"Build phase called in spi_monitor",UVM_LOW)  
       if(!uvm_config_db#(virtual spi_if)::get(this, "", "m_if", m_vif))
        `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".m_vif"})
        if(!uvm_config_db#(virtual spi_if)::get(this, "", "s_if", s_vif))
        `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".s_vif"})    
    endfunction: build_phase
//-------------------------------------------------------------
    task run_phase(uvm_phase phase);
        packet = spi_sequence_item :: type_id :: create("packet");       
        wait(m_vif.monitor_cb.pit==1'b1)    //wait_to_start
        forever begin
           wait(m_vif.monitor_cb.pit==1'b0) //wait_to_complete        
           wb_read(m_vif, 1, SPI_RX_0, packet.out_master_data);
           wb_read(s_vif, 1, SPI_RX_0, packet.out_slave_data);
           $display("SPI_Master=0x%0h, SPI_Slave=0x%0h",packet.out_master_data, packet.out_slave_data);
           dut_out_pkt.write(packet);   
           wait(m_vif.monitor_cb.pit==1'b1); //wait_to_start 
           //@(vif.monitor_cb);
        end
    endtask: run_phase
/*----------------Wishbone read cycle------------------------*/ 
  task wb_read;
    input vif;
    input delay; 
    input logic [awidth -1:0] a;
    output logic [dwidth -1:0] d;
    integer delay;
    spi_vif vif;
    
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
//-------------------------------------------------------------
endclass: spi_monitor
//-------------------------------------------------------------
