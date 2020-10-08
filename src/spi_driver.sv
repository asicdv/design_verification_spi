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
        wb_bfm::wb_reset(m_vif);
        wb_bfm::wb_reset(s_vif);
        fork
            forever begin
            seq_item_port.get_next_item(req);
            drive_transfer(req);
            $cast(packet,req.clone());
            packet = req;
            dut_in_pkt.write(packet);
            seq_item_port.item_done();
            wait(m_vif.monitor_cb.transfer_in_progress==1'b0);
            end
        join_none  
    endtask: run_phase
//-------------------------------------------------------------
    task drive_transfer(spi_sequence_item seq);     
      wb_bfm::wb_write(m_vif, 0, SPI_DIVIDE, seq.divider_reg);     // set divider register
      wb_bfm::wb_write(m_vif, 0, SPI_SS, seq.slave_select_reg);    // set ss 0
      wb_bfm::wb_write(m_vif, 0, SPI_TX_0, seq.in_master_data);    // set master data register
      wb_bfm::wb_write(m_vif, 0, SPI_CTRL, seq.master_ctrl_reg);   // set master ctrl register
      wb_bfm::wb_write(s_vif, 0, SPI_CTRL, seq.slave_ctrl_reg);    // set slave ctrl register
      wb_bfm::wb_write(s_vif, 0, SPI_TX_0, seq.in_slave_data);     // set slave data register
      wb_bfm::wb_write(m_vif, 0, SPI_CTRL, seq.start_dut_reg);     // start data transfer
    endtask: drive_transfer
//-------------------------------------------------------------
endclass: spi_driver
//-------------------------------------------------------------
