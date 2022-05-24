`include "cores/uart.v"

module synth (
              input       clk,
              input       resetq,
              input       message_received,
              input [7:0] note,
              input [7:0] velocity,
              output      buzz
              );
   reg [24:0]        ticks;
   reg [24:0]        on_ticks;
   reg [24:0]        wave_ticks;

   parameter         HERTZ = 12000000;

   // TODO:
   //
   // MIDI wave lengths in ticks, for notes 48 to 59. These 
   // can be shifted right or left to put them into the correct 
   // octave.
   //
   //   ticks = (CPU freq) / (note freq)
   // 
   // Python code to do this:
   //   f = 130.81
   //   cpu_freq = 12000000
   //   for i, z in zip(range(48, 60), [cpu_freq / x for x in [f * math.pow(2, i / 12) for i in range(0, 12)]]):
   //     print(f"parameter NOTE_{i} = {math.round(z)};")

   
   parameter         NOTE_48 = 91736;
   parameter         NOTE_49 = 86587;
   parameter         NOTE_50 = 81728;
   parameter         NOTE_51 = 77141;
   parameter         NOTE_52 = 72811;
   parameter         NOTE_53 = 68724;
   parameter         NOTE_54 = 64867;
   parameter         NOTE_55 = 61227;
   parameter         NOTE_56 = 57790;
   parameter         NOTE_57 = 54547;
   parameter         NOTE_58 = 51485;
   parameter         NOTE_59 = 48596;

   reg [24:0]        notes [11:0];

   assign buzz = (ticks < on_ticks);

   always @ (posedge clk)
     //       > on_ticks<
     //  1    |---------|            |------
     //       |         |            |
     //  0 ---|         |------------|
     //       >wavelength (wave_ticks)<
     begin
        if (resetq)
          begin
             notes[0] <= 91736;
             notes[1] <= 86587;
             notes[2] <= 81728;
             notes[3] <= 77141;
             notes[4] <= 72811;
             notes[5] <= 68724;
             notes[6] <= 64867;
             notes[7] <= 61227;
             notes[8] <= 57790;
             notes[9] <= 54547;
             notes[10] <= 51485;
             notes[11] <= 48596;
          end
        else if (message_received)
          begin
             if ((note > 47) && (note < 60))
               begin
                  on_ticks <= (velocity == 0) ? 0 : (notes[(note - 48)] >> 2);
                  wave_ticks <= notes[(note - 48)];
               end
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
                 .resetq(resetq),
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
     // MIDI NOTE ON MESSAGE
     // | 0 byte  | 1 byte | 2 byte |
     // | command | note   | vel    |
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
                    state <= WAITING_FOR_VELOCITY;
                 end
            end
          WAITING_FOR_VELOCITY:
            begin
               if (uart_rxd)
                 begin
                    velocity <= uart_rx;
                    state <= WAITING_FOR_COMMAND;
                    message_received <= 1;
                 end
            end
        endcase
     end
   
endmodule
     
    
