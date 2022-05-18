`include "cores/uart.v"

module synth (
              input clk,
              input  message_received,
              input  [7:0] note,
              input  [7:0] velocity,
              output buzz
              );
   reg [12:0]        ticks;
   reg [12:0]        on_ticks;
   reg [12:0]        wave_ticks;

   parameter         HERTZ = 12000000;

   // TODO:
   //
   // MIDI wave lengths in ticks, for notes 40 to 52. These 
   // can be shifted right or left to put them into the correct 
   // octave.
   // 

   assign buzz = (ticks < on_ticks);

   always @ (posedge clk)
     begin
        if (message_received)
          begin
             on_ticks <= (velocity == 0) ? 0 : (HERTZ >> 9);
             wave_ticks <= (HERTZ >> 8);
             ticks <= 0;
          end
        else
          begin
             if (ticks < wave_ticks)
               begin
                  ticks <= ticks + 1;
               end
             else
               begin
                  ticks <= 0;
               end
          end
     end
endmodule

module top (
            input  clki,
            input  rx,
            input  resetq,
            output buzz,
            output tx
            );
   
   reg [7:0] uart_rx;
   reg       uart_rxd;
   reg [7:0] command;
   reg [7:0] note;
   reg [7:0] velocity;
   reg       message_received;
   
   reg [3:0] state = 0;

   wire      clk;

   parameter WAITING_FOR_COMMAND = 0;
   parameter WAITING_FOR_NOTE = 1;
   parameter WAITING_FOR_VELOCITY = 2;

   SB_GB clk_gb (
                 .USER_SIGNAL_TO_GLOBAL_BUFFER(clki),
                 .GLOBAL_BUFFER_OUTPUT(clk)
                 );
   
   synth synth0 (
                 .clk(clk),
                 .message_received(message_received),
                 .note(note),
                 .velocity(velocity),
                 .buzz(buzz)
                 );

   uart #(.CLOCK_DIVIDE(312))
   uart0(
         .clk(clk),
         .rst(resetq),
         .rx(rx),
         .tx(tx),
         .transmit(),
         .tx_byte(),
         .received(uart_rxd),
         .rx_byte(uart_rx),
         .is_receiving(),
         .is_transmitting(),
         .recv_error());

   always @ (posedge clk)
     begin
        if (message_received)
          begin
             
          end
     end

   always @ (posedge clk)
     begin
        case (state)
          WAITING_FOR_COMMAND:
            begin
               if (message_received)
                 begin
                    message_received <= 0;
                 end
               if (uart_rxd && (uart_rx[7:4] == 4'b1001))
                 begin
                    command <= uart_rx;
                    state <= WAITING_FOR_NOTE;
                 end
            end
          WAITING_FOR_NOTE:
            begin
               if (uart_rxd)
                 begin
                    note <= uart_rx;
                    state = WAITING_FOR_VELOCITY;
                 end
            end
          WAITING_FOR_VELOCITY:
            begin
               if (uart_rxd)
                 begin
                    velocity <= uart_rx;
                    state = WAITING_FOR_COMMAND;
                    message_received <= 1;
                 end
            end
        endcase
     end
   
endmodule
     
    
