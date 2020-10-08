/*
 * Author:  Deepak Siddharth Parthipan
 *          RIT, NY, USA
 * Module:  Test
 */
//-------------------------------------------------------------
class spi_test extends uvm_test;
//-------------------------------------------------------------
    `uvm_component_utils(spi_test)
    spi_env env;
    spi_sequence h_seq; 
//-------------------------------------------------------------
    function new(string name="spi_test",uvm_component parent);
        super.new(name,parent);
    endfunction: new
//-------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_full_name(),"Build phase called in spi_test",UVM_LOW)
        /* Build environment component*/
        env = spi_env::type_id::create("env",this);
    endfunction: build_phase
//-------------------------------------------------------------
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_full_name(),"Connect phase called in spi_test",UVM_LOW)
    endfunction: connect_phase
//-------------------------------------------------------------
    task reset_phase(uvm_phase phase);
        phase.raise_objection(this);
        reset <= `LOW;
        repeat(RESET_PERIOD) @(posedge clk);
        reset <= `HIGH;
        repeat(RESET_PERIOD) @(posedge clk);
        reset = `LOW;
        phase.drop_objection(this);
    endtask: reset_phase
//-------------------------------------------------------------
    virtual task main_phase(uvm_phase phase);
        `uvm_info(get_full_name(),"in main phase",UVM_LOW)
        phase.raise_objection(this);
        h_seq=spi_sequence::type_id::create("h_seq");
        repeat(1000000)
        h_seq.start(env.agent.sequencer);
        phase.drop_objection(this);
    endtask: main_phase
//-------------------------------------------------------------
endclass: spi_test
//-------------------------------------------------------------
