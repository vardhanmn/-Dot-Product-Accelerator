 module reg_block_fsm (
    input   logic                ACLK,          // Clock
    input   logic                ARESETn,       // Active low reset

    input   logic                AWVALID,       // Write address valid (from master)
    input   logic    [31:0]      AWADDR,        // Write address (from master)
    output  logic                AWREADY,       // Slave ready to accept write address

    input   logic                WVALID,        // Write data valid (from master)
    input   logic    [31:0]      WDATA,         // Write data (from master)
    output  logic                WREADY,        // Slave ready to accept write data

    input   logic                BREADY,        // Master ready to accept write response
    output  logic                BVALID,        // Slave ready to send write response
   // 00 success 10 error all othe rcombinations are invalid for our requirements. encodings are as per axi spec
    output  logic    [1:0]       BRESP,         // Write response (OKAY or ERROR)
   

    //read request
    input   logic    [31:0]      ARADDR,         //ill get RADDR from the Master 
    input   logic                ARVALID,        //i will get RVALID from master saying that valid address is sent
    output  logic                ARREADY,       //i will make ARREADY high

    //read data
    output  logic               RVALID,        // ill make my RVALID high to say the RDATA is vallid
    output  logic    [31:0]     RDATA,         // ill send my RDATA
    output  logic               RRESP,         // ill send my RRESP
    input   logic               RREADY,        //  
        
 
    output  logic    [31:0]      REG0_ff,          
    output  logic    [31:0]      REG1_ff,      
    output  logic    [31:0]      REG2_ff,      
    output  logic    [31:0]      REG3_ff,     
    output  logic    [31:0]      REG4_ff,      
    output  logic    [31:0]      REG5_ff,  

    input   logic                set_done,      // to set the status register
    input   logic                set_error,     // to set the status register
    input   logic                set_busy
);

    // Internal registers to store data
    logic           send_bresp;                   // signal that will send the reg 5 data to the master in the test bench
    logic           send_bresp_ff;                // signal that holds the previous value of send_bresp response   
   	logic   [31:0]  REG0;                      // holds the previous value of REG0
    logic   [31:0]  REG1;                      // holds the previous value of REG1
    logic   [31:0]  REG2;                      // holds the previous value of REG2
    logic   [31:0]  REG3;                      // holds the previous value of REG3
   logic   [31:0]  REG4;
    logic   [31:0]  REG5;                      // holds the previous value of REG5

    assign   BVALID = send_bresp_ff; 
    assign   BRESP  = 2'b00;  

    always_comb begin
        //initialization
            REG0    = REG0_ff;                     // default value will be the previous value
            REG1    = REG1_ff;                     // default value will be the previous value
            REG2    = REG2_ff;                     // default value will be the previous value
            REG3    = REG3_ff;                     // default value will be the previous value
            REG4    = REG4_ff;                     // default value will be the previous value
            REG5    = REG5_ff;                     // default value will be the previous value
            AWREADY = 0;                           // the default value of AWREADY will be 0 when it receives the AWVALID for write address then we will make AWREADY 1               
            WREADY  = 0;                           // the default value of WREADY will be 0 when it receives the WVALID for Write data then we will make WREADY 1                     
            send_bresp = (BREADY && send_bresp_ff) ? 0 : (send_bresp_ff ? 1 : 0);

        //oeration
         if (AWVALID && WVALID) begin
            AWREADY = 1'b1;                        // i will make my AWREADY 1 to accepect the write address
            WREADY = 1'b1;                         // i will make my WREADY  1 to accepect the write data 

            case (AWADDR)
                    32'h0000: begin 
                      		  REG0 = WDATA;
                      		  send_bresp = 1'b1;
                    		  end	// will have the information about control bit
                    32'h0004: REG1 = WDATA;         // will have the starting address of Vector A
                    32'h0008: REG2 = WDATA;         // will have the starting address of Vector B
                    32'h000C: REG3 = WDATA;         // will have the information about the Vector Length
                    32'h0010: REG4 = WDATA;         // will have the information about the Output Address
                    32'h0014: REG5 = WDATA;
                                       //status  //clear data FIXME //indicates the status error, done, invalid, busy
                                 // if the data is writtened in the REG5 then i will make my bresp 1 // this will say data is written successfully 
                              
                    default:begin
                             send_bresp = (BREADY && send_bresp_ff) ? 0 : (send_bresp_ff ? 1 : 0);           
                            end
            endcase
            end
    end
   // status of REG5 indication	
   // 00 invalid status
   // 01 busy status
   // 10 error status
   // 11 done status
     
    always @(posedge ACLK or negedge ARESETn) begin
      if(!ARESETn) begin
            send_bresp_ff <= 0;
            REG0_ff <= 0;
            REG1_ff <= 0;            
            REG2_ff <= 0;
            REG3_ff <= 0;
            REG4_ff <= 0;
            REG5_ff <= 0;            
        end

        else begin
            send_bresp_ff <= send_bresp;
            REG0_ff <=  set_done ? 32'h0 : REG0;
            REG1_ff <= REG1;
            REG2_ff <= REG2;
            REG3_ff <= REG3;
            REG4_ff <= REG4;
            REG5_ff <= set_busy ? 32'h1 : (set_done ? 32'h3 :(set_error ? 32'h2 : REG5)); //reg5 is updated based on the external signals set_done and set_busy neither is triggered it will hold the previous value
        end 
    end
endmodule


  