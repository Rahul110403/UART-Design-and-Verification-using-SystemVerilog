package uart_pkg; 
 
  //   Transaction 
  class transaction; 
    rand bit [7:0] data_in; 
 
    bit [7:0] data_out; 
 
    function void display(string tag); 
      $display("[%s] data_in=%0h data_out=%0h @%0t", 
                tag, data_in, data_out, $time); 
    endfunction 
  endclass 
 
 
  //   Generator 
  class generator; 
    mailbox #(transaction) gen2drv; 
 
    function new(mailbox #(transaction) gen2drv); 
      this.gen2drv = gen2drv; 
    endfunction 
 
    task run(); 
      transaction tr; 
      repeat(10) begin 
        tr = new(); 
        assert(tr.randomize()); 
        gen2drv.put(tr); 
        tr.display("GEN"); 
        #20; 
      end 
    endtask 
  endclass 
 
 
  //   Driver 
  class driver; 
    virtual uart_if vif; 
    mailbox #(transaction) gen2drv; 
 
    function new(virtual uart_if vif, 
                 mailbox #(transaction) gen2drv); 
      this.vif = vif; 
      this.gen2drv = gen2drv; 
    endfunction 
 
    task run(); 
      transaction tr; 
 
      wait(vif.rst == 0); 
 
      forever begin 
        gen2drv.get(tr); 
 
        @(posedge vif.clk); 
        vif.data_in <= tr.data_in; 
        vif.start   <= 1; 
 
        @(posedge vif.clk); 
        vif.start   <= 0; 
 
        // wait for TX done 
        wait(vif.tx_done); 
 
        $display("[DRV] Sent data=%0h @%0t", tr.data_in, $time); 
      end 
    endtask 
  endclass 
 
 
  //   Monitor 
  class monitor; 
    virtual uart_if vif; 
    mailbox #(transaction) mon2scb; 
 
    function new(virtual uart_if vif, 
                 mailbox #(transaction) mon2scb); 
      this.vif = vif; 
      this.mon2scb = mon2scb; 
    endfunction 
 
    task run(); 
      transaction tr; 
 
      wait(vif.rst == 0); 
 
      forever begin 
        wait(vif.rx_done); 
 
        tr = new(); 
        tr.data_out = vif.data_out; 
 
        mon2scb.put(tr); 
        tr.display("MON"); 
      end 
    endtask 
  endclass 
 
 
  //   Scoreboard 
  class scoreboard; 
    mailbox #(transaction) mon2scb; 
 
    bit [7:0] expected_queue[$]; 
 
    function new(mailbox #(transaction) mon2scb); 
      this.mon2scb = mon2scb; 
    endfunction 
 
    task run(); 
      transaction tr; 
      bit [7:0] expected; 
 
      forever begin 
        mon2scb.get(tr); 
 
        if (expected_queue.size() > 0) begin 
          expected = expected_queue.pop_front(); 
 
          if (tr.data_out == expected) 
            $display(" PASS: expected=%0h got=%0h @%0t", 
                      expected, tr.data_out, $time); 
          else 
            $display(" FAIL: expected=%0h got=%0h @%0t", 
                      expected, tr.data_out, $time); 
        end 
      end 
    endtask 
  endclass 
 
endpackage 