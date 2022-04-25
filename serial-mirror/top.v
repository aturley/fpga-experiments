`include "cores/uart.v"

module top(
           clki,
           rx,
           tx
);
   input clki;
   input rx;
   output tx;
   reg [7:0] resetn_counter = 0;
   
   reg transmit;
   reg is_transmitting;
   reg [7:0] tx_byte;
   reg      received;
   reg [7:0] rx_byte;
   wire      resetn;

   assign resetn = &resetn_counter;
   
   uart #(.CLOCK_DIVIDE(312))
   uart0(
         .clk(clki),
         .rst(~resetn),
         .rx(rx),
         .tx(tx),
         .transmit(transmit),
         .tx_byte(tx_byte),
         .received(received),
         .rx_byte(rx_byte),
         .is_receiving(),
         .is_transmitting(is_transmitting),
         .recv_error());

   always @(posedge clki) begin
      if (!resetn)
        resetn_counter <= resetn_counter + 1;
   end
   
   always @( posedge clki )
     begin
        if (received)
          begin
             tx_byte <= rx_byte;
             transmit <= 1;
          end
        if (transmit && is_transmitting)
          transmit <= 0;
     end
endmodule
