//////////////////////////////////////////////////////////////////////
////                                                              ////
////  spi_test.v                                                ////
//////////////////////////////////////////////////////////////////goal////

//`include "timescale.v"

module test();

  wire  scan_out0;
  reg  scan_in0, scan_en, test_mode;

  
  reg         clk;
  reg         rst;
  wire [31:0] adr;
  wire [31:0] dat_i, dat_o;
  wire        we;
  wire  [3:0] sel;
  wire        stb;
  wire        cyc;
  wire        ack;
  wire        err;
  wire        int;

  wire [31:0] adr_s;
  wire [31:0] dat_i_s, dat_o_s;
  wire        we_s;
  wire  [3:0] sel_s;
  wire        stb_s;
  wire        cyc_s;
  wire        ack_s;
  wire        err_s;
  wire        int_s;

  wire  [7:0] ss;
  wire        sclk;
  wire        mosi;
  wire        miso;

  reg  [31:0] qs;
  reg  [31:0] q;
  reg  [31:0] q1;
  reg  [31:0] q2;
  reg  [31:0] q3;
  reg  [31:0] result;

  parameter SPI_RX_0   = 5'h0;
  parameter SPI_RX_1   = 5'h4;
  parameter SPI_RX_2   = 5'h8;
  parameter SPI_RX_3   = 5'hc;
  parameter SPI_TX_0   = 5'h0;
  parameter SPI_TX_1   = 5'h4;
  parameter SPI_TX_2   = 5'h8;
  parameter SPI_TX_3   = 5'hc;
  parameter SPI_CTRL   = 5'h10;
  parameter SPI_DIVIDE = 5'h14;
  parameter SPI_SS     = 5'h18;

  // Generate clock
  always #10 clk = ~clk;

  // Wishbone master model
  wb_master_model #(32, 32) wbm_master_bfm (.clk(clk), .rst(rst), .adr(adr), .din(dat_i), .dout(dat_o),
    .cyc(cyc), .stb(stb), .we(we), .sel(sel), .ack(ack), .err(err), .rty(1'b0)
  );

  // Wishbone slave model
  wb_master_model #(32, 32) wbm_slave_bfm (.clk(clk), .rst(rst), .adr(adr_s), .din(dat_i_s), .dout(dat_o_s),
    .cyc(cyc_s), .stb(stb_s), .we(we_s), .sel(sel_s), .ack(ack_s), .err(err_s), .rty(1'b0)
  );

  // SPI master core
  spi top (
    .wb_clk_i(clk), .wb_rst_i(rst), .wb_adr_i(adr[4:0]), .wb_dat_i(dat_o), .wb_dat_o(dat_i), 
    .wb_sel_i(sel), .wb_we_i(we), .wb_stb_i(stb), .wb_cyc_i(cyc), .wb_ack_o(ack), .wb_err_o(err),  
    .wb_int_o(int), .ss_pad_o(ss), .sclk_pad_o(sclk), .mosi_pad_o(mosi), .miso_pad_i(miso),    
    .scan_in0(scan_in0), .scan_en(scan_en), .test_mode(test_mode), .scan_out0(scan_out0)
  );

  /* SPI slave core
  spi_slave spi_slave (
    .rst(rst), .ss(ss[0]), .sclk(sclk), .mosi(mosi), .miso(miso)
  );*/

  // SPI slave core
  spi_slave spi_slave (
    .wb_clk_i(clk), .wb_rst_i(rst), .wb_adr_i(adr_s[4:0]), .wb_dat_i(dat_o_s), .wb_dat_o(dat_i_s), 
    .wb_sel_i(sel_s), .wb_we_i(we_s), .wb_stb_i(stb_s), .wb_cyc_i(cyc_s), .wb_ack_o(ack_s), .wb_err_o(err_s),  
    .wb_int_o(int_s), .ss_pad_i(ss), .sclk_pad_i(sclk), .mosi_pad_i(mosi), .miso_pad_o(miso),    
    .scan_in0(scan_in0), .scan_en(scan_en), .test_mode(test_mode), .scan_out0(scan_out0)
  );

  initial
    begin

    
    $timeformat(-9,2,"ns", 16);
    `ifdef SDFSCAN
     $sdf_annotate("sdf/spi_tsmc18_scan.sdf", test.top);
    `endif
    
    $display("\nstatus: %t Testbench started\n\n", $time);

    clk = 1'b0;
    //reset = 1'b0;
    scan_in0 = 1'b0;
    scan_en = 1'b0;
    test_mode = 1'b0;

     /* $dumpfile("bench.vcd");
      $dumpvars(1, spi_test);
      $dumpvars(1, spi_test.spi_slave);*/

      // Initial values
      //clk = 0;

      //spi_slave.rx_negedge = 1'b0;
      //spi_slave.tx_negedge = 1'b0;
      wbm_slave_bfm.wb_write(0, SPI_CTRL, 32'h000);         

      result = 32'h0;

      // Reset system
      rst = 1'b0; // negate reset
      repeat(20) @(posedge clk);
      rst = 1'b1; // assert reset
      repeat(20) @(posedge clk);
      rst = 1'b0; // negate reset

      $display("status: %t done reset", $time);
      
      @(posedge clk);

      // Program core
      wbm_master_bfm.wb_write(0, SPI_DIVIDE, 32'h00);  // set divider register
      //wbm_master_bfm.wb_write(0, SPI_TX_0, 32'h5a);    // set tx register to 0x5a
      wbm_master_bfm.wb_write(0, SPI_TX_0, 32'haa);    // set tx register to 0x5a
      wbm_master_bfm.wb_write(0, SPI_CTRL, 32'h2208);  // set 8 bit transfer
      wbm_master_bfm.wb_write(0, SPI_SS, 32'h01);      // set ss 0

      $display("status: %t programmed registers", $time);

      wbm_master_bfm.wb_cmp(0, SPI_DIVIDE, 32'h00);   // verify divider register
      //wbm_master_bfm.wb_cmp(0, SPI_TX_0, 32'h5a);     // verify tx register
      wbm_master_bfm.wb_cmp(0, SPI_CTRL, 32'h2208);   // verify tx register
      wbm_master_bfm.wb_cmp(0, SPI_SS, 32'h01);       // verify ss register

      $display("status: %t verified registers", $time);
//----------------------------32bit--MSB First--TX:posedge--RX:negedge-------------------------------------------//
      //spi_slave.rx_negedge = 1'b1;
      //spi_slave.tx_negedge = 1'b0;
      wbm_slave_bfm.wb_write(0, SPI_CTRL, 32'h200); 
      //spi_slave.wb_dat[31:0] = 32'ha5967e5a;
      //wbm_slave_bfm.wb_write(0, SPI_TX_0, 32'ha5967e5a);
      wbm_slave_bfm.wb_write(0, SPI_TX_0, 32'h11110055);          
      wbm_master_bfm.wb_write(0, SPI_CTRL, 32'h320);   // set 32 bit transfer, start transfer

      $display("status: %t generate transfer:  8 bit, msb first, tx posedge, rx negedge", $time);

      // Check bsy bit
      wbm_master_bfm.wb_read(0, SPI_CTRL, q);
      while (q[8])
        wbm_master_bfm.wb_read(1, SPI_CTRL, q);

      wbm_master_bfm.wb_read(1, SPI_RX_0, q);
      result = result + q;

      wbm_slave_bfm.wb_read(1, SPI_RX_0, qs);  
     // if (spi_slave.wb_dat[7:0] == 8'h5a && q == 32'h000000a5)
        if (q == 32'h11110055 && qs == 32'h000000aa)
        $display("status: %t transfer completed: ok", $time);
      else
        $display("status: %t transfer completed: nok master: (%h) slave: (%h)", $time,q,qs );
/*
//----------------------------8bit--MSB First--TX:negedge--RX:posedge-------------------------------------------//
      //spi_slave.rx_negedge = 1'b0;
      //spi_slave.tx_negedge = 1'b1;
      wbm_slave_bfm.wb_write(0, SPI_CTRL, 32'h400); 
      wbm_master_bfm.wb_write(0, SPI_TX_0, 32'ha5);
      wbm_master_bfm.wb_write(0, SPI_CTRL, 32'h2408);   // set 8 bit transfer, tx negedge
      wbm_master_bfm.wb_write(0, SPI_CTRL, 32'h2508);   // set 8 bit transfer, tx negedge, start transfer

      // Check bsy bit
      wbm_master_bfm.wb_read(0, SPI_CTRL, q);
      while (q[8])
        wbm_master_bfm.wb_read(1, SPI_CTRL, q);

      wbm_master_bfm.wb_read(1, SPI_RX_0, q);
      result = result + q;

      if (spi_slave.wb_dat[7:0] == 8'ha5 && q == 32'h00000096)
        $display("status: %t transfer completed: ok", $time);
      else
        $display("status: %t transfer completed: nok", $time);

//----------------------------16bit--LSB First--TX:negedge--RX:posedge-------------------------------------------//
      //spi_slave.rx_negedge = 1'b0;
      //spi_slave.tx_negedge = 1'b1;
      wbm_slave_bfm.wb_write(0, SPI_CTRL, 32'h400);
      wbm_master_bfm.wb_write(0, SPI_TX_0, 32'h5aa5);
      wbm_master_bfm.wb_write(0, SPI_CTRL, 32'h2c10);   // set 16 bit transfer, tx negedge, lsb
      wbm_master_bfm.wb_write(0, SPI_CTRL, 32'h2d10);   // set 16 bit transfer, tx negedge, start transfer

      $display("status: %t generate transfer: 16 bit, lsb first, tx negedge, rx posedge", $time);

      // Check bsy bit
      wbm_master_bfm.wb_read(0, SPI_CTRL, q);
      while (q[8])
        wbm_master_bfm.wb_read(1, SPI_CTRL, q);

      wbm_master_bfm.wb_read(1, SPI_RX_0, q);
      result = result + q;

      if (spi_slave.wb_dat[15:0] == 16'ha55a && q == 32'h00005a7e)
        $display("status: %t transfer completed: ok", $time);
      else
        $display("status: %t transfer completed: nok", $time);

//----------------------------64bit--LSB First--TX:posedge--RX:negedge-------------------------------------------//
      //spi_slave.rx_negedge = 1'b1;
      //spi_slave.tx_negedge = 1'b0;
      wbm_slave_bfm.wb_write(0, SPI_CTRL, 32'h200);
      wbm_master_bfm.wb_write(0, SPI_TX_0, 32'h76543210);
      wbm_master_bfm.wb_write(0, SPI_TX_1, 32'hfedcba98);
      wbm_master_bfm.wb_write(0, SPI_CTRL, 32'h3a40);   // set 64 bit transfer, rx negedge, lsb
      wbm_master_bfm.wb_write(0, SPI_CTRL, 32'h3b40);   // set 64 bit transfer, rx negedge, start transfer

      $display("status: %t generate transfer: 64 bit, lsb first, tx posedge, rx negedge", $time);

      // Check bsy bit
      wbm_master_bfm.wb_read(0, SPI_CTRL, q);
      while (q[8])
        wbm_master_bfm.wb_read(1, SPI_CTRL, q);

      wbm_master_bfm.wb_read(1, SPI_RX_0, q);
      result = result + q;
      wbm_master_bfm.wb_read(1, SPI_RX_1, q1);
      result = result + q1;

      if (spi_slave.wb_dat == 32'h195d3b7f && q == 32'h5aa5a55a && q1 == 32'h76543210)
        $display("status: %t transfer completed: ok", $time);
      else
        $display("status: %t transfer completed: nok", $time);
//----------------------------128bit--MSB First--TX:posedge--RX:negedge-------------------------------------------//
      //spi_slave.rx_negedge = 1'b0;
      //spi_slave.tx_negedge = 1'b1;
      wbm_slave_bfm.wb_write(0, SPI_CTRL, 32'h400);
      wbm_master_bfm.wb_write(0, SPI_TX_0, 32'hccddeeff);
      wbm_master_bfm.wb_write(0, SPI_TX_1, 32'h8899aabb);
      wbm_master_bfm.wb_write(0, SPI_TX_2, 32'h44556677);
      wbm_master_bfm.wb_write(0, SPI_TX_3, 32'h00112233);
      wbm_master_bfm.wb_write(0, SPI_CTRL, 32'h2400);
      wbm_master_bfm.wb_write(0, SPI_CTRL, 32'h2500);

      $display("status: %t generate transfer: 128 bit, msb first, tx posedge, rx negedge", $time);

      // Check bsy bit
      wbm_master_bfm.wb_read(0, SPI_CTRL, q);
      while (q[8])
        wbm_master_bfm.wb_read(1, SPI_CTRL, q);

      wbm_master_bfm.wb_read(1, SPI_RX_0, q);
      result = result + q;
      wbm_master_bfm.wb_read(1, SPI_RX_1, q1);
      result = result + q1;
      wbm_master_bfm.wb_read(1, SPI_RX_2, q2);
      result = result + q2;
      wbm_master_bfm.wb_read(1, SPI_RX_3, q3);
      result = result + q3;

      if (spi_slave.wb_dat == 32'hccddeeff && q == 32'h8899aabb && q1 == 32'h44556677 && q2 == 32'h00112233 && q3 == 32'h195d3b7f)
        $display("status: %t transfer completed: ok", $time);
      else
        $display("status: %t transfer completed: nok", $time);
//----------------------------32bit--MSB First--TX:negedge--RX:posedge-------------------------------------------//
      //spi_slave.rx_negedge = 1'b0;
      //spi_slave.tx_negedge = 1'b1;
      wbm_slave_bfm.wb_write(0, SPI_CTRL, 32'h400);
      wbm_master_bfm.wb_write(0, SPI_TX_0, 32'haa55a5a5);
      wbm_master_bfm.wb_write(0, SPI_CTRL, 32'h3420);
      wbm_master_bfm.wb_write(0, SPI_CTRL, 32'h3520);

      $display("status: %t generate transfer: 32 bit, msb first, tx negedge, rx posedge, ie", $time);

      // Check interrupt signal
      while (!int)
        @(posedge clk);

      wbm_master_bfm.wb_read(1, SPI_RX_0, q);
      result = result + q;
    
      @(posedge clk);
      if (!int && spi_slave.wb_dat == 32'haa55a5a5 && q == 32'hccddeeff)
        $display("status: %t transfer completed: ok", $time);
      else
        $display("status: %t transfer completed: nok", $time);
//----------------------------32bit--MSB First--TX:posedge--RX:negedge-------------------------------------------//
      //spi_slave.rx_negedge = 1'b1;
      //spi_slave.tx_negedge = 1'b0;
      wbm_slave_bfm.wb_write(0, SPI_CTRL, 32'h200);
      wbm_master_bfm.wb_write(0, SPI_TX_0, 32'h01248421);
      wbm_master_bfm.wb_write(0, SPI_CTRL, 32'h3220);
      wbm_master_bfm.wb_write(0, SPI_CTRL, 32'h3320);

      $display("status: %t generate transfer: 32 bit, msb first, tx posedge, rx negedge, ie, ass", $time);

      while (!int)
        @(posedge clk);

      wbm_master_bfm.wb_read(1, SPI_RX_0, q);
      result = result + q;

      @(posedge clk);
      if (!int && spi_slave.wb_dat == 32'h01248421 && q == 32'haa55a5a5)
        $display("status: %t transfer completed: ok", $time);
      else
        $display("status: %t transfer completed: nok", $time);
//----------------------------1bit--MSB First--TX:posedge--RX:negedge-------------------------------------------//
      //spi_slave.rx_negedge = 1'b1;
      //spi_slave.tx_negedge = 1'b0;
      wbm_slave_bfm.wb_write(0, SPI_CTRL, 32'h400);
      wbm_master_bfm.wb_write(0, SPI_TX_0, 32'h1);
      wbm_master_bfm.wb_write(0, SPI_CTRL, 32'h3201);
      wbm_master_bfm.wb_write(0, SPI_CTRL, 32'h3301);

      $display("status: %t generate transfer: 1 bit, msb first, tx posedge, rx negedge, ie, ass", $time);

      while (!int)
        @(posedge clk);

      wbm_master_bfm.wb_read(1, SPI_RX_0, q);
      result = result + q;

      @(posedge clk);
      if (!int && spi_slave.wb_dat == 32'h02490843 && q == 32'h0)
        $display("status: %t transfer completed: ok", $time);
      else
        $display("status: %t transfer completed: nok", $time);
//--------------------------------------------------------------------------------------------------------------//
      $display("\n\nstatus: %t Testbench done", $time);

      // wait 2.5us
      repeat (250)
	  @(posedge clk) ;

      $display("report (%h)", (result ^ 32'h2e8b36ab) + 32'hdeaddead);
      $display("exit (%h)", result ^ 32'h2e8b36ab);
*/
      $finish;
    end

endmodule


