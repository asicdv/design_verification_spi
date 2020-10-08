/*
 * Author:  Deepak Siddharth Parthipan
 *          RIT, NY, USA
 * Module:  coverage
 */
//-------------------------------------------------------------
class spi_coverage extends uvm_component;
//-------------------------------------------------------------
    `uvm_component_utils(spi_coverage)

    spi_sequence_item trans_ipkt;
    spi_sequence_item trans_opkt;    
    event spi_sig_cov_event;
    virtual spi_if h_vif;
//-------------------------------------------------------------
    covergroup spi_sig_cg(string cg_name, bit cg_per_instance)@(spi_sig_cov_event);
//-------------------------------------------------------------
    option.name = cg_name;
    option.per_instance = cg_per_instance;
//------------------------------------------------------------- 
    cp_dut_mosi: coverpoint h_vif.mosi
    {
        bins low  = {1'b0};
        bins high = {1'b1};
    }
//-------------------------------------------------------------
    cp_dut_miso: coverpoint h_vif.miso
    {
        bins low  = {1'b0};
        bins high = {1'b1};
    }

    cr_mosi_miso : cross cp_dut_mosi, cp_dut_miso{}
//-------------------------------------------------------------    
    endgroup : spi_sig_cg
//---------------------------------------------------
    covergroup spi_trans_cg(string cg_name, bit cg_per_instance);
//-------------------------------------------------------------
    option.name = cg_name;
    option.per_instance = cg_per_instance;
    //option.at_least =1;
    //option.auto_bin_max = 2^32-1;
//------------------------------------------------------------- 
    cp_sg_mosi_in: coverpoint trans_ipkt.exp_master_data
    {
        option.auto_bin_max = 50;
        //bins low  = {[0:255]};
        //bins med  = {[256:65535]};
        //bins high = {[65536:16777215]};
        //bins max  = {[16777216:$]};
    }
//-------------------------------------------------------------
    cp_sg_mosi_out: coverpoint trans_opkt.out_master_data
    {
        option.auto_bin_max = 50;
        //bins low  = {[0:255]};
        //bins med  = {[256:65535]};
        //bins high = {[65536:16777215]};
        //bins max  = {[16777216:$]};
    }
//-------------------------------------------------------------
    cr_mosi_master : cross cp_sg_mosi_in, cp_sg_mosi_out{}
//-------------------------------------------------------------
    cp_sg_miso_in: coverpoint trans_ipkt.exp_slave_data
    {
        option.auto_bin_max = 50;
        //bins low  = {[0:255]};
        //bins med  = {[256:65535]};
        //bins high = {[65536:16777215]};
        //bins max  = {[16777216:$]};
    }
//-------------------------------------------------------------
    cp_sg_miso_out: coverpoint trans_opkt.out_slave_data
    {
        option.auto_bin_max = 50;
        //bins low  = {[0:255]};
        //bins med  = {[256:65535]};
        //bins high = {[65536:16777215]};
        //bins max  = {[16777216:$]};
    }
//-------------------------------------------------------------
    cr_miso_master : cross cp_sg_miso_in, cp_sg_miso_out{}
//-------------------------------------------------------------
    endgroup : spi_trans_cg
//---------------------------------------------------
    function new(string name="spi_covg", uvm_component parent=null);
    super.new(name,parent);
    spi_trans_cg = new("spi_trans_cg",1);
    spi_sig_cg   = new("spi_sig_cg",1);
    endfunction : new    
//---------------------------------------------------
    function void perform_coverage(spi_sequence_item ipkt,spi_sequence_item opkt);
       this.trans_ipkt=ipkt;
       this.trans_opkt=opkt;
       spi_trans_cg.sample();          
    endfunction : perform_coverage
//---------------------------------------------------
endclass: spi_coverage
//-------------------------------------------------------------
