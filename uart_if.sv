 
interface uart_if; 
 
  logic clk; 
  logic rst; 
 
  logic start; 
  logic [7:0] data_in; 
 
  logic [7:0] data_out; 
  logic tx_done; 
  logic rx_done; 
 
endinterface 