/*
 * Author:  Deepak Siddharth Parthipan
 *          RIT, NY, USA
 * Module:  Sequencer
 */
//-------------------------------------------------------------
class spi_sequencer extends uvm_sequencer #(spi_sequence_item);
//-------------------------------------------------------------
    `uvm_component_utils(spi_sequencer) 
//-------------------------------------------------------------
    function new(string name="spi_sequencer",uvm_component parent);
        super.new(name,parent);
    endfunction: new
//-------------------------------------------------------------
endclass: spi_sequencer
//-------------------------------------------------------------
