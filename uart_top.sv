Module top ; 
Import uart_pkg::*; 
uart_if vif(); 
uart_top dut( 
.clk(vif.clk), 
.rst(vif.rst), 
.start(vif.start), 
.data_in(vif.data_in), 
.data_out(vif.data_out), 
.tx_done(vif.tx_done), 
.tx_done(vif.rx_done) 
); 
initial begin 
vif.clk = 0; 
forever #5 vif.clk = ~vif.clk; 
end 
initial begin 
vif.rst=1; 
vif.start=0;    
vif.data_in =0; 
#20 vif.rst=0; 
End 
initial begin 
wait(vif.rst==0); 
repeat(10) begin 
@(posedge vif.clk); 
test.scb.expected_queue.push_back($random); 
end 
end 
test t(vif); 
endmodule