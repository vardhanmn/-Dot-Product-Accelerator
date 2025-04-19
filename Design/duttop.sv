`include "reg_block_fsm.sv"
`include "core_accelerator.sv"

module duttop (
    input        logic              ACLK,                  // Clock
    input        logic              ARESETn,               // Active low reset
    
    input        logic              axi_lte_AWVALID,       // Write address valid (from master)
    input        logic      [31:0]  axi_lte_AWADDR,        // Write address (from master)
    output       logic              axi_lte_AWREADY,       // Slave ready to accept write address
    input        logic              axi_lte_WVALID,        // Write data valid (from master)
    input        logic      [31:0]  axi_lte_WDATA,         // Write data (from master)
    output       logic              axi_lte_WREADY,        // Slave ready to accept write data
    input        logic              axi_lte_BREADY,        // Master ready to accept write response
    output       logic              axi_lte_BVALID,        // Slave ready to send write response
    output       logic      [1:0]   axi_lte_BRESP,         // Write response (OKAY or ERROR)
    input        logic              axi_lte_ARADDR,   
    input        logic              axi_lte_ARVALID,   
    output       logic              axi_lte_ARREADY,   
    output       logic              axi_lte_RVALID,    
    output       logic              axi_lte_RDATA,      
    output       logic              axi_lte_RRESP,       
    input        logic              axi_lte_RREADY,



    output       logic       		ARVALID,
    output       logic [31:0]       ARADDR,
    input        logic 		        ARREADY,
    input        logic              RVALID,  
    input        logic [31:0]       RDATA,
    input        logic [1:0]        RRESP,   
    output       logic              RREADY,
    output       logic              AWVALID,
    output       logic [31:0]       AWADDR,
    input        logic              AWREADY,
    output       logic              WVALID,
    output       logic [31:0]       WDATA,
    input        logic              WREADY,
    input        logic              BVALID, 
    output       logic              BREADY,
  	input        logic [1:0]        BRESP
);

    //Internal signals
    logic set_done;    
    logic set_error;   
  	logic set_busy;
    logic [31:0] REG0, REG1, REG2, REG3, REG4, REG5;  
    

    // Instantiate reg_block_fsm
    reg_block_fsm rfsm (
        .ACLK(ACLK),
        .ARESETn(ARESETn),
        .AWVALID(axi_lte_AWVALID),
        .AWADDR(axi_lte_AWADDR),
        .AWREADY(axi_lte_AWREADY),
        .WVALID(axi_lte_WVALID),
        .WDATA(axi_lte_WDATA),
        .WREADY(axi_lte_WREADY),
        .BREADY(axi_lte_BREADY),
        .BVALID(axi_lte_BVALID),
        .BRESP(axi_lte_BRESP),
        .set_done(set_done),
        .set_error(set_error),
        .ARADDR(axi_lte_ARADDR),          
        .ARVALID(axi_lte_ARVALID),        
        .ARREADY(axi_lte_ARREADY),         
        .RVALID(axi_lte_RVALID),           
        .RDATA(axi_lte_RDATA),            
        .RRESP(axi_lte_RRESP),           
        .RREADY(axi_lte_RREADY),          
        .REG0_ff(REG0),
        .REG1_ff(REG1),
        .REG2_ff(REG2),
        .REG3_ff(REG3),
        .REG4_ff(REG4),
        .REG5_ff(REG5),
        .set_busy(set_busy)     
         
    );

    // Instantiate core_accelerator
    core_accelerator acc (
        .ACLK(ACLK),
        .ARESETn(ARESETn),
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
        .BRESP(BRESP),
        .REG0(REG0),
        .REG1(REG1),
        .REG2(REG2),
        .REG3(REG3),
        .REG4(REG4),
        .REG5(REG5),
    
      .set_error(set_error),
      .set_done(set_done),
      .set_busy(set_busy)
    );

endmodule
