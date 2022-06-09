`include "cores/uart.v"

module synth (
              input       clk,
              input       resetq,
              input       message_received,
              input [7:0] command,
              input [7:0] value1,
              input [7:0] value2,
              output      buzz
              );
   reg [24:0]        ticks;
   reg [24:0]        on_ticks;
   reg [24:0]        wave_ticks;

   parameter         HERTZ = 12000000;

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

   reg [15:0]        amp;

   assign buzz = (ticks < on_ticks) ^ amp;

   wire [7:0]        note;
   wire [7:0]        velocity;

   assign note = value1;
   assign velocity = value2;

   localparam        NOTE_ON = 'b1001;
   
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
        else if (message_received && (command[7:4] == NOTE_ON))
          begin
             // use basic PDM to control the amplitude
             amp <= 'h5555 << velocity[6:3];
        
             if (note < 24)
               begin
               end
             else if (note < 36)
               begin
                  on_ticks <= (velocity == 0) ? 0 : (notes[(note - 24)] << 1);
                  wave_ticks <= notes[(note - 24)] << 2;
               end
             else if (note < 48)
               begin
                  on_ticks <= (velocity == 0) ? 0 : (notes[(note - 36)]);
                  wave_ticks <= notes[(note - 36)] << 1;
               end
             else if (note < 60)
               begin
                  // Base octave
                  on_ticks <= (velocity == 0) ? 0 : (notes[(note - 48)] >> 1);
                  wave_ticks <= notes[(note - 48)];
               end
             else if (note < 72)
               begin
                  on_ticks <= (velocity == 0) ? 0 : (notes[(note - 60)] >> 2);
                  wave_ticks <= notes[(note - 60)] >> 1;
               end
             else if (note < 84)
               begin
                  on_ticks <= (velocity == 0) ? 0 : (notes[(note - 72)] >> 3);
                  wave_ticks <= notes[(note - 72)] >> 2;
               end
             else if ((note < 96))
               begin
                  on_ticks <= (velocity == 0) ? 0 : (notes[(note - 84)] >> 4);
                  wave_ticks <= notes[(note - 84)] >> 3;
               end
             else if (note < 108)
               begin
                  on_ticks <= (velocity == 0) ? 0 : (notes[(note - 96)] >> 5);
                  wave_ticks <= notes[(note - 96)] >> 4;
               end
             else if (note < 120)
               begin
                  on_ticks <= (velocity == 0) ? 0 : (notes[(note - 108)] >> 6);
                  wave_ticks <= notes[(note - 108)] >> 5;
               end
             ticks <= 0;
          end
        else
          begin
             // rotate left
             amp <= {amp[14:0], amp[15]};

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
            output tx,
            output rled_0,
            output rled_1,
            output rled_2,
            output rled_3,
            );
   
   reg [7:0] uart_rx;
   reg       uart_rxd;
   reg [7:0] command;
   reg [7:0] value1;
   reg [7:0] value2;
   reg       message_received;
   
   reg [3:0] state = 0;

   reg [1:0] msg_count = 0;

   assign rled_0 = (msg_count == 0);
   assign rled_1 = (msg_count == 1);
   assign rled_2 = (msg_count == 2);
   assign rled_3 = (msg_count == 3);
   
   wire      clk;

   parameter WAITING_FOR_COMMAND = 0;
   parameter WAITING_FOR_VALUE1 = 1;
   parameter WAITING_FOR_VALUE2 = 2;

   SB_GB clk_gb (
                 .USER_SIGNAL_TO_GLOBAL_BUFFER(clki),
                 .GLOBAL_BUFFER_OUTPUT(clk)
                 );
   
   synth synth0 (
                 .clk(clk),
                 .resetq(resetq),
                 .message_received(message_received),
                 .command(command),
                 .value1(value1),
                 .value2(value2),
                 .buzz(buzz)
                 );

   // serial port (9600 baud) -- 312
   // midi port (32150 baud) -- (12Mhz) / (baud rate * 4) = 93.3...
   uart #(.CLOCK_DIVIDE(94))
   // uart #(.CLOCK_DIVIDE(312))
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
     // MIDI COMMAND
     // | 0 byte  | 1 byte | 2 byte |
     // | command | value1 | value2 |
     begin
        case (state)
          WAITING_FOR_COMMAND:
            begin
               if (message_received)
                 begin
                    message_received <= 0;
                 end
               if (uart_rxd)
                 begin
                    command <= uart_rx;
                    state <= WAITING_FOR_VALUE1;
                 end
            end
          WAITING_FOR_VALUE1:
            begin
               if (uart_rxd)
                 begin
                    value1 <= uart_rx;
                    state <= WAITING_FOR_VALUE2;
                 end
            end
          WAITING_FOR_VALUE2:
            begin
               if (uart_rxd)
                 begin
                    value2 <= uart_rx;
                    state <= WAITING_FOR_COMMAND;
                    message_received <= 1;
                    msg_count <= msg_count + 1;
                 end
            end
        endcase
     end
   
endmodule
     
    
