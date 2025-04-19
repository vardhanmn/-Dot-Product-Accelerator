`timescale 1ns/1ps

module tb;

    // Clock and Reset
    reg         ACLK;
    reg         ARESETn;
    
    // AXI Lite Slave Interface (DUT as slave)
    reg         axi_lte_AWVALID;
    reg  [31:0] axi_lte_AWADDR;
    wire        axi_lte_AWREADY;
    
    reg         axi_lte_WVALID;
    reg  [31:0] axi_lte_WDATA;
    wire        axi_lte_WREADY;
    
    reg         axi_lte_BREADY;
    wire        axi_lte_BVALID;
    wire [1:0]  axi_lte_BRESP;
    
    reg  [31:0] axi_lte_ARADDR;
    reg         axi_lte_ARVALID;
    wire        axi_lte_ARREADY;
    
    wire        axi_lte_RVALID;
    wire        axi_lte_RDATA;              // Note: 1-bit in your interface
    wire        axi_lte_RRESP;
    reg         axi_lte_RREADY;

    // AXI Master Interface (DUT as master)
    wire        ARVALID;
    wire [31:0] ARADDR;
    reg         ARREADY;
    
    reg         RVALID;
    reg  [31:0] RDATA;
    reg  [1:0]       RRESP;
    wire        RREADY;
    
    wire        AWVALID;
    wire [31:0] AWADDR;
    reg         AWREADY;
    
    wire        WVALID;
    wire [31:0] WDATA;
    reg         WREADY;
    
    reg         BVALID;
    wire        BREADY;
   logic [1:0]	    BRESP;

    // DUT INSTANTIATION .DUT(TB)

    duttop dut (
     .ACLK(ACLK),
     .ARESETn(ARESETn),
     .axi_lte_AWVALID(axi_lte_AWVALID),
     .axi_lte_AWADDR(axi_lte_AWADDR),
      .axi_lte_AWREADY(axi_lte_AWREADY), // ive changed this
     .axi_lte_WVALID(axi_lte_WVALID),    
     .axi_lte_WDATA(axi_lte_WDATA),
     .axi_lte_WREADY(axi_lte_WREADY),
     .axi_lte_BREADY(axi_lte_BREADY),
     .axi_lte_BVALID(axi_lte_BVALID),
     .axi_lte_BRESP(axi_lte_BRESP),
     .axi_lte_ARADDR(axi_lte_ARADDR),
     .axi_lte_ARVALID(axi_lte_ARVALID),
     .axi_lte_ARREADY(axi_lte_ARREADY),
     .axi_lte_RVALID(axi_lte_RVALID),
     .axi_lte_RDATA(axi_lte_RDATA),
     .axi_lte_RRESP(axi_lte_RRESP),
     .axi_lte_RREADY(axi_lte_RREADY),
     .ARVALID(ARVALID),
     .ARADDR(ARADDR),
     .ARREADY(ARREADY),
     .RVALID(RVALID),
     .RDATA(RDATA),
     .RRESP(RRESP),
     .RREADY(RREADY),
     .AWVALID(AWVALID),
     .AWADDR(AWADDR),
     .AWREADY(AWREADY),
     .WVALID(WVALID),
     .WDATA(WDATA),
     .WREADY(WREADY),
     .BVALID(BVALID),
      .BREADY(BREADY),
      .BRESP(BRESP)
     
    );
  
  // internal signals
  
  logic [31:0] araddr_temp;
  logic [31:0] op_awaddr;
  reg [7:0] memory [0:511];		// internal memory in the test bench
  bit [31:0] final_output; 
  
  // initialize memory
  initial begin
    for (int i = 0; i< 511; i=i+1) begin
      memory[i] = 8'b0;
  	end
  end
  
  //assign random data to my memory
  initial begin
    for (int i = 0; i<255; i = i+1) begin
      memory[i] = $random;
    end
  end
  
  

initial begin    
            ACLK = 0;
            ARESETn = 0;
            forever #5 ACLK = ~ACLK;
        end

initial begin
            axi_lte_AWVALID      =   '0;
            axi_lte_AWADDR       =   '0;
            axi_lte_WVALID       =   '0;
            axi_lte_WDATA        =   '0;
            axi_lte_WDATA        =   '0;
            axi_lte_BREADY       =   '0;
            axi_lte_ARADDR       =   '0;
            axi_lte_ARVALID      =   '0;
            axi_lte_RREADY       =   '0;
            ARREADY              =   '0;
            RVALID               =   '0;
            RDATA                =   '0;
            RRESP                =   '0;
            AWREADY              =   '0;
            WREADY               =   '0;
            BVALID               =   '0;
            BRESP                =   '0;
        end 

initial begin
          #30 ARESETn = 1'b1;                     // deactivate the RESET
          $display("started driving WDATA to Registers : %t", $time);

      // i am 6 times calling my handle_write task to configure the registers     
  		#20 handle_write(32'h0004, $random%255); // REG1
  		#20 handle_write(32'h0008, $random%255); // REG2
  		#20 handle_write(32'h000C, 32'h4);        // REG3
      #20 handle_write(32'h0010,32'd508); // REG4
      #20 handle_write(32'h0014, 32'h0);        // REG5
      #20 handle_write(32'h0000, 32'h1);        // REG0
      $display("i have sent the address  and data for REG0");

      //i am calling the task handle Response to collect the response of write
  		#10 handle_response();
  		 handle_read();

     // i am calling my read to capture the read addr and passing it to RDATA
      @(posedge ACLK);@(posedge ACLK);
      handle_read();
      handle_read();
      handle_read();
      handle_read();
      handle_read();
      handle_read();
      handle_read();
  
     //i am capturing the output data and Writing to Memory
     handle_output_write();
     handle_output_write();
     handle_output_write();
     handle_output_write();

    #10;
    // Here i am displaying the final output value that i've stored in the Memory
    final_output [31:0]  = {memory[511],memory[510],memory[509],memory[508]};
    $display("final output : %0b", final_output);

    // i am callin the task to handle the Response
    handle_op_response();
  #200 $finish; 
end 


// in this block i am configuring the register
task handle_write(input [31:0] addr, input [31:0] data);

    @(posedge ACLK);
    
    axi_lte_AWADDR  <= addr;  
    axi_lte_AWVALID <= 1'b1;
        $display("I HAVE SENT AWADDR : %t", $time);
    axi_lte_WDATA   <= data;
    axi_lte_WVALID  <= 1'b1;
        $display("I HAVE SENT WDATA : %t", $time);
    fork
      wait(axi_lte_AWREADY);
      wait(axi_lte_WREADY);  
    join
        $display("Slave is Ready to Accepect the address data : %t", $time);
        $display("i have completed writing the data into the registers : %t", $time);
  
  		@(posedge ACLK);
 
		  axi_lte_AWVALID <= 0;
  		axi_lte_WVALID  <= 0;
  		axi_lte_AWADDR  <= 0;  
      axi_lte_WDATA   <= 0;
endtask


  // in this block i am given with the BRESP 
  // based on the response given ill display my Response statements
  task handle_response();
    axi_lte_BREADY <= 1'b1;
    @(posedge ACLK);
    wait(axi_lte_BVALID);
  if(axi_lte_BRESP == 2'b00) 
    $display("Success");
  else if(axi_lte_BRESP == 2'b10)
    $display("Error: Received BRESP at %t", $time);
    @(posedge ACLK);
    axi_lte_BREADY<= 1'b0; 
  endtask

  
  // in this block i am caputring the ARADDR into the araddr_temp
  // then i am sending the RDATA based on the ARADDR
  task handle_read();
    $display("we are inside the task handle read");
    if(ARVALID ==1) begin
    ARREADY <= 1'b1;
    araddr_temp = ARADDR; 
    @(posedge ACLK);
    ARREADY <= 0;
    end
    @(posedge ACLK)@(posedge ACLK)@(posedge ACLK)@(posedge ACLK);
    RVALID <= 1;
    RRESP <= 2'b00;
    RDATA <= memory[araddr_temp];
    @(posedge ACLK)
    if(RREADY) begin
    RVALID <=0;
    end
    @(posedge ACLK) @(posedge ACLK);@(posedge ACLK);
  endtask
  
  
  //in this block i am writing the accelerator output into the Memory
  //i'll capture the AWADDR into a local Variable op_awaddr
  //Based on address i'll Send the into the Memory  
  task handle_output_write();
    if(AWVALID ==1) begin
      AWREADY <= 1'b1;
      op_awaddr = AWADDR;
      @(posedge ACLK);
      AWREADY <= 0;
    end
    @(posedge ACLK)@(posedge ACLK)@(posedge ACLK)@(posedge ACLK);
    @(posedge ACLK)
    if(WVALID) begin
      WREADY <= 1;
      memory[op_awaddr] = WDATA[7:0];
      @(posedge ACLK)
      WREADY <=0;
    end
    @(posedge ACLK) @(posedge ACLK);@(posedge ACLK);
  endtask

  
  //In this Block i am handeling the output response. 
  //Here i'll give the Response after writing the final output Value of accelerator into Memory
  task handle_op_response();
  @(posedge ACLK); @(posedge ACLK);@(posedge ACLK); @(posedge ACLK); @(posedge ACLK);@(posedge ACLK);
    BVALID <= 1;
    BRESP <= 2'b00;
    $display("I have Sent the BRESP");
  @(posedge ACLK);
  if (BREADY) 
    BVALID <=0;
  endtask
  
	
  //for the wave form
  initial 
  begin
    $dumpfile("tb.vcd"); // VCD file for waveform
    $dumpvars(0, tb); // Dump all signals in tb
  end
  endmodule




