`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.03.2018 13:00:19
// Design Name: 
// Module Name: AXI2APB_TestBench
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


module AXI2APB_TestBench(

    );
        
    reg ACLK;
    reg ARESET;
            
    reg[31:0] ARADDR;
    reg ARVALID;
    wire ARREADY;
             
    reg[31:0] AWADDR;
    reg AWVALID;
    wire AWREADY;
    wire[31:0] RDATA;
    wire RVALID;
    wire[1:0] RRESP;
    reg RREADY;
             
    reg[31:0] WDATA;
    reg WVALID;
    reg[3:0] WSTRB;
    wire WREADY;
             
    wire[1:0]BRESP;
    wire BVALID;
    reg BREADY;
             
             //APB interface signals
             
    wire PCLK;
    wire PRESET;
    wire[31:0] PADDR;
    wire PSEL;
             
    wire PENABLE;
    wire PWRITE;
    wire[31:0] PWDATA;
    wire[3:0] PWSTRB;
    reg PREADY;
    reg[31:0] PRDATA;
    reg PSLVERR;
    
    AXI_APB_Bridge A1(
        
        
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
        
        //intial values of all inputs
        initial
        begin
            ACLK=0;
            ARESET=0;
            
            ARADDR=0;
            ARVALID=0;
            
            AWADDR=0;
            AWVALID=0;
            RREADY=0;
           
            WDATA=0;
            WVALID=0;
            WSTRB=4'b0000;
            
            BREADY=0;
            
            
            //APB Signals
            PREADY=1'b0;
            PSLVERR=1'b0;
        end
        
        always
            #5 ACLK=!ACLK;
            
            
        initial
            #400 $finish;
            
            
        initial
        begin
        //write testing
            #100
            #2 ARESET=1'b0;

            #10 ARESET=1'b1;

            #7 AWADDR=32'd48;
               AWVALID=1'b1;            
            #10 WVALID=1'b1;
                WDATA=32'd56;
            
            #10 BREADY=1'b1;
                AWVALID=0;
                WVALID=0;
                
            
                
            #10 PREADY=1'b1;
                BREADY=1'b0;
            #40 
                AWADDR=32'd49;
                AWVALID=1'b1;
            #10 WDATA=32'd78;
                WVALID=1'b1;
                PREADY=1'b1;
                
            #20 PREADY=1'b1;
            #30 WVALID=1'b0;
                
            #10 BREADY=1'b1;
                AWVALID=1'b0;
            #20 BREADY=1'b0;
            
        //Read testing
        
            #10 ARADDR=32'd76;
                ARVALID=1'b1;
                PREADY=1'b0;
            #30 PRDATA=32'd70;
                PREADY=1'b1;
                ARVALID=1'b0;


            #10 ARADDR=32'd77;
                ARVALID=1'b1;
                PREADY=1'b0;
            #30 PRDATA=32'd75;
                PREADY=1'b1;
                ARVALID=1'b0;



            #10 PREADY=1'b0;
                RREADY=1'b1;
            #10 RREADY=1'b0;     
            
        end 
endmodule