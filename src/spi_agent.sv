/*
 * Author:  Deepak Siddharth Parthipan
 *          RIT, NY, USA
 * Module:  Agent
 */
//-------------------------------------------------------------
class spi_agent extends uvm_agent;
//-------------------------------------------------------------
    `uvm_component_utils(spi_agent)
    spi_sequencer sequencer;
    spi_monitor monitor; 
    spi_driver driver;  
    spi_vif m_vif,s_vif;
//-------------------------------------------------------------
    function new(string name="spi_agent",uvm_component parent);
        super.new(name,parent);
    endfunction: new
//-------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_full_name(),"Build phase called in spi_agent",UVM_LOW)         
        if(!uvm_config_db#(virtual spi_if)::get(this, "", "m_if", m_vif))
        `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".m_vif"})
        if(!uvm_config_db#(virtual spi_if)::get(this, "", "s_if", s_vif))
        `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".s_vif"})              
        sequencer = spi_sequencer::type_id::create("sequencer",this);
        driver = spi_driver::type_id::create("driver",this);               
        driver.m_vif = m_vif;
        driver.s_vif = s_vif;
        monitor = spi_monitor::type_id::create("monitor",this);
        monitor.m_vif = m_vif;
        monitor.s_vif = s_vif;
    endfunction: build_phase
//-------------------------------------------------------------
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_full_name(),"Connect phase called in spi_agent",UVM_LOW) 
        driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction: connect_phase
//-------------------------------------------------------------
endclass: spi_agent
//-------------------------------------------------------------
