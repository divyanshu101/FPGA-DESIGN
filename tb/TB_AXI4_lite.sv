`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.02.2025 10:27:14
// Design Name: 
// Module Name: Tb_AXI
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


module Tb_AXI #(parameter WIDTH=32) (  );

                    logic ACLK, ARESETn;
                    logic Wstart;
                    logic   [WIDTH-1:0]  awaddr;

					logic	[(WIDTH/8)-1:0]   wstrb;
					
					logic	[WIDTH-1:0]	wdata;
					logic	[WIDTH-1:0]	araddr;
					logic	 [WIDTH-1:0] data_out;
					logic                  Rstart;
                
parameter PERIOD = 10;//3.33;

   always begin
      ACLK = 1'b0;
      #(PERIOD/2) ACLK = 1'b1;
      #(PERIOD/2);
   end

           
initial
begin
ARESETn =0;
#100;
ARESETn = 1;
//dataaddr =1;
end 


task axi_write;
   input [31:0] write_data;
   input [3:0] write_strb;
   input [31:0]   write_addr;

   begin 
   @(posedge ACLK);
    awaddr <= write_addr;
    #10;
   wdata <= write_data;
   wstrb <= write_strb;

  
   
   end
   endtask

task axi_read;
   input [31:0]   read_addr;

   begin 
   @(posedge ACLK);

   araddr <= read_addr;

   end
   endtask



initial
    begin

wdata = 0;
wstrb =0;
awaddr = 0;
araddr = 0;
data_out = 0;
Wstart =0;
Rstart =0;

#150;


Wstart = 1;
  
axi_write(32'h0398aa44,4'hf,0);
#50
axi_write(32'h00450008,4'hf,1);
#50;
axi_write(32'h06400040,4'hf,2);
#50;
axi_write(32'ha8c06f01,4'hf,3);
#50;
axi_write(32'ha8f25c97,4'hf,4);
#50;
axi_write(32'h1880c904,4'hf,5);
#50;
axi_write(32'h01010000,4'hf,6);
#50;
axi_write(32'h03003752,4'hf,7);
#50;
axi_write(32'h00180018,4'hf,8);
#50;
axi_write(32'h0a000000,4'hf,9);
#50;
axi_write(32'h0b000000,4'hf,10);
#50;
axi_write(32'h0c000000,4'hf,11);
#50;
axi_write(32'h0d000000,4'hf,12);
#30;
Wstart = 0;


#100;

Rstart = 1;

axi_read(0);
#20;
axi_read(1);
#30;
axi_read(2);
#30;
axi_read(3);
#30;
axi_read(4);
#30;
axi_read(5);
#30;
axi_read(6);
#30;
axi_read(7);
#30;
axi_read(8);
#30;
axi_read(9);
#30;
axi_read(10);
#30;
axi_read(11);
#30;
axi_read(12);
#100;

Rstart = 0;

#100;
 $finish;

end




AXI_top axi_lite 
(
             .ACLK ,
             .ARESETn,    
             .awaddr,
			    .wstrb,
			    .wdata,
		     .araddr,
		     .data_out,
		     .Wstart,
		     .Rstart
		     );

endmodule
