
`include "accelerator.sv"
//here one port is declared  as input and on another module also it is declare as input
module core_accelerator (
    input logic ACLK,
    input logic ARESETn,
 
// read address channel  
    output logic 		ARVALID,
    output logic [31:0] ARADDR,
    input  logic 		ARREADY,  
 
// read data Channel   
    input logic RVALID,  
    input logic [31:0] RDATA,
  // 10 for error and 10 for error
  	input logic [1:0] RRESP, //this are necessary response signals for my design as per AXI PROTOCOL   	output logic RREADY,
  	output logic RREADY,
 
// write request channel
    output logic AWVALID,
    output logic [31:0]AWADDR,
    input logic AWREADY,
  
// write data channel
    output logic WVALID,
    output logic [31:0] WDATA,
    input logic WREADY,
  
// write response channel
    input logic BVALID, 
  input logic [1:0] BRESP, 
    output logic BREADY,

//// outputs of slave interface as an input////
    input logic [31:0] REG0,     // i want to change to bit because the default value of bit is 0
    input logic [31:0] REG1,      
    input logic [31:0] REG2,      
    input logic [31:0] REG3,     
    input logic [31:0] REG4,      
    input logic [31:0] REG5,     // change to bit 
    output logic set_error,
    output logic set_done,
    output logic set_busy
);

    
    
    // internal signals
    logic [7:0] vector_a_temp, vector_b_temp;
    logic [31:0] vector_out_temp;
    logic done_temp;
    logic [31:0] address_a_temp, address_b_temp, address_a_temp_1, address_b_temp_1;  // store the address in temporary variable

    logic [7:0] fetch_length_temp,fetch_length_ff; 
    logic [31:0] address_a_ff, address_b_ff;


    logic start_temp;    
    logic [31:0] REG4_ff;
    logic [1:0] count,count_ff;
    logic clear_vec_c;
  //logic [2:0]RRESP; i have changed it

        accelerator acclereator_inst 
        (
        .clock(ACLK),
        .reset_n(ARESETn),
        .vector_a(vector_a_temp),
        .vector_b(vector_b_temp),
          .start(start_temp),
        .vector_c(vector_out_temp),
        .clear_vec_c(clear_vec_c)

        );



typedef enum logic [3:0] {
idle_state = 4'b0000,
read_request_state_1 = 4'b0001,
read_data_state_1 = 4'b0010,
read_request_state_2 = 4'b0011,
read_data_state_2 =4'b0100,
accelerator_operation_state = 4'b0101,
write_address_state = 4'b0110,
write_data_state = 4'b0111,
write_response_state = 4'b1000
} state_t;

  state_t current_state, next_state;

always_ff @ (posedge ACLK or negedge ARESETn) begin 
if (!ARESETn) begin
    current_state <= idle_state;
    address_a_ff <= 0;
    address_b_ff <= 0;
    fetch_length_ff<= 0;
    count_ff<= 0;
    REG4_ff<= 0;
end
else begin
    current_state <= next_state;
    address_a_ff <= address_a_temp;
    address_b_ff <= address_b_temp;
    fetch_length_ff <= fetch_length_temp;
    count_ff    <= count;
    REG4_ff <= REG4;

end
end



//next state logic
always_comb 
  begin
            address_a_temp     = address_a_ff;
            address_b_temp     = address_b_ff;                
            //RADDR              = '0;
            RREADY             = '0;
            next_state         = current_state;
            set_error          ='0;
    		set_busy 		   = '0;	
            ARVALID            ='0;
            ARADDR             ='0;
            start_temp         ='0;
            fetch_length_temp  =fetch_length_ff;
            count              =count_ff;
            AWVALID            ='0;
            AWADDR             ='0;
            WVALID             ='0;
            WDATA              ='0;
            BREADY             ='0;
            set_done           ='0;
			clear_vec_c = '0;
    case (current_state)
        idle_state          :begin 
                                // where i need to write fetch_len_temp = fetch_length_temp_1
                                fetch_length_temp = REG3;
                                address_a_temp = REG1;
                                address_b_temp = REG2;
                                next_state = (REG0 == 1) ? read_request_state_1 : idle_state;
          						set_busy =  REG0 ? 1 : 0;
                            end
        read_request_state_1:begin
                                address_a_temp = address_a_ff;
                                ARVALID = 1;
                                ARADDR = address_a_temp; // two seperate states
                                next_state = ARREADY ? read_data_state_1 : read_request_state_1; // how to write this
                            end 
      

        read_data_state_1   :begin
          							if(RVALID  && (RRESP == 2'b00)) 
                                    begin
                                        RREADY = 1'b1;
                                        vector_a_temp = RDATA;
                                        next_state = read_request_state_2;
                                    end 
          else if(RVALID && (RRESP != 2'b00))
                                    begin
                                        set_error = 1; // error
                                        next_state = idle_state;       
                                    end                
                                else begin
                                        next_state = read_data_state_1;
                                     end
                            end

        read_request_state_2:begin
                                address_b_temp = address_b_ff;
                                ARVALID = 1;
                                ARADDR = address_b_temp;
                                next_state = (ARREADY) ? read_data_state_2 : 				read_request_state_2;
                            end

        read_data_state_2   :begin
          							if(RVALID && (RRESP === 2'b00)) 
                                    begin
                                        RREADY = 1'b1;
                                        vector_b_temp = RDATA;
                                        next_state = accelerator_operation_state;
                                    end 
         								else if(RVALID && (RRESP != 2'b00))
                                        begin
                                        set_error = 1; // error
                                        next_state = idle_state;       
                                        end      
                                else 
                                        begin
                                         next_state = read_data_state_2;
                                        end          
                                    
                            end

accelerator_operation_state :begin 
                               start_temp = 1;
                                if(fetch_length_ff > 1 )                                                     // see about fetch length
                                 begin
                                    address_a_temp = address_a_ff + 1;
                                    address_b_temp = address_b_ff + 1;
                                    fetch_length_temp = fetch_length_ff -1;
                                    next_state = read_request_state_1;
                                 end
                            else
                                 begin
                                    next_state = write_address_state;
                                end
                            end

        write_address_state :begin 
                              count = count_ff;
                            //   REG4 = REG4_ff
                              AWVALID = 1; 
                              AWADDR = (count_ff==0) ? REG4_ff : 
                                       (count_ff==1) ? (REG4_ff + 1) : 
                                       (count_ff==2) ? (REG4_ff + 2): (REG4_ff + 3);

                              next_state = (AWREADY) ? write_data_state  : write_address_state;
                            end

           write_data_state :begin
                                count = WREADY ? count_ff + 1 : count_ff;

                                WVALID = 1;
                                WDATA = (count_ff== 0) ? vector_out_temp[7:0] : 
                                        (count_ff== 1) ? vector_out_temp[15:8] : 
                                        (count_ff==2) ? vector_out_temp[23:16] : vector_out_temp[31:24];

                                       
             next_state = ((count_ff <3) && WREADY) ? write_address_state : ((count_ff==3) && WREADY ) ? write_response_state : write_data_state; // we didnot say where to write
                            end

       write_response_state :begin
                                clear_vec_c = 1;
                                if (BVALID)
                                    begin
                                        BREADY = 1;
                                        set_done = 1;
                                        next_state = idle_state;      
                                    end 
                            end

        default : next_state = idle_state;
    endcase
  end
endmodule

