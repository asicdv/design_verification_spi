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
    spi_sequence_item ip_pkt;
    spi_sequence_item op_pkt;
    static string report_tag;
    spi_coverage spi_covg;
    int pass = 0;
    int fail = 0;
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
        spi_covg =  spi_coverage::type_id::create("spi_covg",this);
    endfunction: build_phase
//-------------------------------------------------------------
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_full_name(),"Connect phase called in spi_scoreboard",UVM_LOW)
    endfunction: connect_phase
//-------------------------------------------------------------
    function void write_exp_pkt(spi_sequence_item tmp_pkt);
        spi_sequence_item pkt;
        $cast(pkt,tmp_pkt.clone());
        //`uvm_info(report_tag,$sformatf("Received packet from driver %0s ",pkt.sprint()),UVM_LOW)
        drv_pkt.push_back(pkt);
        uvm_test_done.raise_objection(this);
    endfunction: write_exp_pkt
//-------------------------------------------------------------
    function void write_act_pkt(spi_sequence_item tmp_pkt);
        spi_sequence_item pkt;
        $cast(pkt,tmp_pkt.clone());
       //`uvm_info(report_tag,$sformatf("Received packet from DUT %0s ",pkt.sprint()),UVM_LOW)
        mon_pkt.push_back(pkt);
    endfunction: write_act_pkt
//-------------------------------------------------------------
    task run_phase(uvm_phase phase);
        //fork               
        forever begin   
        wait(mon_pkt.size()!=0);
        op_pkt = mon_pkt.pop_front();
        ip_pkt = drv_pkt.pop_front();
        //if(drv_pkt.size()==0)
         //`uvm_error("Expected packet was not received in scoreboard",UVM_LOW)
        perform_check(ip_pkt,op_pkt);   
        perform_coverage(ip_pkt,op_pkt);     
        uvm_test_done.drop_objection(this);
        end
        //join_none
        //disable fork;
    endtask: run_phase
//-------------------------------------------------------------
    function void perform_coverage(spi_sequence_item ipkt,spi_sequence_item opkt);
         spi_covg.perform_coverage(ipkt,opkt);          
    endfunction: perform_coverage
//-------------------------------------------------------------
    function void perform_check(spi_sequence_item ip_pkt, spi_sequence_item op_pkt);
        if(ip_pkt.exp_master_data==op_pkt.out_master_data && ip_pkt.exp_slave_data==op_pkt.out_slave_data)
        begin
        //`uvm_info(get_full_name(),"Master PASSED",UVM_MEDIUM)
        //`uvm_info(get_full_name(),"Slave PASSED",UVM_MEDIUM)
        pass++;
        end 
        else
        begin
        `uvm_info(get_full_name(),$sformatf("Slave FAILED: exp data=%0h and out slave data=%0h",ip_pkt.exp_slave_data,op_pkt.out_slave_data),UVM_MEDIUM)   
        `uvm_info(get_full_name(),$sformatf("Master FAILED: exp data=%0h and out master data=%0h",ip_pkt.exp_master_data,op_pkt.out_master_data),UVM_MEDIUM)     
        fail++;
        end                     
    endfunction: perform_check
//-------------------------------------------------------------
    function void extract_phase(uvm_phase phase);      
    endfunction: extract_phase
//-------------------------------------------------------------
    function void report_phase(uvm_phase phase);
    if(fail==0)
    begin
     $display
    ("----------------------------------32bit--MSB First--TX:posedge--RX:negedge--------------------------------");
    $display
    ("------------------------------------------------TEST PASSED-----------------------------------------------");
     $display
    ("**********************************************************************************************************");
uvm_report_info("Scoreboard Report",$sformatf("Trasactions PASS = %0d FAIL = %0d",pass,fail),UVM_MEDIUM);
      $display
    ("**********************************************************************************************************");
    $display
    ("----------------------------------------------------------------------------------------------------------");
     $display
    ("----------------------------------------------------------------------------------------------------------");
    end   
    else
    begin
      $display
    ("----------------------------------32bit--MSB First--TX:posedge--RX:negedge--------------------------------");
    $display
    ("------------------------------------------------TEST FAILED-----------------------------------------------");
     $display
    ("**********************************************************************************************************");
uvm_report_info("Scoreboard Report",$sformatf("Trasactions PASS = %0d FAIL = %0d",pass,fail),UVM_MEDIUM);
      $display
    ("**********************************************************************************************************");
    $display
    ("----------------------------------------------------------------------------------------------------------");
     $display
    ("----------------------------------------------------------------------------------------------------------");
    end   
    endfunction: report_phase
//-------------------------------------------------------------
endclass: spi_scoreboard
//-------------------------------------------------------------
