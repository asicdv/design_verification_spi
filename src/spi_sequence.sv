/*
 * Author:  Deepak Siddharth Parthipan
 *          RIT, NY, USA
 * Module:  Sequence
 */
//-------------------------------------------------------------
class spi_sequence extends uvm_sequence #(spi_sequence_item);
//-------------------------------------------------------------
    `uvm_object_utils(spi_sequence)  
//-------------------------------------------------------------
    function new(string name="spi_sequence");
        super.new(name);
    endfunction: new
//-------------------------------------------------------------
    virtual task body();
        req=spi_sequence_item :: type_id :: create("req");
        start_item(req);
        //configure_dut_register();
        set_dut_data();
        finish_item(req);        
    endtask: body
//-------------------------------------------------------------
    virtual function void configure_dut_register();
      assert(req.randomize() with {  req.master_ctrl_reg == 32'h00002208;       
                                   req.slave_ctrl_reg == 32'h00000200;
                                   req.divider_reg == 32'h00000000;       
                                   req.slave_select_reg == 32'h00000001;
                                   req.start_dut_reg == 32'h00000320;                                 
                                });
    endfunction: configure_dut_register
//-------------------------------------------------------------
    virtual function void set_dut_data();
      assert(req.randomize() with {
                                   req.divider_reg == 32'h00000000;  
                                   req.master_ctrl_reg == 32'h00002200;       
                                   req.slave_ctrl_reg == 32'h00000200;                                         
                                   req.slave_select_reg == 32'h00000001;
                                   req.start_dut_reg == 32'h00000320;  
                                   //req.start_dut_reg == 32'h00000308;
                                   //req.in_master_data == 32'h87654321;       
                                   //req.in_slave_data == 32'h11223344;
                                   req.exp_master_data == req.in_slave_data;       
                                   req.exp_slave_data == req.in_master_data;
                                });
    endfunction: set_dut_data
//-------------------------------------------------------------
endclass: spi_sequence
//-------------------------------------------------------------



