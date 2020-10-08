/*
 * Author:  Deepak Siddharth Parthipan
 *          RIT, NY, USA
 * Module:  Sequence Item
 */
//-------------------------------------------------------------
class spi_sequence_item extends uvm_sequence_item;
//-------------------------------------------------------------
    /*Register configuration*/
    rand logic [31:0] master_ctrl_reg;
    rand logic [31:0] slave_ctrl_reg;
    rand logic [31:0] divider_reg;
    rand logic [31:0] slave_select_reg;
    rand logic [31:0] start_dut_reg; 
    /*DUT output*/
    logic [31:0] out_master_data;
    logic [31:0] out_slave_data;
    /*Expected data*/
    rand logic [31:0] exp_master_data;
    rand logic [31:0] exp_slave_data;
    /*DUT input*/          
    rand logic [31:0] in_master_data;
    rand logic [31:0] in_slave_data;   
    logic [31:0] q;
//-------------------------------------------------------------        
    `uvm_object_utils_begin(spi_sequence_item)
      `uvm_field_int(master_ctrl_reg,UVM_ALL_ON)
      `uvm_field_int(slave_ctrl_reg,UVM_ALL_ON)
      `uvm_field_int(divider_reg,UVM_ALL_ON)   
      `uvm_field_int(slave_select_reg,UVM_ALL_ON)
      `uvm_field_int(start_dut_reg,UVM_ALL_ON)
      `uvm_field_int(out_master_data,UVM_ALL_ON)
      `uvm_field_int(out_slave_data,UVM_ALL_ON)  
      `uvm_field_int(exp_master_data,UVM_ALL_ON)
      `uvm_field_int(exp_slave_data,UVM_ALL_ON) 
      `uvm_field_int(in_master_data,UVM_ALL_ON)
      `uvm_field_int(in_slave_data,UVM_ALL_ON)  
      `uvm_field_int(q,UVM_ALL_ON)            
    `uvm_object_utils_end
//-------------------------------------------------------------
    function new(string name="spi_sequence_item");
        super.new(name);
    endfunction: new
//-------------------------------------------------------------
endclass: spi_sequence_item
//-------------------------------------------------------------
