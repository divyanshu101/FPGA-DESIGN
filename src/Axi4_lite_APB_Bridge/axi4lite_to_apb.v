`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.03.2018 11:47:33
// Design Name: 
// Module Name: AXI_APB_Bridge
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module AXI_APB_Bridge(
    
    //AXI interface signals
     ACLK,
     ARESET,
    
     ARADDR,
     ARVALID,
     ARREADY,
     
     AWADDR,
     AWVALID,
     AWREADY,

     RDATA,
     RVALID,
     RRESP,
     RREADY,
     
     WDATA,
     WVALID,
     WSTRB,
     WREADY,
     
     BRESP,
     BVALID,
     BREADY,
     
     //APB interface signals
     
     PCLK,
     PRESET,
     PADDR,
     PSEL,
     
     PENABLE,
     PWRITE,
     PWDATA,
     PWSTRB,
     PREADY,
     PRDATA,
     PSLVERR

    );
    

        
    //AXI interface signals
     
     input ACLK;
     input ARESET;
        
     input[31:0] ARADDR;
     input ARVALID;

     output reg ARREADY;
     input[31:0] AWADDR;
     input AWVALID;
     output reg AWREADY;
     
     output reg[31:0] RDATA;
     output reg RVALID;
     output reg[1:0] RRESP;
     input RREADY;
     
     input[31:0] WDATA;
     input WVALID;
     input[3:0] WSTRB;
     output reg WREADY;
     
     output reg[1:0] BRESP;
     output reg BVALID;
     input BREADY;
     
     //APB interface signals
     
     output reg PCLK;
     output reg PRESET;
     output reg[31:0] PADDR;
     output reg PSEL;
     
     output reg PENABLE;
     output reg PWRITE;
     output reg[31:0] PWDATA;
     output reg[3:0] PWSTRB;
     input PREADY;
     input[31:0] PRDATA;
     input PSLVERR;
     
     
     //state registers
     reg[3:0] present_state;
     reg[3:0] next_state;
     
     //sampled address and datas
     reg[31:0] sampled_address;
     
     
     
     
     //initially handle writes
     
     parameter IDLE_STATE=4'b0000;//ARREADY=1 and AWREADY=1
     parameter WRITE_ADDRESS_RECEIVED_STATE=4'b0001;//ARREADY=0 and AWREADY=0, WREADY=1 if it's a write
     parameter WRITE_DATA_RECEIVED_STATE=4'b0010;//WREADY=0,PSEL=1,PWRITE=1
     parameter PENABLE_SIGNAL=4'b0011;//PENABLE=1,WREADY=0
     parameter DATA_TRANSFERRED_STATE=4'b0100;//PENABLE=0 and WREADY=1
     parameter TRANSFER_COMPLETE_STATE=4'b0101;//BVALID=1, once BREADY=1 go to idle
     parameter READ_ADDRESS_RECEIVED_STATE=4'B0110;//ARREADY=0 and AWREADY=0
     parameter PENABLE_READ_SIGNAL=4'b0111;//PENABLE=1'b1
     parameter READ_DATA_TRANSFERRED_STATE=4'b1000;//PENABLE=1'b0
    
    //if you want to reset the device it's the same for AXI and APB
    always@(*)
    begin
        PRESET=ARESET;
    end
    
    always@(*)
    begin
        PWSTRB=WSTRB;
    end
    
    
    /*
        state transition on a clock edge
    */
    
    always@(posedge ACLK or posedge ARESET)
    begin
        if(!ARESET)
        begin
            present_state<=IDLE_STATE;
        end
        else
        begin
            present_state<=next_state;
        end
    end
    
    /*
        next state logic
    */
    always@(*)//ideally it shouldn't be (*) but it should be (present_state and inputs)
    begin
        next_state=IDLE_STATE;
        case(present_state)
            IDLE_STATE:
            begin
                next_state=IDLE_STATE;
                if(ARVALID==1'b1 && AWVALID==1'b0)
                begin
                    next_state=READ_ADDRESS_RECEIVED_STATE;
                end
                else if(ARVALID==1'b0 && AWVALID==1'b1)
                begin
                    next_state=WRITE_ADDRESS_RECEIVED_STATE;
                end
                else if(ARVALID==1'b1 && AWVALID==1'b1)
                begin
                    next_state=READ_ADDRESS_RECEIVED_STATE;
                end
                else
                begin
                    next_state=IDLE_STATE;
                end
            end
            WRITE_ADDRESS_RECEIVED_STATE://In this state WREADY=1
            begin
                next_state=WRITE_ADDRESS_RECEIVED_STATE;
                if(WVALID==0)
                begin
                    next_state=WRITE_ADDRESS_RECEIVED_STATE;
                end
                else
                begin
                    next_state=WRITE_DATA_RECEIVED_STATE;
                end
            end
            WRITE_DATA_RECEIVED_STATE:
            begin
                next_state=PENABLE_SIGNAL;
            end
            PENABLE_SIGNAL:
            begin
                next_state=PENABLE_SIGNAL;
                if(PREADY)
                begin
                    next_state=DATA_TRANSFERRED_STATE;
                end
                else
                begin
                    next_state=PENABLE_SIGNAL;
                end
            end
            DATA_TRANSFERRED_STATE:
            begin
                next_state=DATA_TRANSFERRED_STATE;
                if(WVALID==1)
                begin
                    next_state=WRITE_DATA_RECEIVED_STATE;
                end
                else
                begin
                    next_state=TRANSFER_COMPLETE_STATE;
                end
            end
            TRANSFER_COMPLETE_STATE:
            begin
                next_state=IDLE_STATE;
            end
            READ_ADDRESS_RECEIVED_STATE://start set up phase here
            begin
                next_state=PENABLE_READ_SIGNAL;  
            end
            PENABLE_READ_SIGNAL:
            begin
                next_state=PENABLE_READ_SIGNAL;
                if(PREADY==1'b1)
                begin
                    next_state=READ_DATA_TRANSFERRED_STATE;
                end
                else
                begin
                    next_state=PENABLE_READ_SIGNAL;
                end
            end
            READ_DATA_TRANSFERRED_STATE:
            begin
                next_state=READ_DATA_TRANSFERRED_STATE;
                if(RREADY==1'b1)
                begin
                    next_state=READ_ADDRESS_RECEIVED_STATE;
                end
                else
                begin
                    next_state= IDLE_STATE;
                end
            end
           
            
        endcase
        
    end
   
    //state outputs
    always@(*)
    begin
           ARREADY=1'b0;
           AWREADY=1'b0;
           RVALID=1'b0;
           WREADY=1'b0;
           BVALID=1'b0;
           
           //APB outputs
           PSEL=1'b0;
           PENABLE=1'b0;
           PWRITE=1'b0;
        case(present_state)
            IDLE_STATE:
            begin
                ARREADY=1'b1;
                AWREADY=1'b1;
                RVALID=1'b0;
                WREADY=1'b0;
                BVALID=1'b0;
                
                //APB outputs
                PSEL=1'b0;
                PENABLE=1'b0;
                PWRITE=1'b0;
                
            end
            WRITE_ADDRESS_RECEIVED_STATE:
            begin
                ARREADY=1'b0;
                AWREADY=1'b0;
                RVALID=1'b0;
                WREADY=1'b1;
                BVALID=1'b0;
                
                //APB outputs
                PSEL=1'b0;
                PENABLE=1'b0;
                PWRITE=1'b0;
            end
            WRITE_DATA_RECEIVED_STATE:
            begin
                ARREADY=1'b0;
                AWREADY=1'b0;
                RVALID=1'b0;
                WREADY=1'b0;
                BVALID=1'b0;
                
                //APB outputs
                PSEL=1'b1;
                PENABLE=1'b0;
                PWRITE=1'b1;
            end
            PENABLE_SIGNAL:
            begin
                ARREADY=1'b0;
                AWREADY=1'b0;
                RVALID=1'b0;
                WREADY=1'b0;
                BVALID=1'b0;
                
                //APB outputs
                PSEL=1'b1;
                PENABLE=1'b1;
                PWRITE=1'b1;
            end
            DATA_TRANSFERRED_STATE:
            begin
                ARREADY=1'b0;
                AWREADY=1'b0;
                RVALID=1'b0;
                WREADY=1'b1;
                BVALID=1'b0;
                
                //APB outputs
                PSEL=1'b1;
                PENABLE=1'b0;
                PWRITE=1'b1;
            end
            TRANSFER_COMPLETE_STATE:
            begin
                ARREADY=1'b0;
                AWREADY=1'b0;
                RVALID=1'b0;
                WREADY=1'b0;
                BVALID=1'b1;
                
                //APB outputs
                PSEL=1'b0;
                PENABLE=1'b0;
                PWRITE=1'b0;
            end
            READ_ADDRESS_RECEIVED_STATE:
            begin
                ARREADY=1'b0;
                AWREADY=1'b0;
                RVALID=1'b0;
                WREADY=1'b0;
                BVALID=1'b0;
                
                //APB outputs
                PSEL=1'b1;
                PENABLE=1'b0;
                PWRITE=1'b0;
            end
            PENABLE_READ_SIGNAL:
            begin
                ARREADY=1'b0;
                AWREADY=1'b0;
                RVALID=1'b0;
                WREADY=1'b0;
                BVALID=1'b0;
                
                //APB outputs
                PSEL=1'b1;
                PENABLE=1'b1;
                PWRITE=1'b0;
            end
            READ_DATA_TRANSFERRED_STATE:
            begin
                ARREADY=1'b0;
                AWREADY=1'b0;
                RVALID=1'b1;
                WREADY=1'b0;
                BVALID=1'b0;
                
                //APB outputs
                PSEL=1'b0;
                PENABLE=1'b0;
                PWRITE=1'b0;
            end
        endcase
        
    end
    
    always@(*)
    begin
        PCLK=ACLK;
    end
    //address sample LOGIC
    always@(posedge ACLK)
    begin
        if(present_state==IDLE_STATE && ARVALID==1'b1)
        begin
            sampled_address<=ARADDR;
        end
        else if(present_state==IDLE_STATE && AWVALID==1'b1)
        begin
            sampled_address<=AWADDR;
        end
        else
        begin
            sampled_address<=sampled_address;
        end
    end
    
    //write data on PWDATA bus and also address sampling
    always@(posedge ACLK)
    begin
        if((present_state==WRITE_ADDRESS_RECEIVED_STATE && WVALID==1'b1) || (present_state==DATA_TRANSFERRED_STATE && WVALID==1'b1))
        begin
            PADDR<=sampled_address;
            PWDATA<=WDATA;
            
        end
        else if(present_state==IDLE_STATE && ARVALID==1'b1)
        begin
            PADDR<=ARADDR;
        end
        else if(present_state==READ_DATA_TRANSFERRED_STATE && RREADY==1'b1)
        begin
            PADDR<=sampled_address;
        end
    end
    
    
    //error handling
    always@(posedge ACLK or negedge ARESET)
    begin
        if(ARESET==1'b0)
        begin
            BRESP<=2'd0;
        end
        else
            begin
            if(present_state==PENABLE_SIGNAL && PREADY==1'b1 && BRESP==2'b00)//change the logic since if one thing is error the whole burst should be an error
            begin
                if(PSLVERR==1'b0)
                begin
                    BRESP<=2'b00;
                end
                else
                begin
                    BRESP<=2'b11;//error
                end
            end
            else if(present_state==PENABLE_SIGNAL && PREADY==1'b1 && BRESP==2'b11)//an error that happenned before
            begin
                BRESP<=2'b11;//an error
            end
            else
            begin
                BRESP<=BRESP;
            end
        end
    end
    
    //Read address sampling  
    always@(posedge ACLK)
    begin
        if(present_state==PENABLE_READ_SIGNAL && PREADY==1'b1 && PSLVERR==1'b0)
        begin
            RDATA<=PRDATA;
        end
    end
    
    always@(posedge ACLK or negedge ARESET)
    begin
        if(ARESET==1'b0)
        begin
            RRESP=2'b00;
        end
        else
        begin
            if(present_state==PENABLE_READ_SIGNAL && PREADY==1'b1)
            begin
                if(PSLVERR==1'b1)
                begin
                    RRESP<=2'b11;
                end
                else
                begin
                    RRESP<=2'b00;
                end
                    
            end
            
        end
    end 
    
endmodule