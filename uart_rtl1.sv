`timescale 1ns/1ps 
module uart_tx ( 
    input clk, 
    input rst, 
    input tx_start,          // start transmission 
    input [7:0] tx_data,     // data to send 
    output reg tx,           // serial output 
    output reg tx_done       // transmission complete 
); 
 
    reg [3:0] bit_count;     // counts 0 to 9 
    reg [9:0] shift_reg;     // start + data + stop 
    reg sending; 
 
    always @(posedge clk or posedge rst) 
    begin 
        if (rst) 
        begin 
            tx <= 1'b1;      // idle is 1 
            tx_done <= 0; 
            bit_count <= 0; 
            sending <= 0; 
        end 
        else 
        begin 
            tx_done <= 0; 
 
            // Start transmission 
            if (tx_start && !sending) 
            begin 
                // Frame = stop(1) + data + start(0) 
                shift_reg <= {1'b1, tx_data, 1'b0}; 
                sending <= 1; 
                bit_count <= 0; 
            end 
 
            // If sending 
            if (sending) 
            begin 
                tx <= shift_reg[0];        // send LSB first 
                shift_reg <= shift_reg >> 1; 
                bit_count <= bit_count + 1; 
 
                if (bit_count == 9) 
                begin 
                    sending <= 0; 
                    tx_done <= 1; 
                    tx <= 1'b1;            // back to idle 
                end 
            end 
        end 
    end 
 
endmodule 
 
//-----------------------------------------------------------------------------------------------------------------------//   
module uart_rx ( 
    input clk, 
    input rst, 
    input rx,              // serial input 
    output reg [7:0] rx_data, 
    output reg rx_done 
); 
 
    reg [3:0] bit_count; 
    reg [7:0] data_reg; 
    reg receiving; 
 
    always @(posedge clk or posedge rst) 
    begin 
        if (rst) 
        begin 
            bit_count <= 0; 
            rx_done <= 0; 
            receiving <= 0; 
        end 
        else 
        begin 
            rx_done <= 0; 
 
            // Detect start bit 
            if (!receiving && rx == 0) 
            begin 
                receiving <= 1; 
                bit_count <= 0; 
            end 
 
            // Receive data 
            else if (receiving) 
            begin 
                data_reg <= {rx, data_reg[7:1]}; // shift in 
                bit_count <= bit_count + 1; 
 
                if (bit_count == 8) 
                begin 
                    receiving <= 0; 
                    rx_data <= data_reg; 
                    rx_done <= 1; 
                end 
            end 
        end 
    end 
 
endmodule 
//-------------------------------------------------------------------------------------------------------- 
 
module uart_top ( 
    input clk, 
    input rst, 
    input start, 
    input [7:0] data_in, 
    output [7:0] data_out, 
    output tx_done, 
    output rx_done 
); 
 
    wire serial_wire; 
 
    // Instantiate Transmitter 
    uart_tx TX ( 
        .clk(clk), 
        .rst(rst), 
        .tx_start(start), 
        .tx_data(data_in), 
        .tx(serial_wire), 
        .tx_done(tx_done) 
    ); 
 
    // Instantiate Receiver 
    uart_rx RX ( 
        .clk(clk), 
        .rst(rst), 
        .rx(serial_wire), 
        .rx_data(data_out), 
        .rx_done(rx_done) 
    ); 
 
endmodule
