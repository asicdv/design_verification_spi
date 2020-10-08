/*
 * Author:  Deepak Siddharth Parthipan
 *          RIT, NY, USA
 * Module:  Scoreboard
 */
//-------------------------------------------------------------
class spi_scoreboard extends uvm_scoreboard;
//-------------------------------------------------------------
    `uvm_component_utils(spi_scoreboard)

    `uvm_analysis_imp_decl(_exp_pkt)
    `uvm_analysis_imp_decl(_act_pkt)

    uvm_analysis_imp_exp_pkt#(spi_sequence_item,spi_scoreboard) drv2sb;
    uvm_analysis_imp_act_pkt#(spi_sequence_item,spi_scoreboard) mon2sb;

    spi_sequence_item drv_pkt[$];
    spi_sequence_item mon_pkt[$];

    static string report_tag;
//-------------------------------------------------------------
    function new(string name="spi_scoreboard",uvm_component parent);
        super.new(name,parent);
        report_tag = $sformatf("%0s",name);
        drv2sb = new("drv2sb",this);
        mon2sb = new("mon2sb",this);
    endfunction: new
//-------------------------------------------------------------
     function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_full_name(),"Build phase called in spi_scoreboard",UVM_LOW)
    endfunction: build_phase
//-------------------------------------------------------------
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_full_name(),"Connect phase called in spi_scoreboard",UVM_LOW)
    endfunction: connect_phase
//-------------------------------------------------------------
    task run_phase(uvm_phase phase);
        spi_sequence_item ip_pkt,op_pkt;       
        forever begin
        wait(mon2sb.size()!=0)
        op_pkt = mon_pkt.pop_front();
        ip_pkt = drv_pkt.pop_front();
        perform_check(ip_pkt,op_pkt);        
        uvm_test_done.drop_objection(this);
        end
    endtask: run_phase
//-------------------------------------------------------------
    function void write_exp_pkt(spi_sequence_item temp_pkt);
        spi_sequence_item pkt;
        //$cast(pkt,temp_pkt.clone());
        `uvm_info(report_tag,$sformatf("Received packet from driver %0s ",pkt.sprint()),UVM_LOW)
        drv_pkt.push_back(pkt);
        uvm_test_done.raise_objection(this);
    endfunction: write_exp_pkt
//-------------------------------------------------------------
    function void write_act_pkt(spi_sequence_item temp_pkt);
        spi_sequence_item pkt;
        //$cast(pkt,temp_pkt.clone());
        `uvm_info(report_tag,$sformatf("Received packet from DUT %0s ",pkt.sprint()),UVM_LOW)
        mon_pkt.push_back(pkt);
    endfunction: write_act_pkt
//-------------------------------------------------------------
    function void perform_check(spi_sequence_item ip_pkt, spi_sequence_item op_pkt);
        if(ip_pkt.exp_master_data==op_pkt.out_master_data)
        `uvm_info(get_full_name(),"Master data match",UVM_MEDIUM)
        else
        `uvm_info(get_full_name(),"Master data failed",UVM_MEDIUM)
        if(ip_pkt.exp_slave_data==op_pkt.out_slave_data)
        `uvm_info(get_full_name(),"Slave data match",UVM_MEDIUM)
        else
        `uvm_info(get_full_name(),"Slave data failed",UVM_MEDIUM)

    endfunction: perform_check
//-------------------------------------------------------------
endclass: spi_scoreboard
//-------------------------------------------------------------









