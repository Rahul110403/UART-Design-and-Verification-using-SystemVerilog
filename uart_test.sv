 
program test(uart_if vif); 
 
  import uart_pkg::*; 
 
  mailbox #(transaction) gen2drv = new(); 
  mailbox #(transaction) mon2scb = new(); 
 
  generator gen; 
  driver drv; 
  monitor mon; 
  scoreboard scb; 
 
  initial begin 
    gen = new(gen2drv); 
    drv = new(vif, gen2drv); 
    mon = new(vif, mon2scb); 
    scb = new(mon2scb); 
 
    fork 
      gen.run(); 
      drv.run(); 
      mon.run(); 
      scb.run(); 
    join_none 
 
#500; 
$finish; 
end 
endprogram