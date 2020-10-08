/*
 * Author:  Deepak Siddharth Parthipan
 *          RIT, NY, USA
 * Module:  tb_top
 */
//-------------------------------------------------------------
`include "uvm_macros.svh"
`include "spi_pkg.sv"
`include "spi_if.sv"
//-------------------------------------------------------------
module test;
	import uvm_pkg::*;
	import spi_pkg::*;
	
	spi_if master(clk);      //Interface declaration
    spi_if slave(clk);      //Interface declaration
/*------------------SPI master core---------------------------*/
  spi top (
    /*tb to DUT connection*/
    .clk(clk), 
    .reset(reset), 
    .wb_adr_i(master.adr[4:0]), 
    .wb_dat_i(master.dout),      
    .wb_sel_i(master.sel), 
    .wb_we_i(master.we), 
    .wb_stb_i(master.stb), 
    .wb_cyc_i(master.cyc), 
    .wb_dat_o(master.din),
    .wb_ack_o(master.ack), 
    .wb_err_o(master.err),  
    .wb_int_o(master.intp), 
    .scan_in0(scan_in0),
    .scan_out0(scan_out0),
    .scan_en(scan_en), 
    .test_mode(test_mode),     
    /*master to slave connection*/
    .ss_pad_o(master.ss), 
    .sclk_pad_o(master.sclk), 
    .mosi_pad_o(master.mosi), 
    .miso_pad_i(master.miso),
    .tip(master.transfer_in_progress)    
    );
/*------------------SPI slave core---------------------------*/
  spi_slave spi_slave (
    /*tb to DUT connection*/
    .wb_clk_i(clk), 
    .wb_rst_i(reset), 
    .wb_adr_i(slave.adr[4:0]), 
    .wb_dat_i(slave.dout),     
    .wb_sel_i(slave.sel), 
    .wb_we_i(slave.we), 
    .wb_stb_i(slave.stb), 
    .wb_cyc_i(slave.cyc), 
    .wb_dat_o(slave.din), 
    .wb_ack_o(slave.ack), 
    .wb_err_o(slave.err),  
    .wb_int_o(slave.intp),
    .scan_in0(scan_in0), 
    .scan_en(scan_en), 
    .test_mode(test_mode), 
    .scan_out0(scan_out0),     
     /*slave to master connection*/
    .ss_pad_i(master.ss), 
    .sclk_pad_i(master.sclk), 
    .mosi_pad_i(master.mosi), 
    .miso_pad_o(master.miso)
  );
//-------------------------------------------------------------
	initial begin
        $timeformat(-9,2,"ns", 16);
        $set_coverage_db_name("spi");

        `ifdef SDFSCAN
            $sdf_annotate("sdf/spi_tsmc18_scan.sdf", test.top);
        `endif
        generate_clock();
        reg_intf_to_config_db();
        initalize_dut();
        //reset_dut();            //could also be carried out inside pre_reset_phase
		run_test();
	end
//--------------------------------------------------------------
    task generate_clock();
    fork
        forever begin
        clk = `LOW;
        #(CLOCK_PERIOD/2);
        clk = `HIGH;
        #(CLOCK_PERIOD/2);
        end
    join_none
    endtask : generate_clock
//-------------------------------------------------------------
function void reg_intf_to_config_db();
//Registers the Interface in the configuration block so that other blocks can use it retrived using get
		uvm_config_db#(virtual spi_if)::set(null,"*","m_if",master);
        uvm_config_db#(virtual spi_if)::set(null,"*","s_if",slave);
endfunction : reg_intf_to_config_db
//-------------------------------------------------------------
function void initalize_dut();
    test_mode  = 1'b0;
    scan_in0   = 1'b0;
    scan_in1   = 1'b0;
    scan_en    = 1'b0;    
endfunction : initalize_dut
//-------------------------------------------------------------    
task reset_dut();
    reset <= `LOW;
    repeat(RESET_PERIOD) @(posedge clk);
    reset <= `HIGH;
    repeat(RESET_PERIOD) @(posedge clk);
    reset = `LOW;
    //->RST_DONE;
endtask : reset_dut
//-------------------------------------------------------------
endmodule : test
//-------------------------------------------------------------
