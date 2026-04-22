RTL CODE FOR THE UART 
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